//
//  ViewTracker.swift
//  Open Camp
//
//  Created by Nick Herzig on 4/5/23.
//

import SwiftUI

struct ViewTracker: View {
    let tracker : Tracker
    @ObservedObject var firebaseModel: FirebaseHandler
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.openURL) var openURL
    @State var errorMessage = ""
    
    func deleteTracker(){
        let err = firebaseModel.deleteTracker(trackerId: tracker.id!)
        if err.isEmpty{
            //updates the currently tracking page
            firebaseModel.getTrackers(isActive: 1)
            //returns to AddTrackerView
            self.presentationMode.wrappedValue.dismiss()
        }
        else{
            errorMessage = "Unable to delete tracker. Try again later."
        }
    }
    
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            VStack{
                Group{
                    Text("Campground:")
                        .foregroundColor(.white)
                        .frame(width: 350, alignment: .topLeading)
                        .padding()
                    Text(tracker.campground.name)
                        .foregroundColor(.black)
                        .frame(width: 350, height: 40)
                        .font(.system(size: 20, weight: .bold))
                        .background(Color("SecondaryColor"), in: RoundedRectangle(cornerRadius: 20))
                    
                    //Makes an async call to get image from url (IOS 15 and above)
                    AsyncImage(url: URL(string: tracker.campground.photoUrl)) { image in
                            image.resizable().cornerRadius(20)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 330, height: 250)
                    
                    Text("Details:")
                        .foregroundColor(.white)
                        .frame(width: 350, alignment: .topLeading)
                    VStack{
                        Text(tracker.campground.recArea + " " + tracker.campground.state)
                            .font(.system(size:13))
                            .frame(width: 300, height: 10)
                        Text("\(tracker.startDate.formatted(date: .complete, time: .omitted))")
                            .font(.system(size:13))
                            .frame(width: 300, height: 10)
                        Text("Nights: \(tracker.numNights)")
                            .font(.system(size:13))
                            .frame(width: 300, height: 10)
                    }
                    
                    .foregroundColor(.black)
                    .frame(width: 350, height: 80)
                    .font(.system(size: 20, weight: .bold))
                    .background(Color("SecondaryColor"), in: RoundedRectangle(cornerRadius: 20))
                    .padding()
                }
                Spacer()
                VStack{
                    Link("Visit Recreation.gov for more info", destination: URL(string: "https://www.recreation.gov/camping/campgrounds/" + tracker.campground.id)!)
                        .foregroundColor(.white)
                        .frame(width: 350, height: 60)
                        .font(.system(size: 20, weight: .bold))
                        .background(Color("ButtonBlue"), in: RoundedRectangle(cornerRadius: 20))
                        .padding()
                    Divider()
                    Button{
                        deleteTracker()
                    } label: {
                        Text("Delete Tracker")
                    }
                    .foregroundColor(.white)
                    .frame(width: 350, height: 60)
                    .font(.system(size: 20, weight: .bold))
                    .background(Color("DeleteRed"), in: RoundedRectangle(cornerRadius: 20))
                    .padding()
                    Text(errorMessage)
                    .frame(alignment: .center)
                    .foregroundColor(.white)
                    .font(.system(size:11))
                    .multilineTextAlignment(.center)
                    .padding()
                }
                
                .background(Color("SecondaryColor"))
                .ignoresSafeArea()
                .offset(y: 20)
                
            }
        }
    }
}

struct ViewTracker_Previews: PreviewProvider {
    static var previews: some View {
        let campground : Campground = Campground(name: "Plaskett Creek Campground", id: "0",  city: "Big Sur", state: "CA", recArea: "Los Padres National Forest", recAreaId: "!", description: "poo", photoUrl:
            "https://cdn.recreation.gov/public/2018/12/08/16/43/251537_4a120aea-c664-4fe5-8fbb-e75d7532bfe2_700.jpg")
        let tracker : Tracker = Tracker(campground: campground, userEmail: "jimmy", userId: "123", startDate: Date(), numNights: 2, active: true, success: false)
        let firebaseModel = FirebaseHandler()
        ViewTracker(tracker: tracker, firebaseModel: firebaseModel)
    }
}
