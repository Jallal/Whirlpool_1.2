//
//  CalendarEventViewController.swift
//  Whirlpool-iOS
//
//  Created by Gregory Richard on 10/6/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import UIKit

class CalendarEventViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var EndEvent: UILabel!
    @IBOutlet weak var startEvent: UILabel!
    @IBOutlet weak var eventTitle: UITextField!
    
    @IBOutlet weak var eventLocation: UITextField!
    
    @IBOutlet weak var eventDatePickerStart: UIDatePicker!
    @IBOutlet weak var eventDatePickerEnd: UIDatePicker!
    @IBOutlet weak var eventDescription: UITextView!
    @IBAction func MyDatePicker(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let strDate = dateFormatter.stringFromDate(eventDatePickerStart.date)
        self.startEvent.text = strDate
    }
    
    @IBAction func datePickerEndTimeAction(sender: AnyObject) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let endDate = dateFormatter.stringFromDate(eventDatePickerEnd.date)
        self.EndEvent.text = endDate
        
    }
    
    @IBOutlet weak var addOrEditEventButton: UIBarButtonItem!
    
   
    
    
    var editingEventBool = false
    var editingEvent:CalenderEvent?
    
    var guest = String()
    var location = String()
    var kbHeight: CGFloat!
    
    @IBAction func buttonCancel(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    @IBAction func buttonAddEvent(sender: AnyObject) {
        if editingEventBool {
            let editedEvent = createAnEvent()
            addEditedEvent(editedEvent)
        }
        else {
            let newEvent = createAnEvent()
            addNewEvent(newEvent)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if editingEventBool {
            setViewToEditing()
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        eventDescription.layer.cornerRadius = 5
        eventDescription.layer.borderColor = UIColor.grayColor().CGColor
        eventDescription.layer.borderWidth = 0.5
        }
    
    override func viewDidLoad() {
        eventTitle.delegate = self
        eventLocation.delegate = self
        eventDescription.delegate = self
        eventLocation.text = location
    }
    
    
    internal func setViewToEditing(){
        self.title = "Editing Event"
        eventTitle.text = editingEvent?.title
        eventLocation.text = editingEvent?.location
        eventDescription.text = editingEvent?.event.descriptionProperty
        eventDatePickerStart.date = (editingEvent?.event.start.dateTime.date)!
        eventDatePickerEnd.date = (editingEvent?.event.end.dateTime.date)!
    }
    
    func editEventButtonClicked() {
        print("In the edit event button")
    }
    
    //Create an event to add to the calender
    internal func createAnEvent()->GTLCalendarEvent{
        let newEvent = GTLCalendarEvent()
        newEvent.summary = eventTitle.text
        newEvent.descriptionProperty = eventDescription.text
        newEvent.location = eventLocation.text
        let startDate = eventDatePickerStart.date
        
        newEvent.start = GTLCalendarEventDateTime()
        newEvent.start.dateTime = GTLDateTime(date: startDate, timeZone: NSTimeZone.localTimeZone())
        
        let endDate = eventDatePickerEnd.date
        
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
        var addEventTicket = GTLServiceTicket()
        let query =  GTLQueryCalendar.queryForEventsInsertWithObject(event, calendarId: "primary")
        addEventTicket = service.executeQuery(query, completionHandler: { (ticket, object, error) -> Void in
            if error == nil {
                print("Added Sucessfully")
            }
            else {
                NSLog(error.localizedDescription)
            }
        })
    }
    
    internal func addEditedEvent(event: GTLCalendarEvent){
        var editEventTicket = GTLServiceTicket()
        let query =  GTLQueryCalendar.queryForEventsUpdateWithObject(event, calendarId: "primary", eventId: editingEvent?.event.identifier)
        editEventTicket = service.executeQuery(query, completionHandler: { (ticket, object, error) -> Void in
            if error == nil {
                print("Edited Sucessfully")
            }
            else {
                NSLog(error.localizedDescription)
            }
        })
    }

    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
}
