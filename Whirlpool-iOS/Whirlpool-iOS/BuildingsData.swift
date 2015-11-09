
//
//  BuildingsData.swift
//  Whirlpool-iOS
//
//  Created by Gregory Richard on 11/7/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation

protocol buildingsLoadedDelegate {
    func buildingsHaveBeenLoaded()
}

class BuildingsData {
    var _buildingNames = [Building]()
    var _buildingAbbr = [String]()
    var _amountOfBuildings: Int?
    var buildingDelegate: buildingsLoadedDelegate? = nil
    let BUILDINGS_URL = "https://whirlpool-indoor-maps.appspot.com/buildings"
    let BUILDING_URL =  "https://whirlpool-indoor-maps.appspot.com/building?building_name="
    
    init(delegate: buildingsLoadedDelegate){
        //fillBuildingData()
        buildingDelegate = delegate
        request(BUILDINGS_URL) { (response) -> Void in
            self._amountOfBuildings = response["count"] as? Int
            self.parseOutBuildingInfo(response)
            self.buildingDelegate?.buildingsHaveBeenLoaded()
        }
    }
    
//    //method to fetch all the whirlpool building names and abbreviations
//    func fillBuildingData(){
//        let url = NSURL(string: BUILDINGS_URL)
//        let request = NSMutableURLRequest(URL: url!)
//        request.HTTPMethod = "GET"
//        let jsonData = NSMutableData()
//        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (response:NSURLResponse?, data: NSData?, error:NSError?) -> Void in
//            if data != nil {
//                jsonData.appendData(data!)
//                do {
//                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])  as? [String: AnyObject]{
//                        self.parseOutBuildingInfo(jsonResult)
//                    }
//                } catch let parseError {
//                    print(parseError)
//                }
//            }
//            else {
//                print(error)
//            }
//        }
//    }

//    //function to fetch all the attributes associated with a whirlpool building
//    func setupBuildingProperties(buildingAbb: String){
//        let url = NSURL(string:  BUILDING_URL + buildingAbb)
//        let request = NSMutableURLRequest(URL: url!)
//        request.HTTPMethod = "GET"
//        let jsonData = NSMutableData()
//        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (response:NSURLResponse?, data: NSData?, error:NSError?) -> Void in
//            if data != nil {
//                jsonData.appendData(data!)
//                do {
//                    if let jsonResult = try NSJSONSerialization.JSONObjectWithData(jsonData, options: [])  as? [String: AnyObject]{
//                        self.addBuildingToArrayFromDB(jsonResult)
//                    }
//                } catch let parseError {
//                    print(parseError)
//                }
//            }
//            else {
//                print(error)
//            }
//        }
//    }
    
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
    
    func addBuildingToArrayFromDB(buildingInfo: [String: AnyObject]){
        print(buildingInfo)
    }
}