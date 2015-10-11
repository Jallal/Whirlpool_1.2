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
    
    
    private var Rooms  = [RoomInfoViewController()];
   
    
    public func getAllRooms()-> [RoomInfoViewController] {
        
        return self.Rooms
        
    }
    
    public func addARoom(room : RoomInfoViewController){
        
        Rooms .append(room);
        
    }

    
    
}