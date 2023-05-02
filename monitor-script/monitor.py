
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import datetime
from datetime import date
from dateutil.relativedelta import relativedelta
import requests
import smtplib
import os
from dotenv import load_dotenv
from email.message import EmailMessage
import ssl


#initializes firestore credentials
cred = credentials.Certificate("./opencamp-b9298-e050bd58c08f.json")
firebase_admin.initialize_app(cred)
db = firestore.client()

load_dotenv()

MAX_MONTHS = 6
EMAIL_ACCOUNT = "opencamp.app@gmail.com"

# Handles read/write to the opencamp firestore database
class FirestoreModel:
    def __init__(self):
        #initializes database
        self.db = firestore.client()
        self.trackers_ref = self.db.collection("trackers").where(u'active', u'==', True)

    # Returns dicitonary of all active trackers
    def get_trackers(self):
        # Dictionary where key is camground name and values are trackers associated with camground
        tracker_dict = {}
        tracker_docs = self.trackers_ref.stream()

        for td in tracker_docs:
            tracker = td.to_dict()
            tracker["id"] = td.id
            if tracker['campground']['id'] in tracker_dict:
                tracker_dict[tracker['campground']['id']].append(tracker)
            else:
                tracker_dict[tracker['campground']['id']] = [tracker]
        
        return tracker_dict
    
    # Changes a value of a tracker with a given id. updated field is a list of fields to change
    def update_tracker(self, id, updated_fields):
        tracker_ref = db.collection('trackers').document(id)
        for change in updated_fields:
            tracker_ref.update(change)

class EmailModel:
    def __init__(self) -> None:
        self.email_sender = EMAIL_ACCOUNT
        self.email_password = os.getenv("GMAIL_PASSWORD")
        self.context = ssl.create_default_context()
        self.smtp = smtplib.SMTP_SSL('smtp.gmail.com', 465, context=self.context)
    
    #returns true on successful login, false on failure
    def login(self):
        try:
            self.smtp.login(self.email_sender, self.email_password)
            return True
        except:
            return False
        
    def send_email(self, email_object, reciever):
        try:
            self.smtp.sendmail(self.email_sender, reciever, email_object.as_string())
            print("sent email to", reciever)
            return True
        except:
            return False
        
    def create_email_object(self, subject, body, reciever):
        em = EmailMessage()
        em['From'] = self.email_sender
        em['To'] = reciever
        em['Subject'] = subject
        em.set_content(body)

        return em
        
#returns availability for a given campground for 7 months in dicitonary form. Key is month, value is availability for all sites
#Accesses rec.gov api
def get_availability(id):
    availability_dict = {}
    date = datetime.datetime.now()

    #grabs campground availability for 7 months. All trackers will fall under this range
    for i in range(MAX_MONTHS + 1):
        url = 'https://www.recreation.gov/api/camps/availability/campground/{}/month?start_date={}-{}-01T00%3A00%3A00.000Z'.format(id, date.year, date.strftime("%m"))
        headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36'}
        resp = requests.get(url, headers=headers)
        availability_dict[date.strftime("%m")] = resp.json()
        date = date + relativedelta(months=1)
        
    return availability_dict
    

#returns list of available sites, empty list if non are available
def is_available(availability, start_date, num_nights):
    available_sites = []
    month = start_date.strftime("%m")

    for id, site in availability[month]["campsites"].items():
        available = True
        placeholder_date = start_date
        placeholder_site = site
        for i in range(num_nights):
            # If either the day does not exist or the spot is reserved, the site is not available
            if (not (placeholder_date.strftime("%Y-%m-%d") + "T00:00:00Z") in placeholder_site["availabilities"] or
                not placeholder_site["availabilities"][placeholder_date.strftime("%Y-%m-%d") + "T00:00:00Z"] == "Available"):
                available = False
                break
            # Adds one day to the date
            placeholder_date = placeholder_date + relativedelta(days=1)
            # If new date is in new month, switches the availabilty page to the next months
            if placeholder_date.strftime("%m") != month:
                placeholder_site = availability[placeholder_date.strftime("%m")]["campsites"][id]
        if available:
            available_sites.append(site["site"])
      
    return sorted(available_sites, key=lambda x: (len(x), x))

#Given available sites fo a specific site, creates the email body to send to users
def create_email_body(availableSites, tracker):
        body = "These sites are currently available for reservation at {} on {} for {} night(s):\n".format(tracker["campground"]["name"], tracker["startDate"].strftime("%Y-%m-%d"), tracker["numNights"])
        campsites = "\n".join(availableSites)
        link = "\n\nBook campsite reservations at https://www.recreation.gov/camping/campgrounds/{}".format(tracker["campground"]["id"])
        return(body + campsites + link)


def main():
    firestore_model = FirestoreModel()
    email_model = EmailModel()
    if (not email_model.login()):
        print("Could not log into email, try again later")
        quit()

    trackers = firestore_model.get_trackers()
    date = datetime.datetime.now()

    #Checks availability for tracker, by specific campground
    for campground_id in trackers.keys():
        print(campground_id)
        for tracker in trackers[campground_id]:
            current_availability = get_availability(tracker["campground"]["id"])
            print("\t {}, {}, {}".format(tracker["campground"]["name"], tracker["userEmail"], tracker["startDate"]))

            #If tracker is expired, set Active field to False
            if date.strftime("%Y-%m-%d") > tracker["startDate"].strftime("%Y-%m-%d"):
                firestore_model.update_tracker(tracker["id"], {"active": False})
            else:
                available_sites = is_available(current_availability, tracker["startDate"], tracker["numNights"])
                #If sites are available, email user, set Active to False, and Success to True
                if available_sites:
                    print("These sites are available:")
                    print(available_sites)
                    body = create_email_body(available_sites, tracker)
                    subject = "Campsites available at {} on {}".format(tracker["campground"]["name"], tracker["startDate"].strftime("%Y-%m-%d"), tracker["numNights"])
                    email_model.send_email(email_model.create_email_object(subject, body, tracker["userEmail"]), tracker["userEmail"])
                    # firestore_model.update_tracker(tracker["id"], [{"active": False}, {"success": True}])
                else:
                    print("No sites are available at this time")


main()
                