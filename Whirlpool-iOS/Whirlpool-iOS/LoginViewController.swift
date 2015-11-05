//
//  LoginViewController.swift
//  WhirlpoolIndoors
//
//  Created by Team Whirlpool on 9/10/15.
//  Copyright (c) 2015 Team Whirlpool. All rights reserved.
//

import UIKit

//var UserCalandenerInfo = [CalenaderEvents]()
var _userCalenderInfo: UserCalenderInfo?
let service = GTLServiceCalendar()
var _roomsData = RoomsData()

public class LoginViewController: UIViewController , NSXMLParserDelegate{
    
    
    //var _userCalenderInfo: UserCalenderInfo?
    
    @IBOutlet weak var GoogleView: UIView!
    private let kKeychainItemName = "Google Calendar API"
    private let kClientID = "656758157986-ipeuj79t544atfl6fuuc6ij9q7eqh8mh.apps.googleusercontent.com"
    private let kClientSecret = "9--EmDPAMnvbJFhGbWKQyw1p"
    private var accessToken = String()
    private var xmlParser = NSXMLParser()
    private var element = String()
    private var resEmail = String()
    private var resName = String()
    private var att = [String:String]()
    private var nextResourceUrlPage = "https://apps-apis.google.com/a/feeds/calendar/resource/2.0/whirlpool.com/"
    private var previousResourceUrlPage = String()
    private var daysToGrab = 1.0
    
    private let scopes = [kGTLAuthScopeCalendar, "https://apps-apis.google.com/a/feeds/calendar/resource/"] //Add in a scope for Calender Resource API
    
