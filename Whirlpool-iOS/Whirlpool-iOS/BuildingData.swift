//
//  BuildingData.swift
//  Whirlpool-iOS
//
//  Created by Jallal Elhazzat on 11/9/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation
import GoogleMaps

 struct BuildingInfo {
    var name : String = String()
    var Floors : Array<FloorData> = Array<FloorData>()
}


public class  BuildingData {
    
    var addFloorTobuilding = Array<FloorData>(count: 4, repeatedValue: FloorData())
    
    var AllBuilding  = Array<BuildingInfo>(count: 4, repeatedValue: BuildingInfo())
    
    var Building  = BuildingInfo()
    
    
    func AddFloorToBuilding(floor : FloorData ){
        addFloorTobuilding.append(floor)
    }
    
    func linkBuildingToFloors(builing_id : String, floors : Array<FloorData>){
        Building.name  = builing_id
        Building.Floors = floors
        AllBuilding.append(Building)
    }
    
    func getAllFloorsInBuilding(name : String )-> Array<FloorData>{
        
        for build in AllBuilding {
            if  build.name == name {
                return build.Floors
            }
        }
        return Array<FloorData>()//Check for empty name on return of this function

        
    }
    
    
    
    
    
    
    
    
    
    
}