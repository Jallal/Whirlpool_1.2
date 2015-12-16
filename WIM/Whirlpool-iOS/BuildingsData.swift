
//
//  BuildingsData.swift
//  Whirlpool-iOS
//
//  Created by Gregory Richard on 11/7/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation
import GoogleMaps
import SwiftyJSON
import CoreData

protocol buildingsLoadedDelegate {
    func buildingAbbsHaveBeenLoaded()
    func buildingInfoHasBeenLoaded()
    func buildingUpdated()
}

class BuildingsData: buildingsUpdatedDelagate{
    var _buildings = [String:Building]()
    var _buildingAbbr = [String]()
    var _amountOfBuildings: Int?
    var _buildingAbb:String?
    var _buildingDelegate: buildingsLoadedDelegate? = nil
    var _timeStamp = Double()
    var (_elvCount, _mbCount, _wbCount, _strCount, _hwCount, _uxCount, _extCount) = (Int(),Int(),Int(),Int(),Int(),Int(),Int())
    var (_maxX, _maxY, _minX, _minY) = (Double(),Double(),Double(),Double())
    let BUILDINGS_URL = "https://whirlpool-indoor-maps.appspot.com/buildings"
    let BUILDING_URL =  "https://whirlpool-indoor-maps.appspot.com/building?building_name="
    let BUILDING_GEOJSON_URL = "https://whirlpool-indoor-maps.appspot.com/blobstore/ops?building_name="
    let BUILDING_GEOJSON_TIMESTAMP_URL = "https://whirlpool-indoor-maps.appspot.com/blobstore/ops?building_name="
    let BUILDING_INFO_ID = "building_info"
    let BUILDING_NAME_JSON_ID = "building_name" //This is actually an abbreviation
    let BUILDING_NAMES_JSON_ID = "building_names"
    let BUILDING_FLOORNUM_JSON_ID = "num_floors"
    let BUILDING_WINGNUM_JSON_ID =   "num_wings"
    let JSON_SUCCESS = "success"
    let JSON_COUNT = "count"
    let JSON_FEATURES = "features"
    let JSON_GEOM = "geometry"
    let JSON_COORD = "coordinates"
    let JSON_PROP = "properties"
    let JSON_ROOM = "room"
    let JSON_FLOORNUM = "floor_num"
    let JSON_FLOORS = "floors"
    let JSON_WING = "wing"
    let JSON_TYPE = "type"
    
    
    
    //This init is used just to populate the abbreviations of buildings
    init(delegate: buildingsLoadedDelegate){
        _buildingDelegate = delegate
        request(BUILDINGS_URL) { (response) -> Void in
            self._amountOfBuildings = response[self.JSON_COUNT].int!
            self.parseOutBuildingInfo(response)
            self._buildingDelegate?.buildingAbbsHaveBeenLoaded()
        }
    }
    
    func doneUpdating() {
        self._buildingDelegate?.buildingUpdated()
    }
    
    //This init is used to grab data for a building by abbreviation, checks abbreviation passed in after gettting proper abbreviations from database
    init(delegate: buildingsLoadedDelegate, buildingAbb: String){
        _buildingDelegate = delegate
        _buildingAbb = buildingAbb
        let url = BUILDING_GEOJSON_TIMESTAMP_URL + buildingAbb + "&time=true"
        request(url) { (response) -> Void in
            if self.parseBuildingTimeStamp(response){
                //do the next request
                print("in here, pull from online")
                self.request(self.BUILDINGS_URL) { (response) -> Void in  //Grab all building abbreviations
                    self._amountOfBuildings = response[self.JSON_COUNT].int
                    self.parseOutBuildingInfo(response)
                    self._buildingDelegate?.buildingAbbsHaveBeenLoaded()
                    if self._buildingAbbr.contains(buildingAbb) {
                        self.request(self.BUILDING_URL+buildingAbb) { (response) -> Void in //Grab the building data for the abbreviation
                            self.addBuildingToArrayFromDB(response)
                            self.request(self.BUILDING_GEOJSON_URL + buildingAbb) { (response) -> Void in   //Grab the Geojson for the floors in the building
                                if response["count"].int > 0 {
                                    self.writeGeoJsonToFile(response.rawString()!)
                                    self.parseBuildingData(response)
                                }
                                self._buildings[buildingAbb]?.UpdateBuildingsRoomStatus()
                                //call the protocol func here thats implimented in your class that you wanted
                                //This tell the class that the building objects are done being populated
                                self._buildingDelegate?.buildingInfoHasBeenLoaded()
                            }
                        }
                    }
                }
            }else{
                self.request(self.BUILDING_URL + buildingAbb, successHandler: { (response) -> Void in
                    //pull building data from local file
                    //print("pull from local")
                    let json = self.readGeoJsonFromFile()
                    self.addBuildingToArrayFromDB(response)
                    self.parseBuildingData(json)
                    self._buildings[buildingAbb]?.UpdateBuildingsRoomStatus()
                    self._buildingDelegate?.buildingInfoHasBeenLoaded()
                })
                
            }
        }
        
    }
    
