//
//  RoomData.swift
//  Whirlpool-iOS
//
//  Created by Gregory Richard on 10/11/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation
import GoogleMaps


public class RoomData {

    private var coordinates  = [GMSMutablePath()];
    private  var RoomNumber = String()
    private var RoomName = String()
    private var RoomEmail = String()
    private var IsSelected = false;
    private var roomCenter = CLLocationCoordinate2DMake(0,0)
    
    
    public func SetroomCenter(x : double_t, y : double_t){
        
        self.roomCenter.latitude  = x;
        self.roomCenter.longitude = y;

        
    }
    public func GetroomCenter() -> CLLocationCoordinate2D{
        return self.roomCenter
        
    }
    
    
    
    public func SetIsSelected(select : Bool){
        
              self.IsSelected = select;
        
    }
    public func GetIsSelected() -> Bool{
        return self.IsSelected;
        
    }
    
    
    public func SetRoomCoordinates(coord  : GMSMutablePath){
        self.coordinates.append(coord);
        
    }
    
    public func GetRoomCoordinates()->[GMSMutablePath]{
        return self.coordinates;
        
    }
    
    public func GetName()->String{
        return self.RoomName;
        
    }
    
    public func GetEmail()-> String {
        return self.RoomEmail
    }
    
    
    public func SetRoomNumber(roomnumber: String){
        
        self.RoomNumber = roomnumber;
    }
    public func GetRoomNumber()-> String{
        
        return self.RoomNumber ;
    }
    
    public func SetRoomName(name: String){
        self.RoomName = name
    }

    
    public func SetRoomEmail(email: String){
        self.RoomEmail = email
    }
}