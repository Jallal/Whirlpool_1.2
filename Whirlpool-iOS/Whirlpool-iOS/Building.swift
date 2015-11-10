//
//  Building.swift
//  Whirlpool-iOS
//
//  Created by Gregory Richard on 11/7/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation

class Building {
    let _buildingName: String
    let _buildingAbbr: String
    let _numberOfFloors: Int
    let _numberOfWings: Int
    var _floors = [FloorData]()
    
    
    init(buildingName: String, buildingAbbr: String, numberOfFloors: Int, numberOfWings: Int){
        self._buildingAbbr = buildingAbbr
        self._buildingName = buildingName
        self._numberOfFloors = numberOfFloors
        self._numberOfWings = numberOfWings
    }
    
    func appendFloor(floor: FloorData){
        _floors.append(floor)
    }
    
    func getFloors() -> [FloorData]{
        return _floors
    }
    
}