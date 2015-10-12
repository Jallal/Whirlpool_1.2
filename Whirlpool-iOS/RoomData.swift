//
//  RoomData.swift
//  Whirlpool-iOS
//
//  Created by Gregory Richard on 10/11/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation
import GoogleMaps


class RoomData {

    private var coordinates  = [GMSMutablePath()];
    private  var RoomNumber = ""
    private var RoomName = ""
    private var RoomEmail = ""
    
    
    
    
    public func SetRoomCoordinates(coord  : GMSMutablePath){
        self.coordinates.append(coord);
        
    }
    
    public func GetRoomCoordinates()->[GMSMutablePath]{
        return self.coordinates;
        
    }
    
    public func SetRoomNumber(roomnumber: String){
        
        self.RoomNumber = roomnumber;
    }
    public func GetRoomNumber()-> String{
        
        return self.RoomNumber ;
    }
    

}