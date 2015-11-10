//
//  RoomsData.swift
//  Whirlpool-iOS
//
//  Created by Team Whirlpool on 10/11/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation
import GoogleMaps


public class RoomsData :UIViewController, NSURLConnectionDelegate {
    var Rooms  = [RoomData]();
    
    public func getAllRooms()-> [RoomData] {
        return self.Rooms
    }
    
    public func addARoom(room : RoomData){
        Rooms.append(room);
    }
    
    public func count()->Int {
        return Rooms.count
    }

    
    public func getRoomWithName(roomName: String)-> RoomData {
      
        for room in Rooms {
            if room.GetRoomName() == roomName {
                return room
            }
        }
            return RoomData() //Check for empty name on return of this function
    }
    
    
    
    
    
    
    enum JSONError: String, ErrorType {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    

    
    
    func updateRoomsInfo(building_id : String ,room_name : String,RoomInformation : RoomData) {
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let urlPath = "https://whirlpool-indoor-maps.appspot.com/room?building_name=\(building_id)&room_name=\(room_name)"
            guard let endpoint = NSURL(string: urlPath) else { print("Error creating endpoint");return }
            let request = NSMutableURLRequest(URL:endpoint)
            NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
                do {
                    
                    do {
                        
                        if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as?  NSDictionary {
                            if let features = json["amenities"] as? NSArray {
                                for resource in features {
                                    RoomInformation.SetRoomResources((resource as? String)!)
                                }
                            }
                            
                            
                            if let rows = json["rooms"] as? [[String: AnyObject]] {
                                for ro in rows {
                                    
                                    if let cap = ro["capacity"] as? Int {
                                        RoomInformation.SetRoomCapacity(cap)
                                    }
                                    if let ext = ro["extension"] as? String {
                                        RoomInformation.SetRoomExt(ext);
                                    }
                                    if let stat = ro["occupancy_status"] as? String {
                                        RoomInformation.SetRoomStatus(stat)
                                    }
                                    if let name = ro["room_name"] as? String {
                                        RoomInformation.SetRoomName(name)
                                    }
                                    if let loc = ro["building_name"] as? String {
                                        RoomInformation.SetRoomLocation(loc)
                                    }
                                    if let type = ro["room_type"] as? String {
                                        RoomInformation.SetRoomType(type)
                                    }
                                    if let email = ro["email"] as? String {
                                        RoomInformation.SetRoomEmail(email)
                                    }
                                    
                                    
                                }
                            }
                        }
                        
                    }
                } catch let error as JSONError {
                    print(error.rawValue)
                } catch {
                    print(error)
                }
                
                }.resume()
        })
        
    }
    
    
   }