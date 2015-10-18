//
//  RoomsData.swift
//  Whirlpool-iOS
//
//  Created by Team Whirlpool on 10/11/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation
import GoogleMaps

public class RoomsData {
    
    
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

    
    
    public func getRoombyName(name : String)->RoomData{
        var newRoom = RoomData()
        
       for room in self.getAllRooms(){
        if(room.GetRoomName()==name){
            return room
        }
       }
        return newRoom
    }
    
    
    
    enum JSONError: String, ErrorType {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
    }
    
    func updateRoomsInfo() {
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
        let urlPath =  "https://webdev.cse.msu.edu/~elhazzat/wim/room-load.php"
        guard let endpoint = NSURL(string: urlPath) else { print("Error creating endpoint");return }
        let request = NSMutableURLRequest(URL:endpoint)
        NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
            do {
                
                do {
                    
                    if let json = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as?  NSArray {
                        for room in (json as? NSArray)! {
                            var RoomInformation  = RoomData();
                             var count = 0;
                            for ro in (room as? NSArray)!  {
                                if(count==0){
                                    RoomInformation.SetRoomLocation(ro as! String)
 
                                }
                                else if(count==1){
                                     RoomInformation.SetRoomName(ro as! String)
                                    
                                }
                                else if(count==2){
                                    RoomInformation.SetRoomCapacity(ro as! String)
                                    
                                }
                                else if(count==3){
                                        RoomInformation.SetRoomPolycomExt(ro as! String)
                                    
                                }
                                else if(count==4){
                                     RoomInformation.SetRoomResources(ro as! String)
                                    
                                }
                                else if(count==5){
                                    RoomInformation.SetRoomOwnership(ro as! String)
                                    
                                }
                                else if(count==6){
                                     RoomInformation.SetRoomNotes(ro as! String)
                                    
                                }
                                else if(count==7){
                                    RoomInformation.SetRoomStatus(ro as! String)
                                    
                                }
                                else if(count==8){
                                      RoomInformation.SetRoomFloor(ro as! String)
                                    
                                }
                                else if(count==9){
                                     RoomInformation.SetRoomEmail(ro as! String)
                                    
                                }
                                count = count+1
                                
                            }
                            
                            self.addARoom(RoomInformation);
                        }
                        
                    } else {
                        let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)    // No error thrown, but not NSDictionary
                        print("Error could not parse JSON: \(jsonStr)")
                    }
                } catch let parseError {
                    print(parseError)                                                          // Log the error thrown by `JSONObjectWithData`
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    print("Error could not parse JSON: '\(jsonStr)'")
                }
            } catch let error as JSONError {
                print(error.rawValue)
            } catch {
                print(error)
            }
            
            }.resume()
              })
        
    }
    
    

    
    
    
func insertroominfo( loc: String,room: String,floor:String,status:String,email:String,ownership:String,resources:String,capacity: String){
        var bodyData = "location=\(loc)&room=\(room)&floor=\(floor)&status=\(status)&email=\(email)&ownership=\(ownership)&resources=\(resources)&capacity=\(capacity)"
    //var bodyData = ["location" :loc, "room": room, "floor" : floor, "status" : status, "email": email, "ownership":ownership, "resources": resources, "capacity":capacity]
    
    
        let URL: NSURL = NSURL(string: "https://webdev.cse.msu.edu/~elhazzat/wim/room-insert.php")!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:URL)
        request.HTTPMethod = "POST"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
            {
                (response, data, error) in
                print(response)
                print(data)
                var output = NSString(data: data!, encoding: NSUTF8StringEncoding) // new output variable
                //var array = self.JSONParseArray(output)
        }
        
    }
    
    
    
    
    func updateRoomStatus( value : Bool, email : String,room: String,location : String){
        var bodyData = "?status=\(value)&email=\(email)&room=\(room)&location=\(location)"
        let URL: NSURL = NSURL(string: "https://webdev.cse.msu.edu/~elhazzat/wim/room-save.php")!
        let request:NSMutableURLRequest = NSMutableURLRequest(URL:URL)
        request.HTTPMethod = "POST"
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue())
            {
                (response, data, error) in
                
                var output = NSString(data: data!, encoding: NSUTF8StringEncoding) // new output variable
                //var array = self.JSONParseArray(output)
        }
        
    }
    
}