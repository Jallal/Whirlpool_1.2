
//
//  BuildingsData.swift
//  Whirlpool-iOS
//
//  Created by Gregory Richard on 11/7/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation
import GoogleMaps

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
        print("&&&&&&&&&&&&&&&&&&&&&BUILDING INFO &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
        print(buildingInfo)
    
        //Parse the building info here
        //Call createBuilding and the returned building add to the array. (_buildings)
    }
    
    
    
    
    
      // Possible errors from parsing JSON
    enum JSONError: String, ErrorType {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    
    
    
     /* This function get all the floors with their rooms in a particular building @Param : building Id*/
    func GetAllFloorsInBuilding(building_id : String) -> Building{
        var FloorCount = 0
        var building = Building(buildingName: building_id, buildingAbbr: building_id, numberOfFloors: 3, numberOfWings: 0)

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
           
            let urlPath = "https://whirlpool-indoor-maps.appspot.com/blobstore/ops?building_name=\(building_id)"
            guard let endpoint = NSURL(string: urlPath) else { print("Error creating endpoint");return }
            let request = NSMutableURLRequest(URL:endpoint)
            NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
                do {
                    if let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                        
                        if let features = jsonDict["floors"] as? [[String: AnyObject]]{
                            
                            for da in  features{
                                var floorNumber : Int = Int()
                                if let floorN = da["floor_num"] as? String{
                                    if let myNumber = NSNumberFormatter().numberFromString(floorN) {
                                        floorNumber  = myNumber.integerValue
                                        FloorCount++
                                    }
                                }
                                
                                if let cap = da["geojson"] as? NSString{
                                    let file = "file.json"
                                    let text = cap
                                    if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                                        let path = dir.stringByAppendingPathComponent(file);
                                        
                                        //writing
                                        do {
                                            try text.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
                                        }
                                        catch {
                                           print("GeoJSON parsing failed")
                                        }
                                        
                                        //reading
                                        do {
                                            let Floor  = FloorData()
                                            let AllRoomsInFloor  = self.GetAllTheRoomsForAbuilding(path,Building_id: building_id)
                                            Floor.AddRoomsToFloor(floorNumber,rooms:AllRoomsInFloor)
                                            building.appendFloor(Floor)
                                            building.SetNumberOfFloors(FloorCount)
                                        }
                                        catch {
                                             print("GeoJSON parsing failed")
                                        }
                                    }
                                    
                                    
                                }
                                
                            }
                            
                            
                            
                        }
                    
                    }
                   
                   
                } catch let error as NSError {
                    
                } catch {
                    print(error)
                }
                
                }.resume()
        })
        return building
    }
    
    
    
    /* This function will get all the rooms in a floor of a building requires the building id and the file path*/

    func GetAllTheRoomsForAbuilding(jsonPath : String,Building_id : String) -> RoomsData {
        // Parsing GeoJSON can be CPU intensive, do it on a background thread
        //var Building_id : String =  "RV"
           let roomsdata = RoomsData()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            // Get the path for example.geojson in the app's bundle
            
            //let jsonPath = NSBundle.mainBundle().pathForResource(filename, ofType: "json")
            let jsonData = NSData(contentsOfFile: jsonPath)
            
            do {
                
                // Load and serialize the GeoJSON into a dictionary filled with properly-typed objects
             
                if let jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: []) as? NSDictionary {
                    
                    // Load the `features` array for iteration
                    if let features = jsonDict["features"] as? NSArray {
                        
                        for feature in features {
                            let CurrentRoom = RoomData();
                            if let feature = feature as? NSDictionary {
                                if let  property = feature["properties"] as? NSDictionary {
                                    
                                    if let roomNum = property["room"]{
                                        CurrentRoom.SetRoomName(roomNum as! String)
                                        
                                    }
                                    
                                }
                                if let geometry = feature["geometry"] as? NSDictionary {
                                    
                                    
                                    if geometry["type"] as? String == "Polygon" {
                                        
                                        // Create an array to hold the formatted coordinates for our line
                                        
                                        //var coordinates: [CLLocationCoordinate2D] = []
                                        
                                        if let locations = geometry["coordinates"] as? NSArray {
                                            
                                            // Iterate over line coordinates, stored in GeoJSON as many lng, lat arrays
                                            var maxX : double_t = -400
                                            var maxY : double_t = -400
                                            var minX : double_t = 400
                                            var minY : double_t = 400
                                            
                                            for location in locations {
                                                let rec = GMSMutablePath()
                                                
                                                for var i = 0; i < location.count; i++ {
                                                    var lat = 0 as Double
                                                    for var j = 0; j < location[i].count; j++ {
                                                        
                                                        if (j+1 == location[i].count){
                                                            rec.addCoordinate(CLLocationCoordinate2DMake(location[i][j].doubleValue,lat))
                                                            if(maxX < location[i][j].doubleValue){
                                                                maxX = location[i][j].doubleValue
                                                            }
                                                            if(maxY < lat){
                                                                maxY = lat
                                                            }
                                                            if(minX > location[i][j].doubleValue){
                                                                minX = location[i][j].doubleValue
                                                            }
                                                            if(minY > lat){
                                                                minY = lat
                                                            }
                                                            
                                                        }
                                                        else{
                                                            lat = location[i][j].doubleValue
                                                            if(maxY <  lat){
                                                                maxY = lat
                                                            }
                                                            if(minY >  lat){
                                                                minY = lat
                                                            }
                                                            
                                                        }
                                                    }
                                                    
                                                    
                                                }
                                                CurrentRoom.SetroomCenter((minX+maxX)/2, y: ((minY+maxY)/2))
                                                CurrentRoom.SetRoomCoordinates(rec)
                                            }
                                            
                                            
                                        }
                                        
                                        
                                    }
                                }
                            }
                            roomsdata.updateRoomsInfo(Building_id,room_name: CurrentRoom.GetRoomName(),RoomInformation: CurrentRoom )
                           roomsdata.addARoom(CurrentRoom)
                           
                            
                        }
                    }
                }
             
            }
                
                
            catch
                
            {
                
                print("GeoJSON parsing failed")
                
            }
            
        })
        return roomsdata
    }
    
    public func getBuildingByName(name : String) -> Building {

        for build in _build{
            if(build._buildingAbbr==name){
                return build
            }
        }
        return Building(buildingName: "", buildingAbbr: "", numberOfFloors: 0, numberOfWings: 0)
        
    }
    

    
    
}
