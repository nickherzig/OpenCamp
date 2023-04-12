//
//  FirebaseModels.swift
//  Open Camp
//
//  Created by Nick Herzig on 3/13/23.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift

let MAX_TRACKERS = 10

//Struct to represent a tracking object that is stored in the database.
struct Tracker: Codable, Identifiable {
    @DocumentID var id : String? = UUID().uuidString
    var campground : Campground
    var userEmail : String
    var userId : String
    var startDate : Date
    var numNights : Int
    var active : Bool
    var success: Bool
}


class FirebaseHandler : ObservableObject {
    let user = Auth.auth().currentUser
    let db = Firestore.firestore()
    @Published var userActiveTrackers : [Tracker] = []
    
    //Adds a tracker struct to firestore
    func addTracker(campground : Campground, date : Date, numNights : Int) -> String{
        if user == nil{
            return ""
        }
        
        //Checks if user has too many trackers
        if userActiveTrackers.count >= MAX_TRACKERS {
            return "max_trackers"
        }
        
        //Checks if user tracker already exists.
        for tracker in userActiveTrackers{
            if tracker.campground.id == campground.id && tracker.startDate == date && tracker.numNights == numNights {
                return "duplicate_tracker"
            }
        }
        
        //Adds tracker to the firestore database
        let newTracker : Tracker = Tracker(campground: campground, userEmail: (user?.email)!, userId: user!.uid, startDate: date, numNights: numNights, active: true, success: false)
        do {
            try db.collection("trackers").document(newTracker.id!).setData(from: newTracker)
            return newTracker.id!
        }
        catch let error {
            print("Error writing tracker to Firestore: \(error)")
            return ""
        }
    }
    
    //sets userActiveTrackers list
    func getTrackers(isActive : Int){
        if user == nil{
            return
        }
        var userActiveTrackersPh : [Tracker] = []
        db.collection("trackers").whereField("userId", isEqualTo: user!.uid).whereField("active", isEqualTo: true).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting tackers: \(err)")
            }
            else{
                var tracker : Tracker
                for document in querySnapshot!.documents{
                    do{
                        tracker = try document.data(as: Tracker.self)
                        userActiveTrackersPh.append(tracker)
                    } catch {
                        print(error)
                      }
                }
                self.userActiveTrackers = (userActiveTrackersPh.sorted{$0.startDate < $1.startDate}).map{ $0 }
            }
        }
    }
    
    //deletes tracker with given trackerId
    func deleteTracker(trackerId : String) -> String {
        var retValue = ""
        if user == nil {
            return "error"
        }
        db.collection("trackers").document(trackerId).delete() { err in
            if let err = err {
                print("Error removing tracker \(err.localizedDescription)")
                retValue = "error"
            }
        }
        return retValue
        
    }
    
}
