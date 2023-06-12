# Open Camp
Open camp is an iOS app built on swift that can be used to place reservation trackers on fully booked campsites. <br>

Campsite data is pulled from the recreation.gov api. https://ridb.recreation.gov/docs <br>

The app is built using swift/swiftui for the frontend, firebase for auth and databases, and AWS for lambda functions. <br>

The app allows users to create an account and add campground trackers to the database. A python monitoring script is on a timed AWS lambda function that monitors all user's active trackers. This code can be found in monitor-script. If a campground is available for a given date, the user then recieves an email with each available site and a link to book. <br>

This project was completed in June 2023 by Nick Herzig as his Cal Poly Senior Project