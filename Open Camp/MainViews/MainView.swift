//
//  MainView.swift
//  Open Camp
//
//  Created by Nick Herzig on 2/27/23.
//

import SwiftUI

struct MainView: View {
    let campgroundModel = CampgroundHandler()
    let firebaseModel = FirebaseHandler()
    init() {
        UITabBar.appearance().barTintColor = UIColor(Color(.white))
          UITabBar.appearance().backgroundColor = UIColor(Color("SecondaryColor"))
        
       }
    
    var body: some View {
            TabView {
                CampsiteTrackingView(campgroundModel: campgroundModel, firebaseModel: firebaseModel)
                    .tabItem {
                        Image(systemName: "triangle.lefthalf.filled")
                        Text("Sites")
                        .foregroundColor(.white)
                    }
                AddTrackerView(campgroundModel: campgroundModel, firebaseModel: firebaseModel)
                    .tabItem {
                        Image(systemName: "plus")
                        Text("Add")
                    }
                AccountView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Account")
                    }
            }
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
