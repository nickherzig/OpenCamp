//
//  AccountView.swift
//  Open Camp
//
//  Created by Nick Herzig on 2/27/23.
//

import SwiftUI

struct AccountView: View {
    @ObservedObject var firebaseModel: FirebaseHandler
    @State var verificationSent : Bool = false
    @State var logoutError = ""
    @State var loggedOut = false
    
    init (firebaseModel: FirebaseHandler){
        self.firebaseModel = firebaseModel
        firebaseModel.getTrackers(isActive: false)
        firebaseModel.reloadUser()
    }
    
    func logout(){
        let loggedOut = firebaseModel.logout()
        if (loggedOut) {
            self.loggedOut = true
        }
        else{
            self.logoutError = "Unable to logout. Try again later."
        }
    }
    
    var body: some View {
        if (loggedOut){
            ContentView()
        }
        else{
            ZStack {
                Color("BackgroundColor")
                    .ignoresSafeArea()
                VStack{
                    Group{
                        Text("Email")
                            .foregroundColor(.white)
                            .frame(width: 350, alignment: .topLeading)
                            .padding()
                        Text(firebaseModel.auth.currentUser?.email ?? "email")
                            .foregroundColor(.black)
                            .frame(width: 350, height: 40)
                            .font(.system(size: 20, weight: .bold))
                            .background(Color("SecondaryColor"), in: RoundedRectangle(cornerRadius: 20))
                        if (!firebaseModel.isVerified() && !verificationSent){
                            Button {
                                firebaseModel.sendEmailVerification()
                                verificationSent = true
                            } label: {
                                Text("This email has not been verified.\nClick me to resend verification.")
                            }
                            .buttonStyle(BorderedProminentButtonStyle())
                            .font(.system(size: 15))
                            .foregroundColor(.white)
                            .frame(width: 300, height: 60)
                        }
                        if (verificationSent){
                            Text("Verification sent, please check email.")
                                .foregroundColor(.white)
                                .frame(width: 350)
                        }
                        Text("Member Since")
                            .foregroundColor(.white)
                            .frame(width: 350, alignment: .topLeading)
                            .padding()
                        Text(firebaseModel.auth.currentUser?.metadata.creationDate?.formatted(date: .complete, time: .omitted) ?? "date")
                            .foregroundColor(.black)
                            .frame(width: 350, height: 40)
                            .font(.system(size: 20, weight: .bold))
                            .background(Color("SecondaryColor"), in: RoundedRectangle(cornerRadius: 20))
                    }
                    
                    
                    
                    Text("Past Trackers")
                        .foregroundColor(.white)
                        .frame(width: 350, alignment: .topLeading)
                        .padding()
                    if (firebaseModel.userInactiveTrackers.isEmpty){
                        Text("You have no past trackers")
                            .font(.system(size:15))
                            .frame(width: 300, height: 60, alignment: .center)
                            .font(.system(size: 20, weight: .bold))
                            .background(Color("SecondaryColor"), in: RoundedRectangle(cornerRadius: 20))
                            .multilineTextAlignment(.center)
                    }
                    List(firebaseModel.userInactiveTrackers, id:\.id){ tracker in
                        NavigationLink(destination: CreateTracker(campground: tracker.campground, firebaseModel: firebaseModel))
                        {
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
                                Text("Success: \(tracker.success.description)")
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
                    
                    Button{
                        //logout
                        logout()
                    } label: {
                        Text("Log out")
                    }
                    .foregroundColor(.white)
                    .frame(width: 250, height: 60)
                    .font(.system(size: 20, weight: .bold))
                    .background(Color("DeleteRed"), in: RoundedRectangle(cornerRadius: 20))
                    .padding()
                    
                    Text(logoutError)
                        .frame(alignment: .center)
                        .foregroundColor(.white)
                        .font(.system(size:11))
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .onAppear{
                self.verificationSent = false
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        let firebaseModel = FirebaseHandler()
        AccountView(firebaseModel: firebaseModel)
    }
}
