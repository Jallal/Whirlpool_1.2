//
//  CalendarEventViewController.swift
//  Whirlpool-iOS
//
//  Created by Gregory Richard on 10/6/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import UIKit

extension NSDate {
    var startOfDay: NSDate {
        return NSCalendar.currentCalendar().startOfDayForDate(self)
    }
    
    var endOfDay: NSDate? {
        let components = NSDateComponents()
        components.day = 1
        components.second = -1
        return NSCalendar.currentCalendar().dateByAddingComponents(components, toDate: startOfDay, options: NSCalendarOptions())
    }
}


extension UITextView: UITextViewDelegate {
    
    // Placeholder text
    var placeholder: String? {
        
        get {
            // Get the placeholder text from the label
            var placeholderText: String?
            
            if let placeHolderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeHolderLabel.text
            }
            return placeholderText
        }
        
        set {
            // Store the placeholder text in the label
            let placeHolderLabel = self.viewWithTag(100) as! UILabel?
            if placeHolderLabel == nil {
                // Add placeholder label to text view
                self.addPlaceholderLabel(newValue!)
            }
            else {
                placeHolderLabel?.text = newValue
                placeHolderLabel?.sizeToFit()
            }
        }
    }
    
    // Hide the placeholder label if there is no text
    // in the text viewotherwise, show the label
    public func textViewDidChange(textView: UITextView) {
        
        let placeHolderLabel = self.viewWithTag(100)
        
        if !self.hasText() {
            // Get the placeholder label
            placeHolderLabel?.hidden = false
        }
        else {
            placeHolderLabel?.hidden = true
        }
    }
    
    // Add a placeholder label to the text view
    func addPlaceholderLabel(placeholderText: String) {
        
        // Create the label and set its properties
        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        placeholderLabel.frame.origin.x = 5.0
        placeholderLabel.frame.origin.y = 5.0
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.lightGrayColor()
        placeholderLabel.tag = 100
        
        // Hide the label if there is text in the text view
        placeholderLabel.hidden = (self.text.characters.count > 0)
        
        self.addSubview(placeholderLabel)
        self.delegate = self;
    }
    
}

class CalendarEventViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate, UITableViewDataSource, UITableViewDelegate {
    
    struct busyTime {
        let start: NSDate
        let end: NSDate
        let startString: String
        let endString: String
    }
    
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
    var freeBusyTimes = [(GTLDateTime,GTLDateTime)]()
    var selectedIndexPath:NSIndexPath?
    var startDate:NSDate?
    var endDate:NSDate?
    var eventTitle:String?
    var locationTitle:String?
    var descriptionTitle:String?
    var _roomFreeBusyTimes = [busyTime]()

