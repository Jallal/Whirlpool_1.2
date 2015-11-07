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
    
    
    
    
    func getTheGeoJson(building_id : String){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let urlPath = "https://whirlpool-indoor-maps.appspot.com/blobstore/ops?building_name=\(building_id)"
            guard let endpoint = NSURL(string: urlPath) else { print("Error creating endpoint");return }
            let request = NSMutableURLRequest(URL:endpoint)
            NSURLSession.sharedSession().dataTaskWithRequest(request) { (data, response, error) -> Void in
                do {
                    if let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary {
                          if let features = jsonDict["floors"] as? [[String: AnyObject]]{
                            for da in  features{
                            
                                if let cap = da["geojson"] as? NSString{
                                    
                                   let file = "file.txt"
                                    let text = cap
                                    if let dir : NSString = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true).first {
                                        let path = dir.stringByAppendingPathComponent(file);
                                        
                                        //writing
                                        do {
                                            try text.writeToFile(path, atomically: false, encoding: NSUTF8StringEncoding)
                                        }
                                        catch {/* error handling here */}
                                        
                                        //reading
                                        do {
                                           //let text2 = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding)
                                            self.parseJson(path,Building_id: building_id);
                                          
                                        }
                                        catch {/* error handling here */}
                                    }
                                    
                                
                              
                                }
                                
                            }
                           
                            
                        
                        }
                        
                    }
                } catch let error as NSError {
                    // error handling
                } catch {
                    print(error)
                }
                
                }.resume()
        })
        
}






    //func parseJson( filename : String,Building_id : String){
    func parseJson(jsonPath : String,var Building_id : String){
        
        //self.getTheGeoJson()
        
        
        // Parsing GeoJSON can be CPU intensive, do it on a background thread
        //var Building_id : String =  "RV"
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            
            // Get the path for example.geojson in the app's bundle
            
            //let jsonPath = NSBundle.mainBundle().pathForResource(filename, ofType: "json")
            let jsonData = NSData(contentsOfFile: jsonPath)
            
            do {
                
                // Load and serialize the GeoJSON into a dictionary filled with properly-typed objects
                
                if let jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: []) as? NSDictionary {
                    
                    //print(jsonDict);
                    
                    // Load the `features` array for iteration
                    if let features = jsonDict["features"] as? NSArray {
                        
                        for feature in features {
                            var CurrentRoom = RoomData();
                            if let feature = feature as? NSDictionary {
                                if let  property = feature["properties"] as? NSDictionary {
                                    
                                    if let roomNum = property["room"]{
                                        CurrentRoom.SetRoomName(roomNum as! String)
                                        
                                    }
                                    
                                }
                                if let geometry = feature["geometry"] as? NSDictionary {
                                    
                                    
                                    if geometry["type"] as? String == "Polygon" {
                                        
                                        // Create an array to hold the formatted coordinates for our line
                                        
                                        //var coordinates: [CLLocationCoordinate2D] = []
                                        
                                        if let locations = geometry["coordinates"] as? NSArray {
                                            
                                            // Iterate over line coordinates, stored in GeoJSON as many lng, lat arrays
                                            var maxX : double_t = -400
                                            var maxY : double_t = -400
                                            var minX : double_t = 400
                                            var minY : double_t = 400
                                            
                                            for location in locations {
                                                var rec = GMSMutablePath()
                                                
                                                for var i = 0; i < location.count; i++ {
                                                    var lat = 0 as Double
                                                    for var j = 0; j < location[i].count; j++ {
                                                        
                                                        if (j+1 == location[i].count){
                                                            rec.addCoordinate(CLLocationCoordinate2DMake(location[i][j].doubleValue,lat))
                                                            if(maxX < location[i][j].doubleValue){
                                                                maxX = location[i][j].doubleValue
                                                            }
                                                            if(maxY < lat){
                                                                maxY = lat
                                                            }
                                                            if(minX > location[i][j].doubleValue){
                                                                minX = location[i][j].doubleValue
                                                            }
                                                            if(minY > lat){
                                                                minY = lat
                                                            }
                                                            
                                                        }
                                                        else{
                                                            lat = location[i][j].doubleValue
                                                            if(maxY <  lat){
                                                                maxY = lat
                                                            }
                                                            if(minY >  lat){
                                                                minY = lat
                                                            }
                                                            
                                                        }
                                                    }
                                                    
                                                    
                                                }
                                                CurrentRoom.SetroomCenter((minX+maxX)/2, y: ((minY+maxY)/2))
                                                CurrentRoom.SetRoomCoordinates(rec)
                                            }
                                            
                                            
                                        }
                                        
                                        
                                    }
                                }
                            }
                            self.updateRoomsInfo(Building_id,room_name: CurrentRoom.GetRoomName(),RoomInformation: CurrentRoom )
                            self.addARoom(CurrentRoom)
                            
                            
                        }
                    }
                    
                }
            }
                
                
            catch
                
            {
                
                print("GeoJSON parsing failed")
                
            }
            
        })
      }
    
    
    
   }