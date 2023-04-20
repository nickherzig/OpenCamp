//
//  CampgroundModels.swift
//  Open Camp
//
//  Created by Nick Herzig on 2/28/23.
//

import SwiftUI

struct Campground: Codable, Identifiable {
    var name : String
    var id : String
    var city : String
    var state : String
    var recArea : String
    var recAreaId: String
    var description: String
    var photoUrl: String
}


struct CampgroundSearchJson: Decodable {
    let RECDATA: [CampsiteJson]
}

struct CampsiteJson: Decodable {
    let FacilityID : String
    let FacilityName: String
    let FacilityTypeDescription: String
    let ParentRecAreaID: String
    let Reservable : Bool
    let FacilityDescription : String
    let FACILITYADDRESS : [FacilityAddressJson]
    let RECAREA : [RecAreaJson]
    let MEDIA : [MediaJson]
}

struct MediaJson : Decodable {
    let Height : Int
    let IsPrimary : Bool
    let MediaType : String
    let URL : String
    let Width : Int
}

struct RecAreaJson : Decodable {
    let RecAreaID: String
    let RecAreaName: String
}

struct FacilityAddressJson: Decodable {
    let AddressStateCode: String
    let City: String
}


class CampgroundHandler: ObservableObject {
    let API_KEY = "841cc0f8-f2ed-4f57-8b54-49fcaa992a9d"
    let defaultSession = URLSession(configuration: .default)
    
    var currentRecDataSearch : CampgroundSearchJson?;
    @Published var searchedCampgrounds: [Campground] = []
    
    //returns a request object from a given URL
    func makeRequest(url : String) -> URLRequest{
        let ridbURL = URL(string: url)!
        var request = URLRequest(url: ridbURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue(API_KEY, forHTTPHeaderField: "apikey")
        
        return request
    }
    
    
    //Sends a GET request to the REC.gov API for all campgrounds by a given search query
    func getCampgroundsRequest(query : String, callbackHandler : @escaping () -> Void){
        let urlString : String = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let request = makeRequest(url: "https://ridb.recreation.gov/api/v1/facilities?query=" + urlString + "&limit=20&offset=0&full=true&activity=CAMPING")
        
        let task = defaultSession.dataTask(with: request, completionHandler: {data, response, error -> Void in
            if error != nil {
                return
            }
            guard let data = data else { return }
            let recData : CampgroundSearchJson = try! JSONDecoder().decode(CampgroundSearchJson.self, from: data)
            DispatchQueue.main.async {
                self.currentRecDataSearch = recData
                callbackHandler()
            }
            
        })
        task.resume()
    }
    
    //Turns a CampgroundJson Object into a preferred Campground object
    func makeCamground(camp : CampsiteJson) -> Campground {
        var newCampground = Campground(
            name : camp.FacilityName.uppercased(),
            id : camp.FacilityID,
            city : "",
            state : "",
            recArea : "",
            recAreaId: "",
            description: camp.FacilityDescription,
            photoUrl: ""
        )
        if (!camp.FACILITYADDRESS.isEmpty) {
            newCampground.city = camp.FACILITYADDRESS[0].City
            newCampground.state = camp.FACILITYADDRESS[0].AddressStateCode
        }
        if (!camp.RECAREA.isEmpty){
            newCampground.recArea = camp.RECAREA[0].RecAreaName
            newCampground.recAreaId = camp.RECAREA[0].RecAreaID
        }
        
        // Adds photo urls to campground object
        for media in camp.MEDIA {
            if media.MediaType == "Image" && media.IsPrimary == true{
                newCampground.photoUrl = media.URL
                break
            }
        }
        return newCampground
    }
    
    func orderCampgrounds(query : String, campgrounds : [Campground]){
        let query = query.uppercased()
        self.searchedCampgrounds = campgrounds.sorted{
            if $0.name.contains(query) && !$1.name.contains(query){
                return true
            }
            else if !$0.name.contains(query) && $1.name.contains(query){
                return false
            }
            else if $0.recArea.uppercased().contains(query) && !$1.recArea.uppercased().contains(query){
                return true
            }
            else if !$0.recArea.uppercased().contains(query) && $1.recArea.uppercased().contains(query){
                return false
            }
            else if $0.city.uppercased().contains(query) && !$1.city.uppercased().contains(query){
                return true
            }
            else if !$0.city.uppercased().contains(query) && $1.city.uppercased().contains(query){
                return false
            }
            return true
        }.map { $0 }
    }
    
    //Executes a search for campgrounds. Puts all campground objects into the searchedCampground object
    func getCampgroundsSearch(query : String){
        var searchedCampgroundsPh : [Campground] = []
        if query.isEmpty {
            self.searchedCampgrounds = []
            return
        }
        
        //Calls getCampgroundRequest, waits for completion, then runs closure
        getCampgroundsRequest(query: query) {
            self.currentRecDataSearch?.RECDATA.forEach { camp in
                if camp.FacilityTypeDescription == "Campground" && camp.Reservable == true{
                    searchedCampgroundsPh.append(self.makeCamground(camp: camp))
                }
                //            if (!cg.recArea.isEmpty && !cg.state.isEmpty){
            }
            self.orderCampgrounds(query: query, campgrounds: searchedCampgroundsPh)
        }
        
    }
}




//
//searchedCampgrounds.append(campground2)
//searchedCampgrounds.append(campground1)
//searchedCampgrounds.append(campground3)
