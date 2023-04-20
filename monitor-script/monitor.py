
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import datetime
from datetime import date
from dateutil.relativedelta import relativedelta
import requests

#initializes firestore credentials
cred = credentials.Certificate("./opencamp-b9298-e050bd58c08f.json")
firebase_admin.initialize_app(cred)


db = firestore.client()

MAX_MONTHS = 6

#Handles read/write to the opencamp firestore database
class FirestoreModel:
    def __init__(self):
        #initializes database
        self.db = firestore.client()
        self.trackers_ref = self.db.collection("trackers")

    #returns dicitonary of all trackers
    def get_trackers(self):
        #Dictionary where key is camground name and values are trackers associated with camground
        tracker_dict = {}
        tracker_docs = self.trackers_ref.stream()

        for td in tracker_docs:
            tracker = td.to_dict()
            if tracker['campground']['id'] in tracker_dict:
                tracker_dict[tracker['campground']['id']].append(tracker)
            else:
                tracker_dict[tracker['campground']['id']] = [tracker]
        
        return tracker_dict
    
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
    return available_sites
        

            

def main():
    firestore_model = FirestoreModel()
    trackers = firestore_model.get_trackers()
    date = datetime.datetime.now()

    #Checks availability for tracker, by specific campground
    for campground_id in trackers.keys():
        print(campground_id)
        for tracker in trackers[campground_id]:
            
            print("\t {}, {}, {}".format(tracker["campground"]["name"], tracker["userEmail"], tracker["startDate"]))
            current_availability = get_availability(tracker["campground"]["id"])
            print(tracker["startDate"].strftime("%Y-%m-%d"))
            startdate = tracker["startDate"]

            print(is_available(current_availability, tracker["startDate"], tracker["numNights"]))
                    


main()