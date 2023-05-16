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
    let auth = Auth.auth()
    let db = Firestore.firestore()
    @Published var userActiveTrackers : [Tracker] = []
    @Published var userInactiveTrackers : [Tracker] = []
    
    
    //Adds a tracker struct to firestore
    func addTracker(campground : Campground, date : Date, numNights : Int) -> String{
        let user = auth.currentUser
        if user == nil{
            return ""
        }
        
        if (!self.isVerified()){
            return "not_verified"
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
    
    //Logs out current user
    func logout() -> Bool {
        do {
            try auth.signOut()
            self.reloadUser()
            return true
        }
        catch{
            print("Could not sign user out: \(error)")
        }
        return false
    }
    
    //Gets all updated state info on the user
    func reloadUser(){
        auth.currentUser?.reload(completion: { (error) in
            if (error != nil){
                print(error?.localizedDescription ?? "error")
            }
        })
    }
    
    //Sends an email verification to the current user's email
    func sendEmailVerification(){
        let user = self.auth.currentUser
        if user != nil && !user!.isEmailVerified {
            user?.sendEmailVerification(completion: { (error) in
                if (error != nil){
                    print(error?.localizedDescription ?? "error")
                }
            })
        }
        else {
            print("Unable to send email verification")
        }
        
    }
    
    //Checks if user has verified their email
    func isVerified() -> Bool{
        self.reloadUser()
        let user = self.auth.currentUser
        if user != nil{
            return user!.isEmailVerified
        }
        return false
    }
    
    //sets userActiveTrackers list
    func getTrackers(isActive : Bool){
        let user = self.auth.currentUser
        if user == nil{
            return
        }
        var userTrackersPh : [Tracker] = []
        db.collection("trackers").whereField("userId", isEqualTo: user!.uid).whereField("active", isEqualTo: isActive).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting tackers: \(err)")
            }
            else{
                var tracker : Tracker
                for document in querySnapshot!.documents{
                    do{
                        tracker = try document.data(as: Tracker.self)
                        userTrackersPh.append(tracker)
                    } catch {
                        print(error)
                      }
                }
                if (isActive){
                    self.userActiveTrackers = (userTrackersPh.sorted{$0.startDate < $1.startDate}).map{ $0 }
                }
                else {
                    self.userInactiveTrackers = (userTrackersPh.sorted{$0.startDate < $1.startDate}).map{ $0 }
                }
                
                
            }
        }
    }
    
    //deletes tracker with given trackerId
    func deleteTracker(trackerId : String) -> String {
        var retValue = ""
        let user = self.auth.currentUser
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
