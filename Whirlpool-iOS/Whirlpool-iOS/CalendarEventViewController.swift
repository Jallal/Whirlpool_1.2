//
//  CalendarEventViewController.swift
//  Whirlpool-iOS
//
//  Created by Gregory Richard on 10/6/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import UIKit

class CalendarEventViewController: UIViewController {

    @IBOutlet weak var eventTitle: UITextField!
    
    @IBOutlet weak var eventLocation: UITextField!
    
    @IBOutlet weak var eventDatePicker: UIDatePicker!
    
    @IBOutlet weak var eventDescription: UITextView!
    
    var guest = String()
    var location = String()
    
    
    @IBAction func buttonCreateEvent(sender: AnyObject) {
        let newEvent = createAnEvent()
        addNewEvent(newEvent)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        eventDescription.layer.cornerRadius = 5
        eventDescription.layer.borderColor = UIColor.grayColor().CGColor
        eventDescription.layer.borderWidth = 0.5
        
    }
    
    override func viewDidLoad() {
        eventLocation.text = location
    }
    
    //Create an event to add to the calender
    internal func createAnEvent()->GTLCalendarEvent{
        let newEvent = GTLCalendarEvent()
        newEvent.summary = eventTitle.text
        newEvent.descriptionProperty = eventDescription.text
        newEvent.location = eventLocation.text
        let startDate = NSDate(timeInterval: 3600, sinceDate: NSDate())
        
        newEvent.start = GTLCalendarEventDateTime()
        newEvent.start.dateTime = GTLDateTime(date: startDate, timeZone: NSTimeZone.localTimeZone())
        
        let endDate = NSDate(timeInterval: 3600 * 2, sinceDate: NSDate())
        
        newEvent.end = GTLCalendarEventDateTime()
        newEvent.end.dateTime = GTLDateTime(date: endDate, timeZone: NSTimeZone.localTimeZone())
        if guest != String() {
            let eventGuest = GTLCalendarEventAttendee()
            eventGuest.email = guest
            eventGuest.displayName = location
            eventGuest.resource = true
            newEvent.attendees = [eventGuest]
        }
        return newEvent
        
        
    }
    
    internal func addNewEvent(event : GTLCalendarEvent){
        var editEventTicket = GTLServiceTicket()
        let query =  GTLQueryCalendar.queryForEventsInsertWithObject(event, calendarId: "primary")
        editEventTicket = service.executeQuery(query, completionHandler: { (ticket, object, error) -> Void in
            //editEventTicket = nil
            if error == nil {
                let event = object as! GTLCalendarEvent
                NSLog(event.summary)
            }
            else {
                NSLog(error.localizedDescription)
            }
        })
    }

    
    
    
    
    
}
