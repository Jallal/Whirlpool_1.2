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
    var event: GTLCalendarEvent!
    
    
    init(CalenderEventSummary: String?, EventStartDate: String?, EventEndDate: String?, EventLocation :String? , event: GTLCalendarEvent!) {
        if let sd = EventStartDate {
            startDate = sd
        }
        
        if let t = CalenderEventSummary {
            title = t
        }
        if let l = EventLocation {
            
            if(EventLocation != nil){
            location = l
            }else{
                location = String()
                
            }
        }
        if let ed = EventEndDate {
            endDate = ed
        }
        self.event = event
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
    
    func getStartTimeDateObject()->GTLDateTime! {
        return event.start.dateTime
    }
    
    func getEndTimeDateObject()->GTLDateTime! {
        return event.end.dateTime
    }
    
    func getTimeUntilEventStart()->String {
        let start : GTLDateTime! = event.start.dateTime ?? event.start.date
        let timeElapsed = start.date.timeIntervalSinceDate(NSDate())
        let timeElapsedInHours = (timeElapsed/60.0)/60.0
        
        let timeUntil = determineStringOfElapsedHours(timeElapsedInHours)
        
        return "\(timeUntil)"
    }
    
    func determineStringOfElapsedHours(time: Double)->String {
        //var formatter = NSNumberFormatter()
        if (time / 24.0) >= 1 {
            let days = time / 24.0
            return "\(Int(days)) d"
        }
            //If the time interval is less than a day
        else {
            //Return the minutes specifically if it is less than an hour
            if time < 1.0 {
                let finalTime = Int(time * 100)
                return NSString(format: "%i min", finalTime) as String
            }
                //If it is greater than an hour return the interval for time of .5 hour intervals
            else{
                if (time % 1) > 0.5 {
                    let finalTime = Int(time)
                    return NSString(format: "%i.5 hr", finalTime) as String
                }
                else {
                    let finalTime = Int(time)
                    return NSString(format: "%i hr", finalTime) as String
                }
            }
            
        }
    }
    
    
    internal func deleteNewEvent(){
        var deleteEventTicket = GTLServiceTicket()
        let query =  GTLQueryCalendar.queryForEventsDeleteWithCalendarId("primary", eventId: self.event.identifier)
        deleteEventTicket = service.executeQuery(query, completionHandler: { (ticket, object, error) -> Void in
            if error == nil {
                print("No Error")
            }
            else {
                NSLog(error.localizedDescription)
            }
        })
    }
    
    
    
    
}