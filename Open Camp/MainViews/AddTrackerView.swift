//
//  AddTrackerView.swift
//  Open Camp
//
//  Created by Nick Herzig on 2/27/23.
//

import SwiftUI

struct AddTrackerView: View {
    @State private var campgroundSearch = ""
    @ObservedObject var campgroundModel: CampgroundHandler
    @ObservedObject var firebaseModel: FirebaseHandler
    @State private var campgrounds : [Campground] = []
    @State private var loading = false;
    
    func callGetCampgrounds(){
        loading = true
        campgroundModel.getCampgroundsSearch(query: campgroundSearch)
        loading = false
    }
    
    var body: some View {
        ZStack {
            Color("BackgroundColor")
                .ignoresSafeArea()
            VStack{
                Text("Add Campground")
                    .foregroundColor(.white)
                    .frame(width: 350, alignment: .topLeading)
                    .padding()
                TextField(
                    "Search for campground",
                    text: $campgroundSearch,
                    onCommit: {
                        callGetCampgrounds()
                    })
                .padding()
                .frame(width: 350, height: 50)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .background(
                    RoundedRectangle(cornerRadius: 20)
                )
                Button {
                    callGetCampgrounds()
                } label: {
                    Text("Submit")
                }
                .buttonStyle(BorderedProminentButtonStyle())
                .frame(width: 200, height: 0)
                .padding()
                
                if loading{
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                        .foregroundColor(.black)
                        .frame(width: 100, height: 100)
                }
                
                List(campgroundModel.searchedCampgrounds, id:\.id){ campground in
                    NavigationLink(destination: CreateTracker(campground: campground, firebaseModel: firebaseModel)){
                        VStack{
                            Text(campground.name)
                                .font(.system(size:15))
                                .frame(width: 300, height: 10)
                            Text(campground.recArea + " " + campground.state)
                                .font(.system(size:14))
                                .frame(width: 300, height: 10)
                        }
                    }
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 20)
                            .background(.clear)
                            .foregroundColor(Color("SecondaryColor"))
                            .padding(
                                EdgeInsets(
                                    top: 15,
                                    leading: 10,
                                    bottom: 15,
                                    trailing: 10
                                )
                            )
                    )
                    .listRowSeparator(.hidden).frame(height: 75)
                }
                .environment(\.defaultMinListRowHeight, 10)
                .listRowSeparator(.hidden)
                .scrollContentBackground(.hidden)
                
                Spacer()
            }
        }
    }
}

struct AddTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        let campgroundModel = CampgroundHandler()
        let firebaseModel = FirebaseHandler()
        AddTrackerView(campgroundModel: campgroundModel, firebaseModel: firebaseModel)
        
    }
}
