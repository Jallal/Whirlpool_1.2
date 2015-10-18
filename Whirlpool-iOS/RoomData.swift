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
    private var RoomName = String()
    private var RoomEmail = String()
    private var IsSelected = false;
    private var roomCenter = CLLocationCoordinate2DMake(0,0)
    private var roomLOcation = String()
    private var roomCapacity  = String()
    private var roomPolycomExt = String()
    private var roomAvResources = [String]()
    private var roomOwnership = String()
    private var roomNotes = String()
    private var roomstatus = String()
    private var roomFloor = String()
    
    
    
    
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
    
    public func GetRoomName()->String{
        return self.RoomName;
        
    }
    
    public func GetRoomEmail()-> String {
        return self.RoomEmail
    }
    
    
    
    
    public func SetRoomName(name: String){
        self.RoomName = name
    }
    
    

    
    public func SetRoomEmail(email: String){
        self.RoomEmail = email
    }
    
    
    public func SetRoomLocation(loca: String){
        self.roomLOcation = loca
    }
    
    
    public func SetRoomCapacity(capacity: String){
        self.roomCapacity = capacity
    }
    
    public func SetRoomResources(resources: String){
        let AvResources = resources.componentsSeparatedByString(",")
        self.roomAvResources = AvResources
    }
    public func GetRoomResources()->[String]{
        return self.roomAvResources
    }
    
    public func SetRoomOwnership(owner: String){
     
        self.roomOwnership = owner
    }
    
    public func SetRoomNotes(notes: String){
        
        self.roomNotes = notes
    }
    
    public func SetRoomStatus(status: String){
    self.roomstatus  = status
    }
    
    public func SetRoomPolycomExt( poly : String){
        self.roomPolycomExt = poly
    }
    public func SetRoomFloor(floor : String){
        self.roomFloor = floor
    }
    

}