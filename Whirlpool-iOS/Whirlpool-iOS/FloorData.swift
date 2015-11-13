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

    var _rooms:[RoomData]
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
    
    
}