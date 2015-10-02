//
//  UserCalenderInfo.swift
//  Whirlpool-iOS
//
//  Created by Gregory Richard on 9/29/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation
import UIKit


class UserCalenderInfo {
    var  CalenderInfo = [CalenderEvent]()
    
     func addEventToCalender(event: CalenderEvent){
        CalenderInfo.append(event)
    }
    
    func getCalenderEventsCount()->Int {
        return CalenderInfo.count
    }
    
    func getCalenderInfo()->[CalenderEvent] {
        if CalenderInfo.count == 0 {
            var tempCalender = [CalenderEvent]()
            tempCalender.append(CalenderEvent(CalenderEventSummary: "No Events Today", EventStartDate: "", EventEndDate: "", EventLocation: ""))
            return tempCalender
        }
        
        return CalenderInfo
    }
    
}