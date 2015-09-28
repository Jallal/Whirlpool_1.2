//
//  CalenderEvent.swift
//  WhirlpoolIndoors
//
//  Created by Gregory Richard on 9/23/15.
//  Copyright © 2015 Team Whirlpool. All rights reserved.
//

import Foundation
import UIKit


class CalenderEvent {
    //Variables that make up a calander event
    var date: NSDate?
    var title: String?
    var location: AnyObject?//CLLocation: this may be used to create a location
    var type: String? //This could be for the colored bar on the cell depending on event type
    
    
    
    
    
    init(CalenderEventData: [String: AnyObject]){
        if let d = CalenderEventData["date"] {
            date = d as? NSDate
        }
        if let t = CalenderEventData["title"] {
            title = t as? String
        }
        if let l = CalenderEventData["location"] {
            location = l
        }
        if let typ = CalenderEventData["type"] {
            type = typ as? String
        }
    }
    
    
    func getTitle()->String{
        return "needs implimentation"
    }
    
    func getDate()->String{
        return "12/11/2015 - 12/12/2015"
    }
    
    func getType()->UIColor{
        return UIColor.whiteColor()
    }
    
}