//
//  FloorData.swift
//  Whirlpool-iOS
//
//  Created by Jallal Elhazzat on 11/7/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation
import GoogleMaps




public class FloorData {

    var _rooms  = [String:RoomData]()
   var _floorNumber:Int!

    var _floorWing:String!
    
    init(floorNumber: Int, floorWing: String){
        _floorNumber = floorNumber
        _floorWing = floorWing
        _rooms = [String:RoomData]()
    }
    

    func setRooms(rooms: [String:RoomData]){
        _rooms = rooms
    }
    
    func appendRoom(room: RoomData){
        _rooms[room.GetRoomName()]=(room)
    }
    
    func getRoomsInFloor(Floor : Int)->[String: RoomData] {
        if(self._floorNumber == Floor){
            return self._rooms
        }else{
            return [String: RoomData] ()
        }
    }
    
    func getRoomsInFloor()-> [String:RoomData]{
       return  _rooms
    }
    
    func SetFloorNumber( floor : Int){
        self._floorNumber = floor
    }
    
    func getFloorNumber() -> Int{
        return self._floorNumber
    }
    
    
    func getElevatorsAndStairsInFloor()-> [String:RoomData]{
        
        var Elevators  = [String:RoomData]()
        
        for (roomName, room) in _rooms{
            
            if((room.GetRoomName().containsString("ELV"))||(room.GetRoomName().containsString("STR"))){
                Elevators[roomName] = (room)
            }
            
        }
        
        
        return Elevators
    }
    
//    func getElevatorsOnlyInFloor()-> [String: RoomData]{
//        
//        var Elevators  = [String:RoomData]()
//        
//        for (roomName, room) in _rooms{
//            
//            if(room.GetRoomName() == "ELV"){
//                Elevators[roomName] = (room)
//                
//            }
//            
//        }
//        
//        
//        return Elevators
//    }
    
    
}
