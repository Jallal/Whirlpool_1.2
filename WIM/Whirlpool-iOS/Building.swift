
//
//  Building.swift
//  Whirlpool-iOS
//
//  Created by Gregory Richard on 11/7/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol buildingsUpdatedDelagate{
    func doneUpdating()
}

class Building: NSObject {
    var _buildingAbbr: String
    var _numberOfFloors: Int
    var _numberOfWings: Int
    var _floors = [FloorData]()
    var _rooms = [RoomData]()
    var _timer = NSTimer()
    var getAllRoomsRequest = "https://whirlpool-indoor-maps.appspot.com/room"
    var updatingDelagate: buildingsUpdatedDelagate?
    
    init(buildingAbbr: String, numberOfFloors: Int, numberOfWings: Int, delg: buildingsUpdatedDelagate){
        self._buildingAbbr = buildingAbbr
        self._numberOfFloors = numberOfFloors
        self._numberOfWings = numberOfWings
        self.updatingDelagate = delg
    }
    
    deinit{
        print("good bye building")
    }
    
    func removeTimer(){
        if _timer != NSTimer() {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                print("Good by timer")
                self._timer.invalidate()
            }
        }
    }
    
    func doneUpdating(){
        if updatingDelagate != nil {
            updatingDelagate?.doneUpdating()
        }
    }
    
    func appendFloor(floor: FloorData){
        _floors.append(floor)
    }
    
    func getFloors() -> [FloorData]{
        return _floors
    }
    
    func getNumberOfFloors() -> Int{
      return  _floors.count
    }
    
    func getFloorInBuilding(myfloor : Int) -> FloorData{
        
        var optionalFloor = FloorData(floorNumber: 1,floorWing: "nil")
        
        for floor in self._floors{

            if(floor._floorNumber == myfloor){
                return  floor
            }
        }
        
        
        return optionalFloor
    }
    
    
    
    
    func getARoomInBuilding(building_id : String) -> RoomData{
        
        var myRoom = RoomData()
        
        if(self._buildingAbbr == building_id){
            
            for floor in self.getFloors(){
                var rooms =  floor.getRoomsInFloor()
                
                for (roomName, room) in rooms{
                    
                    myRoom = room
                    return  myRoom
                }
                
                
                }
            }
        
       return myRoom
    }
    
    func buildingStartRoomUpdateTimer(){
        if NSThread.isMainThread(){
        _timer = NSTimer.scheduledTimerWithTimeInterval(120.0, target: self, selector: Selector("UpdateBuildingsRoomStatus"), userInfo: nil, repeats: true)
        }
        else{
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                self._timer = NSTimer.scheduledTimerWithTimeInterval(120.0, target: self, selector: Selector("UpdateBuildingsRoomStatus"), userInfo: nil, repeats: true)
            })
        }
    }
    
    func getARoomInBuilding(building_id : String, roomName: String) -> RoomData{
        
        var myRoom = RoomData()
        
        if(self._buildingAbbr == building_id){
            
            for floor in self.getFloors(){
                var rooms =  floor.getRoomsInFloor()
                
                for (roomName, room) in rooms{
                    
                    if (roomName == room.GetRoomName()){
                        return room
                    }
                }
                
                
            }
        }
        
        return myRoom
    }
    

    
    func UpdateBuildingsRoomStatus()
    {
        request(getAllRoomsRequest) { (response) -> Void in
            self.parseRoomsAndBuildings(response)
            self.doneUpdating()
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
    
    func parseRoomsAndBuildings(response: JSON){
        for i in 0...response.count-1{
            for x in 0...response[i]["rooms"].count-1{
                let room = response[i]["rooms"][x] as JSON
                createRoomFromJSON(room)
            }
        }
    }
    
    func createRoomFromJSON(roomJson:JSON){
        let room = RoomData()
        room.SetRoomName(roomJson["room_name"].stringValue)
        for i in 0..._floors.count-1{
            if _floors[i]._rooms[room.GetRoomName()] != nil {
                _floors[i]._rooms[room.GetRoomName()]!.SetRoomName(roomJson["room_name"].stringValue)
                _floors[i]._rooms[room.GetRoomName()]!.SetRoomEmail(roomJson["email"].stringValue)
                _floors[i]._rooms[room.GetRoomName()]!.SetRoomCapacity(roomJson["capacity"].intValue)
                _floors[i]._rooms[room.GetRoomName()]!.SetRoomStatus(roomJson["occupancy_status"].stringValue)
                _floors[i]._rooms[room.GetRoomName()]!.SetRoomExt(roomJson["extension"].stringValue)
                _floors[i]._rooms[room.GetRoomName()]!.SetRoomType(roomJson["room_type"].stringValue)
                _floors[i]._rooms[room.GetRoomName()]!.SetRoomLocation(roomJson["resource_name"].stringValue)
                _floors[i]._rooms[room.GetRoomName()]!.SetRoomBuildingName(roomJson["building_name"].stringValue)
                break
            }
        }
        
    }
    
    
    
    
}