    func writeGeoJsonToFile(buildingJson: String){
        let file = _buildingAbb! + ".json" //this is the file. we will write to and read from it
        
        let text = buildingJson
        
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = dir.stringByAppendingPathComponent(file);
            
            //writing
            do {
                try text.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
            }
            catch {/* error handling here */}
            
            let appDelagate = UIApplication.sharedApplication().delegate as! AppDelegate
            let managedContext = appDelagate.managedObjectContext
            
            
            var object: NSManagedObject?
            
            //2
            let fetchRequest = NSFetchRequest(entityName: "Timestamp_of_file")
            //3
            do {
                let results = try managedContext.executeFetchRequest(fetchRequest)
                let tempResults = results as! [NSManagedObject]
                if tempResults.count>0{
                    for x in 0...tempResults.count-1{
                        let tempBuildingName = tempResults[x].valueForKey("buildingName") as! String
                        if tempBuildingName == _buildingAbb {
                            object = tempResults[x]
                        }
                    }
                }
                
            } catch {
                print("Could not fetch")
            }
            if let obj = object{
                managedContext.deleteObject(object!)
            }
            
            let entity = NSEntityDescription.insertNewObjectForEntityForName("Timestamp_of_file", inManagedObjectContext: managedContext)
            entity.setValue(_timeStamp, forKey: "timestamp")
            entity.setValue(_buildingAbb, forKey: "buildingName")
            //4
            do {
                try managedContext.save()
            } catch let error as NSError  {
                print("Could not save \(error), \(error.userInfo)")
            }

            
        }
    }
    
    func readGeoJsonFromFile()->JSON{
        let file = _buildingAbb! + ".json" //this is the file. we will write to and read from it
        var text = String()
        var json: JSON?
        if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
            let path = dir.stringByAppendingPathComponent(file);
            
            //reading
            do {
                text = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
                let data = text.dataUsingEncoding(NSUTF8StringEncoding)! as NSData
                json = JSON(data: data, options: NSJSONReadingOptions.MutableContainers, error: nil)
            }
            catch {/* error handling here */}
        }
        return json!
    }

    func request( destination : String, successHandler: (response: JSON) -> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: destination as String)!)
        request.HTTPMethod = "GET"
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            do {
                let readableJSON = JSON(data: data!, options: NSJSONReadingOptions.MutableContainers, error: nil)
                successHandler(response: readableJSON)
            }
        }
        task.resume()
    }
    
    func parseBuildingTimeStamp(response: JSON)->Bool{
        let timeStamp = response["time"].doubleValue
        _timeStamp = timeStamp
        print(response)
        print(timeStamp)
        return checkLocalTimeStamp(_buildingAbb!, timestamp: timeStamp)
    }
    
    func checkLocalTimeStamp(buildingName: String,timestamp: Double)->Bool{
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "Timestamp_of_file")
        //3
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            let tempResults = results as! [NSManagedObject]
            if tempResults.count>0{
                for x in 0...tempResults.count-1{
                    let tempBuildingName = tempResults[x].valueForKey("buildingName") as! String
                    if tempBuildingName == buildingName {
                        let savedTime = tempResults[x].valueForKey("timestamp") as! Double
                        return (savedTime < timestamp) //true to pull new info
                    }
                }
            }
            
        } catch {
            print("Could not fetch")
        }
        //if not in the local sqllight
        return true
    }
    
    func parseOutBuildingInfo(buildingInfo: JSON){
        for var i = 0 ; i < buildingInfo[JSON_COUNT].int; i++ {
            _buildingAbbr.append(buildingInfo[BUILDING_NAMES_JSON_ID][i][1].string!)
        }
    }
    
    //Use this function for when the building is done being pulled to store its info to an array after creating a building object.
    func addBuildingToArrayFromDB(buildingInfo: JSON){
        //Parse the building info here
        //Call createBuilding and the returned building add to the array.
        if checkJsonResponseSuccess(buildingInfo) {
            let buildingInfoResponse = buildingInfo[BUILDING_INFO_ID]
            let buildingAbb = buildingInfoResponse[BUILDING_NAME_JSON_ID].stringValue
            let numberOfFloors = buildingInfoResponse[BUILDING_FLOORNUM_JSON_ID].intValue
            let numberOfWings = buildingInfoResponse[BUILDING_WINGNUM_JSON_ID].intValue
            let building = Building(buildingAbbr: buildingAbb, numberOfFloors: numberOfFloors, numberOfWings: numberOfWings, delg: self)
            _buildings[buildingAbb] = building
        }
    }
    
    func parseBuildingData(jsonBuildingAndFloorData: JSON){
        if checkJsonResponseSuccess(jsonBuildingAndFloorData) {
            let floorsInBuilidingResponseCount = jsonBuildingAndFloorData[JSON_COUNT].int!
            let buildingAbb = jsonBuildingAndFloorData[BUILDING_NAME_JSON_ID].string!
            for i in 0...(floorsInBuilidingResponseCount-1) {
                let floorNum = jsonBuildingAndFloorData[JSON_FLOORS][i][JSON_FLOORNUM].int!
                if let floorWing = jsonBuildingAndFloorData[JSON_FLOORS][i][JSON_WING].string {
                    setFloorOfBuilding(floorNum, floorWing: floorWing, jsonBuildingAndFloorData: jsonBuildingAndFloorData, buildingAbb: buildingAbb, iteration: i)
                } else {
                    setFloorOfBuilding(floorNum, floorWing: String(), jsonBuildingAndFloorData: jsonBuildingAndFloorData, buildingAbb: buildingAbb, iteration: i)                }
            }
        }
    }
    
    //This sets the floor to the proper building object and also calls parse through rooms to create rooms from the geojson
    func setFloorOfBuilding(floorNum: Int, floorWing: String, jsonBuildingAndFloorData: JSON, buildingAbb: String,iteration: Int){
        let floor = FloorData(floorNumber: floorNum, floorWing: floorWing)
        let floorsRooms = parseGeoJsonOfEachFloor(jsonBuildingAndFloorData[JSON_FLOORS][iteration], buildingAbb: buildingAbb, floorNum:floorNum)
        floor.setRooms(floorsRooms)
        _buildings[buildingAbb]?.appendFloor(floor)
    }
    
    //This is parsing out all the rooms and their coordinates and returning a list to add the rooms to the specific floor
    func parseGeoJsonOfEachFloor(jsonBuildingAndFloorData: JSON, buildingAbb: String, floorNum: Int)->[String : RoomData]{
        let strData = jsonBuildingAndFloorData["geojson"].string!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let geoJsonInfo = JSON(data: strData!, options: NSJSONReadingOptions.MutableContainers, error: nil)
        var floorsRooms = [String:RoomData]()
        for x in 0...(geoJsonInfo[JSON_FEATURES].count - 1) {
            let roomName = geoJsonInfo[JSON_FEATURES][x][JSON_PROP][JSON_ROOM].string
            var room = RoomData()
            if(roomName != nil){
            //self.updateRoomsInfo(buildingAbb, room_name: roomName!, RoomInformation: &room)
            let roomType = geoJsonInfo[JSON_FEATURES][x][JSON_GEOM][JSON_TYPE].string
            if roomType == "Polygon" {
                (_maxX, _maxY, _minX, _minY) = (-180.0,-90.0,180.0,90.0)
                room.SetRoomName(roomName!)
                 let rec = GMSMutablePath()
                for y in 0...(geoJsonInfo[JSON_FEATURES][x][JSON_GEOM][JSON_COORD][0].count - 1) {
                    let  lat = geoJsonInfo[JSON_FEATURES][x][JSON_GEOM][JSON_COORD][0][y][1].double!    // coordinates for room look like [[[long,lat],[long,lat]]]
                    let  long  = geoJsonInfo[JSON_FEATURES][x][JSON_GEOM][JSON_COORD][0][y][0].double!                    
                    determineMaxMin(lat,maxY: long, minX: lat, minY: long)
                    rec.addCoordinate(CLLocationCoordinate2D(latitude: lat,longitude: long))
                }
                room.SetRoomCoordinates(rec)
                room.SetRoomFloor(floorNum)
                room.SetroomCenter(_minX, minY: _minY, maxX: _maxX, maxY: _maxY)
                let potentialNewName = checkForDupName(roomName!, floorsRooms: floorsRooms)
                if potentialNewName == String(){
                    floorsRooms[roomName!] = (room)
                }
                else{
                    room.SetRoomName(potentialNewName)
                    room.SetRoomType(roomName!)
                    floorsRooms[potentialNewName] = (room)
                }
                
            }
            }
        }
        return floorsRooms
    }
    
    func checkForDupName(roomLookUp:String, floorsRooms: [String:RoomData])->String{
            switch roomLookUp{
                case "ELV":
                    _elvCount++
                    return "ELV\(_elvCount)"
                case "WB":
                    _wbCount++
                    return "WB\(_wbCount)"
                case "MB":
                    _mbCount++
                    return "MB\(_mbCount)"
                case "STR":
                    _strCount++
                    return "STR\(_strCount)"
                case "HW":
                    _hwCount++
                    return "HW\(_hwCount)"
                case "UX":
                    _uxCount++
                    return "UX\(_uxCount)"
                case "EXT":
                    _extCount++
                    return "EXT\(_extCount)"
                default:
                    return String()
            }
    }
    
    func determineMaxMin(maxX:Double, maxY:Double,minX:Double,minY:Double){
        _minX = ((minX < _minX) ? minX : _minX)
        _minY = ((minY < _minY) ? minY : _minY)
        _maxX = ((maxX > _maxX) ? maxX : _maxX)
        _maxY = ((maxY > _maxY) ? maxY : _maxY)
    }
    
    func checkJsonResponseSuccess(response: JSON)-> Bool{
        return response[JSON_SUCCESS].bool!
    }
    
    
    enum JSONError: String, ErrorType {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
//    func updateRoomsInfo(building_id : String ,room_name : String, inout RoomInformation : RoomData) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
//            let urlPath = "https://whirlpool-indoor-maps.appspot.com/room?building_name=\(building_id)&room_name=\(room_name)"
//            guard let endpoint = NSURL(string: urlPath) else { print("Error creating endpoint");return }
//            let request = NSMutableURLRequest(URL:endpoint)
//            NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
//                do {
//                    
//                    do {
//                        
//                        if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as?  NSDictionary {
//                            if let features = json["amenities"] as? NSArray {
//                                for resource in features {
//                                    RoomInformation.SetRoomResources((resource as? String)!)
//                                }
//                            }
//                            
//                            
//                            if let rows = json["rooms"] as? [[String: AnyObject]] {
//                                for ro in rows {
//                                    
//                                    if let cap = ro["capacity"] as? Int {
//                                        RoomInformation.SetRoomCapacity(cap)
//                                    }
//                                    if let ext = ro["extension"] as? String {
//                                        RoomInformation.SetRoomExt(ext);
//                                    }
//                                    if let stat = ro["occupancy_status"] as? String {
//                                        RoomInformation.SetRoomStatus(stat)
//                                    }
//                                    if let name = ro["room_name"] as? String {
//                                        RoomInformation.SetRoomName(name)
//                                    }
//                                    if let loc = ro["building_name"] as? String {
//                                        RoomInformation.SetRoomLocation(loc)
//                                    }
//                                    if let type = ro["room_type"] as? String {
//                                        RoomInformation.SetRoomType(type)
//                                    }
//                                    if let email = ro["email"] as? String {
//                                        RoomInformation.SetRoomEmail(email)
//                                    }
//                                    
//                                }
//
//                            }
//                        }
//                        
//                    }
//                } catch let error as JSONError {
//                    print(error.rawValue)
//                } catch {
//                    print(error)
//                }
//                
//                }.resume()
//        })
//        
//    }

    

    

    
}