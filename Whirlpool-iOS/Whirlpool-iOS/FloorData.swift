//
//  FloorData.swift
//  Whirlpool-iOS
//
//  Created by Jallal Elhazzat on 11/7/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation
import GoogleMaps


struct FloorInfo {
    var number : Int = Int()
    var rooms: Array<RoomData> = Array<RoomData>()
}

public class FloorData {
    
    var AllFloors  = Array<FloorInfo>()
    var floor  = FloorInfo()


    
    func getRoomsInFloor(floor : Int)->Array<RoomData>{
        
        for fl in AllFloors {
            if  fl.number == floor{
                return fl.rooms
            }
        }
          return Array<RoomData>()
    }
    
    

    
    func AddRoomsToFloor(f: Int, rooms : Array<RoomData> ){
        floor.number = f
        floor.rooms = rooms
        self.AllFloors.append(floor)
    }
    
    
    
    func getNumberOfFloors()->Int {
        return  self.AllFloors.count
    }
    
    
}