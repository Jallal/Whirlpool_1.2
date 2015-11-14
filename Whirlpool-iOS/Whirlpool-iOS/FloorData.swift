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

   var _rooms  = Array<RoomData>()
   var _floorNumber:Int!

    var _floorWing:String!
    
    init(floorNumber: Int, floorWing: String){
        _floorNumber = floorNumber
        _floorWing = floorWing
        _rooms = [RoomData]()
    }
    
    func setRooms(rooms: [RoomData]){
        _rooms = rooms
    }
    
    func appendRoom(room: RoomData){
        _rooms.append(room)
    }
    
    func getRoomsInFloor(Floor : Int)->[RoomData] {
        
        if(self._floorNumber == Floor){
            
            return self._rooms
            
        }else{
            return [RoomData] ()
        }
        
        
    }
    
    func getRoomsInFloor()-> Array<RoomData>{
        
       return  _rooms
        
        
    }
    
    
}