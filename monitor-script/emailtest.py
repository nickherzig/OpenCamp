import smtplib
import os
from dotenv import load_dotenv
from email.message import EmailMessage
import ssl


load_dotenv()
email_sender = "opencamp.app@gmail.com"
email_password = os.getenv("GMAIL_PASSWORD")

body = """
This worked lets go
"""

em = EmailMessage()

em['From'] = email_sender
em['To'] = "nickherzig4455661@gmail.co"
em['Subject'] = "Test email"
em.set_content(body)

context = ssl.create_default_context()

s = smtplib.SMTP_SSL('smtp.gmail.com', 465, context=context)

s.login(email_sender, email_password)
s.sendmail(email_sender, "nickherzig4455661@gmail.co", em.as_string())

s.quit()