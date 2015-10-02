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
    var startDate: String?
    var endDate: String?
    var title: String?
    var location: String?//CLLocation: this may be used to create a location
    var type: String? //This could be for the colored bar on the cell depending on event type
    
    /*struct CalenaderEvents
    {
        let EventSummary: String
        let EventStartDate: String
        let EventEndDate : String
        let EventLocation : String
    }*/

    
    
    
    init(CalenderEventSummary: String?, EventStartDate: String?, EventEndDate: String?, EventLocation :String? ) {
        if let sd = EventStartDate {
            startDate = sd
        }
        
        if let t = CalenderEventSummary {
            title = t
        }
        if let l = EventLocation {
            location = l
        }
        if let ed = EventEndDate {
            endDate = ed
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