
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

protocol buildingsLoadedDelegate {
    func buildingAbbsHaveBeenLoaded()
    func buildingInfoHasBeenLoaded()
}

class BuildingsData {
    var _buildings = [String:Building]()
    var _buildingAbbr = [String]()
    var _amountOfBuildings: Int?
    var _buildingDelegate: buildingsLoadedDelegate? = nil
    var (_maxX, _maxY, _minX, _minY) = (Double(),Double(),Double(),Double())
    let BUILDINGS_URL = "https://whirlpool-indoor-maps.appspot.com/buildings"
    let BUILDING_URL =  "https://whirlpool-indoor-maps.appspot.com/building?building_name="
    let BUILDING_GEOJSON_URL = "https://whirlpool-indoor-maps.appspot.com/blobstore/ops?building_name="
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
    
    //This init is used to grab data for a building by abbreviation, checks abbreviation passed in after gettting proper abbreviations from database
    init(delegate: buildingsLoadedDelegate, buildingAbb: String){
        _buildingDelegate = delegate
        request(BUILDINGS_URL) { (response) -> Void in  //Grab all building abbreviations
            self._amountOfBuildings = response[self.JSON_COUNT].int
            self.parseOutBuildingInfo(response)
            self._buildingDelegate?.buildingAbbsHaveBeenLoaded()
            if self._buildingAbbr.contains(buildingAbb) {
                self.request(self.BUILDING_URL+buildingAbb) { (response) -> Void in //Grab the building data for the abbreviation
                    self.addBuildingToArrayFromDB(response)
                    self.request(self.BUILDING_GEOJSON_URL + buildingAbb) { (response) -> Void in   //Grab the Geojson for the floors in the building
                        self.parseBuildingData(response)
                        //call the protocol func here thats implimented in your class that you wanted
                        //This tell the class that the building objects are done being populated
                        self._buildingDelegate?.buildingInfoHasBeenLoaded()
                    }
                }
            }
        }
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
            let buildingAbb = buildingInfoResponse[BUILDING_NAME_JSON_ID].string!
            let numberOfFloors = buildingInfoResponse[BUILDING_FLOORNUM_JSON_ID].int!
            let numberOfWings = buildingInfoResponse[BUILDING_WINGNUM_JSON_ID].int!
            let building = Building(buildingAbbr: buildingAbb, numberOfFloors: numberOfFloors, numberOfWings: numberOfWings)
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
        let floorsRooms = parseGeoJsonOfEachFloor(jsonBuildingAndFloorData[JSON_FLOORS][iteration], buildingAbb: buildingAbb)
        floor.setRooms(floorsRooms)
        _buildings[buildingAbb]?.appendFloor(floor)
    }
    
    //This is parsing out all the rooms and their coordinates and returning a list to add the rooms to the specific floor
    func parseGeoJsonOfEachFloor(jsonBuildingAndFloorData: JSON, buildingAbb: String)->[RoomData]{
        let strData = jsonBuildingAndFloorData["geojson"].string!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let geoJsonInfo = JSON(data: strData!, options: NSJSONReadingOptions.MutableContainers, error: nil)
        var floorsRooms = [RoomData]()
        for x in 0...(geoJsonInfo[JSON_FEATURES].count - 1) {
            let roomName = geoJsonInfo[JSON_FEATURES][x][JSON_PROP][JSON_ROOM].string
            let roomType = geoJsonInfo[JSON_FEATURES][x][JSON_GEOM][JSON_TYPE].string
            if roomType == "Polygon" {
                (_maxX, _maxY, _minX, _minY) = (-180.0,-90.0,180.0,90.0)
                let room = RoomData()
                room.SetRoomName(roomName!)
                 var rec = GMSMutablePath()
                for y in 0...(geoJsonInfo[JSON_FEATURES][x][JSON_GEOM][JSON_COORD][0].count - 1) {
                    let  lat = geoJsonInfo[JSON_FEATURES][x][JSON_GEOM][JSON_COORD][0][y][1].double!    // coordinates for room look like [[[long,lat],[long,lat]]]
                    let  long  = geoJsonInfo[JSON_FEATURES][x][JSON_GEOM][JSON_COORD][0][y][0].double!
                    determineMaxMin(long,maxY: lat, minX: long, minY: lat)
                    rec.addCoordinate(CLLocationCoordinate2D(latitude: lat,longitude: long))
                }
                room.SetRoomCoordinates(rec)
                room.SetroomCenter(_minX, minY: _minY, maxX: _maxX, maxY: _maxY)
                floorsRooms.append(room)
            }
        }
        return floorsRooms
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
    

    

    
}