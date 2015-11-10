
//
//  BuildingsData.swift
//  Whirlpool-iOS
//
//  Created by Gregory Richard on 11/7/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation

protocol buildingsLoadedDelegate {
    func buildingAbbsHaveBeenLoaded()
    func buildingInfoHasBeenLoaded()
}

class BuildingsData {
    var _buildings = [Building]()
    var _buildingAbbr = [String]()
    var _amountOfBuildings: Int?
    var _buildingDelegate: buildingsLoadedDelegate? = nil
    let BUILDINGS_URL = "https://whirlpool-indoor-maps.appspot.com/buildings"
    let BUILDING_URL =  "https://whirlpool-indoor-maps.appspot.com/building?building_name="
    
    //This init is used just to populate the abbreviations of buildings
    init(delegate: buildingsLoadedDelegate){
        _buildingDelegate = delegate
        request(BUILDINGS_URL) { (response) -> Void in
            self._amountOfBuildings = response["count"] as? Int
            self.parseOutBuildingInfo(response)
            self._buildingDelegate?.buildingAbbsHaveBeenLoaded()
        }
    }
    
    //This init is used to grab data for a building by abbreviation, checks abbreviation passed in after gettting proper abbreviations from database
    init(delegate: buildingsLoadedDelegate, buildingAbb: String){
        _buildingDelegate = delegate
        request(BUILDINGS_URL) { (response) -> Void in
            self._amountOfBuildings = response["count"] as? Int
            self.parseOutBuildingInfo(response)
            self._buildingDelegate?.buildingAbbsHaveBeenLoaded()
            if self._buildingAbbr.contains(buildingAbb) {
                self.request(self.BUILDING_URL+buildingAbb) { (response) -> Void in
                    self.addBuildingToArrayFromDB(response)
                    //call the protocol func here thats implimented in your class that you wanted
                    //This tell the class that the building objects are done being populated
                    self._buildingDelegate?.buildingInfoHasBeenLoaded()
                }
            }
        }
    }
    
    func request( destination : String, successHandler: (response: [String: AnyObject]) -> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: destination as String)!)
        request.HTTPMethod = "GET"
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments)  as? [String: AnyObject]{
                    successHandler(response: jsonResult as [String: AnyObject])
                }
            } catch let parseError {
                print(parseError)
            }
        }
        task.resume()
    }

    //creates a building object to with data from the database
    func createBuilding(buildingName: String, buildingAbbreviation: String,  numberOfFloors: Int, numberOfWings: Int ) ->Building{
        let building = Building(buildingName: buildingName, buildingAbbr: buildingAbbreviation, numberOfFloors: numberOfFloors, numberOfWings: numberOfWings)
        return building
    }
    
    func parseOutBuildingInfo(buildingInfo: [String:AnyObject]){
        let buildingList = buildingInfo["building_names"] as! [[String]]
        for var i = 0 ; i < buildingInfo["count"] as! Int; i++ {
            request(BUILDINGS_URL+buildingList[i][1], successHandler: { (response) -> Void in
                self.addBuildingToArrayFromDB(response)
            })
            _buildingAbbr.append(buildingList[i][1])
        }
    }
    
    //Use this function for when the building is done being pulled to store its info to an array after creating a building object.
    func addBuildingToArrayFromDB(buildingInfo: [String: AnyObject]){
        print(buildingInfo)
        //Parse the building info here
        //Call createBuilding and the returned building add to the array. (_buildings)
    }
}