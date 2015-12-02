//
//  CalendarEventViewController.swift
//  Whirlpool-iOS
//
//  Created by Gregory Richard on 10/6/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import UIKit

class CalendarEventViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var addEventTableView: UITableView!
    var editingEventBool = false
    var editingEvent:CalenderEvent?
    
    var guest = String()
    var location = String()
    var kbHeight: CGFloat!

    @IBOutlet weak var addOrEditEventButton: UIBarButtonItem!
    
    var startEventHeight = PickerTableViewCell.defaultHeight
    var endEventHeight = PickerTableViewCell.defaultHeight
    var eventStartCell:PickerTableViewCell!
    var eventEndCell:PickerTableViewCell!
    var eventTitleCell:AddEventTableViewCell!
    var eventLocationCell:AddEventTableViewCell!
    var eventDescriptionCell:AddEventTableViewCell!
    var selectedIndexPath:NSIndexPath?
    var startDate:NSDate?
    var endDate:NSDate?
    var eventTitle:String?
    var locationTitle:String?
    var descriptionTitle:String?

    @IBAction func buttonCancel(sender: AnyObject) {
        checkObservers()
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
        checkObservers()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func checkObservers(){
        if let startCell = eventStartCell {
            startCell.checkAndDeregister()
        }
        if let endCell = eventEndCell {
            endCell.checkAndDeregister()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        self.addEventTableView.delegate = self
        self.addEventTableView.dataSource = self
        if self.location != String(){
            locationTitle = self.location
        }
        if editingEventBool {
            setViewToEditing()
        }
        
        //Set up the Navigation bar colors
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 130.0/255.0, green: 230.0/255.0, blue: 192.0/255.0, alpha: 1)

        }
    
    override func viewDidLoad() {

    }
    
    
    internal func setViewToEditing(){
        startDate = editingEvent?.event.start.dateTime.date!
        endDate = editingEvent?.event.end.dateTime.date!
        eventTitle = editingEvent?.title
        locationTitle = editingEvent?.location
        descriptionTitle = editingEvent?.event.descriptionProperty
    }
    
    //Create an event to add to the calender
    internal func createAnEvent()->GTLCalendarEvent{
        let newEvent = GTLCalendarEvent()
        newEvent.summary = eventTitleCell.cellInputText.text
        newEvent.descriptionProperty = eventDescriptionCell.cellInputText.text
        newEvent.location = eventLocationCell.cellInputText.text
        let startDate = eventStartCell.datePicker.date
        
        newEvent.start = GTLCalendarEventDateTime()
        newEvent.start.dateTime = GTLDateTime(date: startDate, timeZone: NSTimeZone.localTimeZone())
        
        let endDate = eventEndCell.datePicker.date
        
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row{
        case 1:
            let height = ((indexPath == selectedIndexPath) ? PickerTableViewCell.exandedHeight : PickerTableViewCell.defaultHeight)
            return height
        case 2:
            let height = ((indexPath == selectedIndexPath) ? PickerTableViewCell.exandedHeight : PickerTableViewCell.defaultHeight)
            return height
        case 4:
            return view.bounds.size.height * (3/5)
        default:
            return 44.0
        }
    }
    
    func checkCells(){
        if eventEndCell != nil {
            endDate = eventEndCell.datePicker.date
        }
        if eventStartCell != nil {
            startDate = eventStartCell.datePicker.date
        }
        if eventTitleCell != nil {
            eventTitle = eventTitleCell.cellInputText.text
        }
        if eventLocationCell != nil {
            locationTitle = eventLocationCell.cellInputText.text
        }
        if eventDescriptionCell != nil {
            descriptionTitle = eventDescriptionCell.cellInputText.text
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        checkCells()
        switch indexPath.row{
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("addEventCell", forIndexPath: indexPath) as! AddEventTableViewCell
            cell.cellInputText.text = "Enter Title"
            eventTitleCell = cell
            eventTitleCell.setCellInputTextHeight()
            if eventTitle != nil {
                eventTitleCell.cellInputText.text = eventTitle
            }
            return eventTitleCell
        case 1:
                let cell = tableView.dequeueReusableCellWithIdentifier("datePickerCell", forIndexPath: indexPath) as! PickerTableViewCell
                cell.datePickerCellLabel.text = "Start"
                eventStartCell = cell
                eventStartCell!.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0)
                eventStartCell?.checkWhichDatePickerAndSetImage()
                eventStartCell.datePicker.timeZone = NSTimeZone.localTimeZone()
                eventStartCell.datePicker.minuteInterval = 5
                eventStartCell.datePicker.minimumDate = NSDate()
                if startDate != nil {
                    eventStartCell.datePicker.date = startDate!
                }
                return eventStartCell
        case 2:
                let cell = tableView.dequeueReusableCellWithIdentifier("datePickerCell", forIndexPath: indexPath) as! PickerTableViewCell
                cell.datePickerCellLabel.text = "End"
                eventEndCell = cell
                eventEndCell?.checkWhichDatePickerAndSetImage()
                eventEndCell.datePicker.timeZone = NSTimeZone.localTimeZone()
                eventEndCell.datePicker.minuteInterval = 5
                eventEndCell.datePicker.minimumDate = NSDate()
                if endDate != nil {
                    eventEndCell.datePicker.date = endDate!
                }
                return eventEndCell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier("addEventCell", forIndexPath: indexPath) as! AddEventTableViewCell
            cell.cellInputText.text = "Location"
            eventLocationCell = cell
            eventLocationCell.cellImage.image = UIImage(named: "Location.png")
            eventLocationCell.setCellInputTextHeight()
            if locationTitle != nil {
                eventLocationCell.cellInputText.text = locationTitle
            }
            return eventLocationCell
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier("addEventCell", forIndexPath: indexPath) as! AddEventTableViewCell
            cell.cellInputText.text = "Add Note"
            eventDescriptionCell = cell
            eventDescriptionCell.cellImage.image = UIImage(named: "Add Note.png")
            eventDescriptionCell.setCellInputTextHeight()
            if descriptionTitle != nil {
                eventDescriptionCell.cellInputText.text = descriptionTitle
            }
            return eventDescriptionCell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 1) || (indexPath.row == 2) {
            let previousIndexPath = selectedIndexPath
            selectedIndexPath = ((selectedIndexPath == indexPath) ? nil : indexPath)
            var indexPaths = [NSIndexPath]()
            if let previous = previousIndexPath{
                indexPaths.append(previous)
            }
            if let current = selectedIndexPath {
                indexPaths.append(current)
            }
            if indexPaths.count > 0 {
                tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
            }
        }else{
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
    }
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        if (indexPath.row == 1) || (indexPath.row == 2) {
            (cell as! PickerTableViewCell).watchFrameChanges()
        }
    }

    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
        if (indexPath.row == 1) || (indexPath.row == 2) {
            let cellTemp = cell as! PickerTableViewCell
            if cellTemp.isReg {
                cellTemp.ignoreFrameChanges()
            }
        }
    }
    
}
