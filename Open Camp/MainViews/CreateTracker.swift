//
//  CreateTracker.swift
//  Open Camp
//  UI to create a new tracker on a selected campsite
//
//  Created by Nick Herzig on 3/9/23.
//

import SwiftUI

struct CreateTracker: View {
    let campground : Campground
    @ObservedObject var firebaseModel: FirebaseHandler
    @State private var date : Date = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
    @State private var numNights : Int = 1
    @State private var errorMessage = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    
    // Starting and finishing date (six months in advance) for date picker
    let startingDate: Date = Date()
    let endingDate = Date().addingTimeInterval(15780000)
    
    //accesses firebase firstone to add a tracker
    func addTracker(){
        let dateCorrected = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: date)!
        let id = firebaseModel.addTracker(campground: campground, date: dateCorrected, numNights: numNights)
        if id.isEmpty{
            errorMessage = "Unable to add tracker. Try again later."
        }
        else if id == "max_trackers"{
            errorMessage = "You have reached the max number of trackers"
        }
        else if id == "duplicate_tracker"{
            errorMessage = "You already have a tracker with these specifications"
        }
        else if id == "not_verified"{
            errorMessage = "You must verify your email before you can make a tracker"
        }
        
        else{
            print("Tracker ID: " + id)
            //updates the currently tracking page
            firebaseModel.getTrackers(isActive: true)
            //returns to AddTrackerView
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    var body: some View {
        
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            VStack{
                Text("Create campsite tracker for:")
                    .foregroundColor(.white)
                    .frame(width: 350, alignment: .topLeading)
                    .padding()
                Text(campground.name)
                    .foregroundColor(.black)
                    .frame(width: 350, height: 40)
                    .font(.system(size: 20, weight: .bold))
                    .background(Color("SecondaryColor"), in: RoundedRectangle(cornerRadius: 20))
                Text("Start date:")
                    .foregroundColor(.white)
                    .frame(width: 350, alignment: .topLeading)
                    .padding()
                DatePicker("Start Date", selection: $date, in: startingDate...endingDate, displayedComponents: [.date])
                    .frame(width: 350, alignment: .topLeading)
                    .datePickerStyle(.graphical)
                    .background(Color("SecondaryColor"), in: RoundedRectangle(cornerRadius: 20))
                Text("Number of nights:")
                    .foregroundColor(.white)
                    .frame(width: 350, alignment: .topLeading)
                    .padding()
                Picker("Nights", selection: $numNights) {
                    ForEach(1...6, id: \.self) {
                        Text("\($0)")
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .background(Color("SecondaryColor"), in: RoundedRectangle(cornerRadius: 20))
                .frame(width: 350, height: 80)
                Button {
                    addTracker()
                } label: {
                    Text("Submit")
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .frame(width: 200, height: 0)
                .offset(y: 20)
                .padding()
                
                Text(errorMessage)
                .frame(alignment: .center)
                .foregroundColor(.white)
                .font(.system(size:11))
                .multilineTextAlignment(.center)
                .padding()
                Spacer()
            }
        }
    }
}

struct CreateTracker_Previews: PreviewProvider {
    static var previews: some View {
        let campground : Campground = Campground(name: "Plaskett Creek Campground", id: "0",  city: "Big Sur", state: "CA", recArea: "Los Padres National Forest", recAreaId: "!", description: "poo", photoUrl: "https://cdn.recreation.gov/public/2018/12/08/16/43/251537_4a120aea-c664-4fe5-8fbb-e75d7532bfe2_700.jpg")
        let firebaseModel = FirebaseHandler()
        CreateTracker(campground: campground, firebaseModel: firebaseModel)
    }
}