    let output = UITextView()
    


    
    // When the view loads, create necessary subviews
    // and initialize the Google Calendar API service
    override public func viewDidLoad() {
        super.viewDidLoad()
        output.frame = self.GoogleView.bounds
        output.editable = false
        output.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        output.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.GoogleView.addSubview(output);
        
        GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: kClientSecret
        )
        _roomsData.updateRoomsInfo();
        _roomsData.parseJson();

        
    }
    
    func httpCall(){
        let whirlpoolResourceUrl = NSURL(string: nextResourceUrlPage)
        let request = NSMutableURLRequest(URL: whirlpoolResourceUrl!)
        request.HTTPMethod = "GET"
        let headerToken = "Bearer " + accessToken
        request.allHTTPHeaderFields = ["Authorization" : headerToken]
        let queue:NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            var err: NSError?
            if err?.localizedDescription != nil
            {
                print("error:", err?.localizedDescription)
            }
            else
            {
                do {
                    self.xmlParser = NSXMLParser(data: data!)
                    self.xmlParser.delegate = self
                    self.previousResourceUrlPage = self.nextResourceUrlPage
                    if self.xmlParser.parse() {
                        if self.nextResourceUrlPage != self.previousResourceUrlPage {
                            self.httpCall()
                        }
                        else
                        {
                            //Make call to database
                            //self.pushRoomDataToDatabase()
                            self.performSegueWithIdentifier("MainPage", sender: nil)
                        }
                    }
                    else{
                        print("Darn xml parser")
                    }
                } catch let error as NSError {
                    print("error: ", error )
                }
                
            }
        })
        
    }
    
    // When the view appears, ensure that the Google Calendar API service is authorized
    // and perform API calls
    override public func viewDidAppear(animated: Bool) {
        if let authorizer = service.authorizer,
            canAuth = authorizer.canAuthorize where canAuth {
                fetchEvents()
                
        } else {
            presentViewController(
                createAuthController(),
                animated: true,
                completion: nil
            )
        }
    }
    
    // Construct a query and get a list of upcoming events from the user calendar
    public func fetchEvents(){
        let query = GTLQueryCalendar.queryForEventsListWithCalendarId("primary")
        query.maxResults = 10
        query.timeMin = GTLDateTime(date: NSDate(), timeZone: NSTimeZone.localTimeZone())
        query.timeMax = GTLDateTime(date: NSDate().dateByAddingTimeInterval(60.0*60.0*24.0*daysToGrab), timeZone: NSTimeZone.localTimeZone())
        query.singleEvents = true
        query.orderBy = kGTLCalendarOrderByStartTime
        service.executeQuery(
            query,
            delegate: self,
            didFinishSelector: "displayResultWithTicket:finishedWithObject:error:"
        )
        
    }
    
    
    
    
    // Display the start dates and event summaries in the UITextView
    public func displayResultWithTicket(
        ticket: GTLServiceTicket,
        finishedWithObject events : GTLCalendarEvents?,
        error : NSError?) {
            
            if let error = error {
                showAlertLogin("Error", message: error.localizedDescription)
                return
            }
            
            var eventString = ""
            if events?.items() != nil {
                _userCalenderInfo = UserCalenderInfo()
                if events!.items().count > 0 {
                    for event in events!.items() as! [GTLCalendarEvent] {
                        var location =  String()
                        if event.location != nil{
                            location = event.location
                        }
                        let start : GTLDateTime! = event.start.dateTime ?? event.start.date
                        let startingString = NSDateFormatter()
                        startingString.dateFormat = "hh:mm a"
                        let startString = startingString.stringFromDate(start.date)
                        
                        /***********************************/
                        let EndDate   : GTLDateTime! = event.end.dateTime ?? event.end.date
                        
                        let endingString = NSDateFormatter()
                        endingString.dateFormat = "hh:mm a"
                        
                        let endString = startingString.stringFromDate(EndDate.date)
                        /***********************************/
                        
                        eventString += "\(startString) - \(event.summary)\n"
                        
                        _userCalenderInfo!.addEventToCalender(CalenderEvent(CalenderEventSummary: event.summary,EventStartDate:startString,EventEndDate:endString,EventLocation :location, event:event ))
                    }
                } else {
                    eventString = "No upcoming events found."
                }
            }
            //output.text = eventString
            
            //self.httpCall()
            self.performSegueWithIdentifier("MainPage", sender: nil)
            
    }
    
    
    // Creates the auth controller for authorizing access to Google Calendar API
    private func createAuthController() -> GTMOAuth2ViewControllerTouch {
        let scopeString = scopes.joinWithSeparator(" ")
        return GTMOAuth2ViewControllerTouch(
            scope: scopeString,
            clientID: kClientID,
            clientSecret: kClientSecret,
            keychainItemName: kKeychainItemName,
            delegate: self,
            finishedSelector: "viewController:finishedWithAuth:error:"
        )
    }
    
    // Handle completion of the authorization process, and update the Google Calendar API
    // with the new credentials.
    func viewController(vc : UIViewController,
        finishedWithAuth authResult : GTMOAuth2Authentication, error : NSError?) {
            
            if let error = error {
                service.authorizer = nil
                showAlertLogin("Authentication Error", message: error.localizedDescription)
                return
            }
            accessToken = (authResult.accessToken)
            service.authorizer = authResult
            dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Helper for showing an alert
    func showAlertLogin(title : String, message: String) {
        let alert = UIAlertView(
            title: title,
            message: message,
            delegate: nil,
            cancelButtonTitle: "OK"
        )
        alert.show()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    
    public func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        
        if (elementName == "link" && attributeDict["rel"] == "next")  {
            nextResourceUrlPage = attributeDict["href"]!
            //print("This is the next Resource Page: " + nextResourceUrlPage)
        }
        
        if (elementName == "apps:property" ){
            if attributeDict["name"] == "resourceCommonName" {
                element = elementName
                att = attributeDict
                resName = att["value"]!
            }
            if attributeDict["name"] == "resourceEmail" {
                element = elementName
                att = attributeDict
            }
        }
        

        
    }
    
    public func parser(parser: NSXMLParser, foundCharacters string: String)
    {
        
        if element == ("apps:property") {
            if resName.rangeOfString("US - Benton Harbor") != nil {
                resEmail = att["value"]!
                let tempResName = resName
                resName = ""
                let newRoom = RoomData()
                newRoom.SetRoomEmail(resEmail)
                newRoom.SetRoomName(tempResName)
                _roomsData.addARoom(newRoom)
            }
            
            
        }
    }
    
    
    func pushRoomDataToDatabase(){
        for room in _roomsData.getAllRooms() {
            let roomLongName = room.GetRoomName()
            var splitRoomName = roomLongName.componentsSeparatedByString("-")
            
            if splitRoomName.count >= 4 {
                let locTemp = getAbbr(splitRoomName[2].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
                let roomTemp = splitRoomName[3].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                _roomsData.insertroominfo(locTemp, room: roomTemp, floor: "2", status: "Busy", email: room.GetRoomEmail(), ownership: "Online", resources: "TV", capacity: "5")
            }
        }
    }
    
    func getAbbr(location: String)->String{
        switch location {
        case "Riverview":
                return "BHR"
        case "Hilltop 150":
            return "HIL150"
        case "Hilltop 211":
            return "HIL211"
        case "St. Joe Tech Center":
            return "SJTech"
        default:
            return location
            
        }
    }
    
    
    
    
}


