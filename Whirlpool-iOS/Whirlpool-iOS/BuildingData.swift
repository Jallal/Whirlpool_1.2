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
    
    var AllBuilding  = Array<BuildingInfo>()
    var Building  = BuildingInfo()
    
    
    func linkBuildingToFloors(builing_id : String, Allfloors : Array<FloorData> ){
        Building.name  = builing_id
        Building.Floors = Allfloors
        self.AllBuilding.append(Building)
    }
    
    
    
    func getAllFloorsInBuilding(name : String )-> Array<FloorData>{
        
        for build in AllBuilding {
            if  build.name == name {
                return build.Floors
            }
        }
        return Array<FloorData>()//Check for empty name on return of this function
    }
    
    
    func getNumberOfFloorsInBuilding(name : String) -> Int{
        for build in AllBuilding {
            if  build.name == name {
                return   build.Floors.count
            }
        }
        
        return 0
        
    } 
    
    
}