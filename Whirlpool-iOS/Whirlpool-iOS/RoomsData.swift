//
//  RoomsData.swift
//  Whirlpool-iOS
//
//  Created by Team Whirlpool on 10/11/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation
import GoogleMaps

public class RoomsData {
    
    
    var Rooms  = [RoomData]();
   
    
    public func getAllRooms()-> [RoomData] {
        return self.Rooms
    }
    
    public func addARoom(room : RoomData){
        Rooms.append(room);
    }
    
    public func count()->Int {
        return Rooms.count
    }
    
    public func getRoomWithName(roomName: String)-> RoomData {
        for room in Rooms {
            if room.GetName() == roomName {
                return room
            }
        }
            return RoomData() //Check for empty name on return of this function
    }

    
    
}