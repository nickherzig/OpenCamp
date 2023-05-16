//
//  CampsiteTrackingView.swift
//  Open Camp
//
//  Created by Nick Herzig on 2/27/23.
//

import SwiftUI

struct CampsiteTrackingView: View {
    @ObservedObject var campgroundModel: CampgroundHandler
    @ObservedObject var firebaseModel: FirebaseHandler
    
    
    init (campgroundModel: CampgroundHandler, firebaseModel: FirebaseHandler){
        self.campgroundModel = campgroundModel
        self.firebaseModel = firebaseModel
        firebaseModel.getTrackers(isActive: true)
    }
    
    var body: some View {
        if (firebaseModel.auth.currentUser == nil){
            ContentView()
        }
        else{
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                
                VStack{
                    Text("Currently Tracking")
                        .foregroundColor(.white)
                        .frame(width: 350, alignment: .topLeading)
                        .padding()
                    if (firebaseModel.userActiveTrackers.isEmpty && firebaseModel.isVerified()){
                        Text("You are not currently tracking any campsites")
                            .font(.system(size:15))
                            .frame(width: 300, height: 60, alignment: .center)
                            .font(.system(size: 20, weight: .bold))
                            .background(Color("SecondaryColor"), in: RoundedRectangle(cornerRadius: 20))
                            .multilineTextAlignment(.center)
                    }
                    if (!firebaseModel.isVerified()){
                        Text("You must verify your email to create and view trackers. Visit account page to resend email")
                            .font(.system(size:15))
                            .frame(width: 320, height: 80, alignment: .center)
                            .font(.system(size: 20, weight: .bold))
                            .background(Color("SecondaryColor"), in: RoundedRectangle(cornerRadius: 20))
                            .multilineTextAlignment(.center)
                    }
                        
                    List(firebaseModel.userActiveTrackers, id:\.id){ tracker in
                        NavigationLink(destination: ViewTracker(tracker: tracker, firebaseModel: firebaseModel)){
                            VStack{
                                Text(tracker.campground.name)
                                    .font(.system(size:15))
                                    .foregroundColor(.white)
                                    .frame(width: 300, height: 40)
                                    .font(.system(size: 20, weight: .bold))
                                    .background(Color(.black), in: RoundedRectangle(cornerRadius: 20))
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
                        }
                        .listRowBackground(
                            RoundedRectangle(cornerRadius: 20)
                                .background(.clear)
                                .foregroundColor(Color("SecondaryColor"))
                                .padding(
                                    EdgeInsets(
                                        top: 5,
                                        leading: 10,
                                        bottom: 5,
                                        trailing: 10
                                    )
                                )
                        )
                        .listRowSeparator(.hidden).frame(height: 75)
                        .padding()
                    }
                    .environment(\.defaultMinListRowHeight, 100)
                    .listRowSeparator(.hidden)
                    .scrollContentBackground(.hidden)
                    Spacer()
                }
            }
            .onAppear{
                firebaseModel.reloadUser()
            }
        }
        
    }
}

struct CampsiteTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        let campgroundModel = CampgroundHandler()
        let firebaseModel = FirebaseHandler()
        CampsiteTrackingView(campgroundModel: campgroundModel, firebaseModel: firebaseModel)
    }
}
