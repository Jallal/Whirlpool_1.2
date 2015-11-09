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
    private var roomLocation = String()
    private var roomCapacity  = Int()
    private var roomPolycomExt = String()
    private var roomAvResources = [String()]
    private var roomOwnership = String()
    private var roomNotes = String()
    private var roomstatus = String()
    private var roomFloor = String()
    private var roomExt = String()
     private var roomType = String()
    
    
    
    
    public func SetRoomType(type : String){
        self.roomType = type
    }
    public func GetRoomType()->String{
        return self.roomType
    }
    
    
    public func SetRoomExt(ext : String){
        self.roomExt = ext;
    }
    public func GetRoomExt()->String{
        return self.roomExt
    }
    
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
    public func SetRoomStatus(stat : String ){
        self.roomstatus = stat;
    }
    public func GetRoomStatus()->String{
        return self.roomstatus;
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
        self.roomLocation = loca
    }
    
    public func GetRoomLocation() -> String{
        return self.roomLocation
    }
    
    
    public func SetRoomCapacity(capacity: Int){
        self.roomCapacity = capacity
    }
    public func GetRoomCapacity()->Int{
        return self.roomCapacity
    }
    
    public func SetRoomResources(resources: String){
        self.roomAvResources.append(resources)
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
    
    public func SetRoomPolycomExt( poly : String){
        self.roomPolycomExt = poly
    }
    public func SetRoomFloor(floor : String){
        self.roomFloor = floor
    }
    

}