//
//  MainView.swift
//  Open Camp
//
//  Created by Nick Herzig on 2/27/23.
//

import SwiftUI

struct MainView: View {
    init() {
          UITabBar.appearance().barTintColor = UIColor(Color("White"))
          UITabBar.appearance().backgroundColor = UIColor(Color("SecondaryColor"))
       }
    
    var body: some View {
        
            TabView {
                CampsiteTrackingView()
                    .tabItem {
                        Image(systemName: "triangle.lefthalf.filled")
                        Text("Sites")
                        .foregroundColor(.white)
                    }
                AddTrackerView()
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
