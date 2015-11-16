//
//  Building.swift
//  Whirlpool-iOS
//
//  Created by Gregory Richard on 11/7/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation
import SwiftyJSON

class Building {
    let _buildingAbbr: String
    let _numberOfFloors: Int
    let _numberOfWings: Int
    var _floors = [FloorData]()
    var _rooms = [RoomData]()
    
    init(buildingAbbr: String, numberOfFloors: Int, numberOfWings: Int){
        self._buildingAbbr = buildingAbbr
        self._numberOfFloors = numberOfFloors
        self._numberOfWings = numberOfWings
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
    
    
    
    func getARoomInBuilding(building_id : String) -> RoomData{
        
        var myRoom = RoomData()
        
        if(self._buildingAbbr == building_id){
            
            for floor in self.getFloors(){
                var rooms =  floor.getRoomsInFloor()
                
                for room in rooms{
                    
                    myRoom = room
                    return  myRoom
                }
                
                
                }
            }
        
       return myRoom
    }
    
    func getARoomInBuilding(building_id : String, roomName: String) -> RoomData{
        
        var myRoom = RoomData()
        
        if(self._buildingAbbr == building_id){
            
            for floor in self.getFloors(){
                var rooms =  floor.getRoomsInFloor()
                
                for room in rooms{
                    
                    if (roomName == room.GetRoomName()){
                        return room
                    }
                }
                
                
            }
        }
        
        return myRoom
    }
    
    
}