    @IBAction func buttonCancel(sender: AnyObject) {
        checkObservers()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    @IBAction func buttonAddEvent(sender: AnyObject) {
        if editingEventBool {
            let editedEvent = createAnEvent()
            addEditedEvent(editedEvent)
            checkObservers()
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
        else {
            let newEvent = createAnEvent()
            checkFreeBusyTime(newEvent)
        }
        
        
    }
    
    func checkObservers(){
        if let startCell = eventStartCell {
            startCell.checkAndDeregister()
        }
        if let endCell = eventEndCell {
            endCell.checkAndDeregister()
        }
    }
    
    func checkIntervalOverlap()->Bool{
        if _roomFreeBusyTimes.count-1 >= 0 {
            for i in 0..._roomFreeBusyTimes.count-1{
                if((startDate?.timeIntervalSinceReferenceDate < _roomFreeBusyTimes[i].end.timeIntervalSinceReferenceDate) && (endDate?.timeIntervalSinceReferenceDate > _roomFreeBusyTimes[i].start.timeIntervalSinceReferenceDate)){
                    return true
                }
            }
        }
        return false
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
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            else {
                self.presentInvalidTimeRangeAlert()
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
    
    func checkFreeBusyTime(event: GTLCalendarEvent){
        if guest != String(){
            var freeBusyTicket = GTLServiceTicket()
            let requestItem = GTLCalendarFreeBusyRequestItem()
            requestItem.identifier = guest
            
            let now = GTLDateTime(date: startDate, timeZone: NSTimeZone.localTimeZone())
            print(NSTimeZone.localTimeZone())
            let endOfDay = GTLDateTime(date: NSDate().dateByAddingTimeInterval(60.0 * 60.0 * 24.0 * 1), timeZone: NSTimeZone.localTimeZone())
            
            let query = GTLQueryCalendar.queryForFreebusyQuery()
            query.items = [requestItem]
            query.timeZone = NSTimeZone.localTimeZone().name
            query.maxResults = 20
            query.timeMin = now
            query.timeMax = endOfDay
            query.singleEvents = true
            freeBusyTicket = service.executeQuery(query, completionHandler: { (ticket, object, error) -> Void in
                if error == nil {
                    let freeBusyResponse = object as! GTLCalendarFreeBusyResponse
                    let responseCal = freeBusyResponse.calendars
                    var properties = responseCal.additionalProperties()
                    let calBusyTimes = properties[self.guest]?.busy
                    if calBusyTimes! != nil {
                        for period in calBusyTimes! {
                            print(period.start as GTLDateTime)
                            print(period.end as GTLDateTime)
                            let convStartDate = period.start as GTLDateTime
                            let convEndDate = period.end as GTLDateTime
                            let finStartDate = NSDateFormatter.localizedStringFromDate(convStartDate.date, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
                            let finEndDate = NSDateFormatter.localizedStringFromDate(convEndDate.date, dateStyle: NSDateFormatterStyle.ShortStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
                            let tempBusy = busyTime.init(start: convStartDate.date, end: convEndDate.date, startString: finStartDate, endString: finEndDate)
                            self._roomFreeBusyTimes.append(tempBusy)
                        }
                    }
                    if self.checkIntervalOverlap() {
                        self.presentBusyAlert(event)
                    }
                    else{
                        self.checkObservers()
                        self.addNewEvent(event)
                    }
                }
                else {
                    print("Error: ", error)
                    return
                }
            })
        }
        else{
            self.checkObservers()
            self.addNewEvent(event)
        }
    }
    
    func presentBusyAlert(event: GTLCalendarEvent){
        var message = String()
        for i in 0..._roomFreeBusyTimes.count-1{
            message += _roomFreeBusyTimes[i].startString + "-" + _roomFreeBusyTimes[i].endString + "\n"
        }
        let alertController = UIAlertController(title: "Busy Times", message: message, preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let destroyAction = UIAlertAction(title: "Book Anyways", style: .Destructive) { (action) in
            self.checkObservers()
            self.addNewEvent(event)
        }
        alertController.addAction(destroyAction)
        presentViewController(alertController, animated: true) { () -> Void in
        }
    }
    
    
    func presentInvalidTimeRangeAlert(){
        var message = "Please choose a  earlier starting\n then end time."
        let alertController = UIAlertController(title: "Invalid Time Range", message: message, preferredStyle: .Alert)
        presentViewController(alertController, animated: true) { () -> Void in
            sleep(2)
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
    }


    
//    func textFieldShouldReturn(textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        return false
//    }
//    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
//        if text == "\n"{
//            textView.resignFirstResponder()
//            return false
//        }
//        return true
//    }
    
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
            
            eventTitleCell = cell
            eventTitleCell.setCellInputTextHeight()
            if eventTitle != nil {
                eventTitleCell.cellInputText.text = eventTitle
            }else{
                cell.cellInputText.placeholder = "Enter Title"
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
            
            eventLocationCell = cell
            eventLocationCell.cellImage.image = UIImage(named: "Location.png")
            eventLocationCell.setCellInputTextHeight()
            if locationTitle != nil {
                eventLocationCell.cellInputText.text = locationTitle
            }else{
            cell.cellInputText.placeholder = "Location"
            }
            return eventLocationCell
        case 4:
            let cell = tableView.dequeueReusableCellWithIdentifier("addEventCell", forIndexPath: indexPath) as! AddEventTableViewCell
            
            eventDescriptionCell = cell
            eventDescriptionCell.cellImage.image = UIImage(named: "Add Note.png")
            eventDescriptionCell.setCellInputTextHeight()
            if descriptionTitle != nil {
                eventDescriptionCell.cellInputText.text = descriptionTitle
            }else{
                cell.cellInputText.placeholder = "Add Note"
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
