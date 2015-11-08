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

    var buildingFloors = Array<Array<RoomData>>(count: 3, repeatedValue: Array<RoomData>())

    
    func getRoomsInFloor(floor : Int)->Array<RoomData>{
        return buildingFloors[floor]
    }

    
    func AddRoomsToFloor(floor: Int, rooms : Array<RoomData> ){
      self.buildingFloors[floor]=rooms

        
    }
    
    func getNumberOfFloors()->Int{
        return self.buildingFloors.count
    }
    
    
    
}