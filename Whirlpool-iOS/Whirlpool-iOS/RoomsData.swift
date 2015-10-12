//
//  RoomsData.swift
//  Whirlpool-iOS
//
//  Created by Team Whirlpool on 10/11/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation
import GoogleMaps

class RoomsData {
    
    
    private var Rooms  = [RoomData()];
   
    
    public func getAllRooms()-> [RoomData] {
        return self.Rooms
    }
    
    public func addARoom(room : RoomData){
        Rooms.append(room);
    }
    
    public func count()->Int {
        return Rooms.count
    }

    
    
}