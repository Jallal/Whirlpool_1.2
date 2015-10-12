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

public class LoginViewController: UIViewController , NSXMLParserDelegate{
    //var _userCalenderInfo: UserCalenderInfo?
    
    @IBOutlet weak var GoogleView: UIView!
    private let kKeychainItemName = "Google Calendar API"
    private let kClientID = "656758157986-ipeuj79t544atfl6fuuc6ij9q7eqh8mh.apps.googleusercontent.com"
    private let kClientSecret = "9--EmDPAMnvbJFhGbWKQyw1p"
    private var accessToken = String()
    private var xmlParser = NSXMLParser()
    private var whirlpoolEmails = [String()]
    private var element = String()
    
    
    
    
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
        
        
        
        
    }
    
    func httpCall(){
        let whirlpoolResourceUrl = NSURL(string: "https://apps-apis.google.com/a/feeds/calendar/resource/2.0/whirlpool.com/")
        let request = NSMutableURLRequest(URL: whirlpoolResourceUrl!)
        request.HTTPMethod = "GET"
        let headerToken = "Bearer " + accessToken
        request.allHTTPHeaderFields = ["Authorization" : headerToken]
        let queue:NSOperationQueue = NSOperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
            var err: NSError?
            if err?.localizedDescription != nil
            {
                print("hi")
            }
            else
            {
                do {
                    //let jsonDict = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? NSDictionary
                    self.xmlParser = NSXMLParser(data: data!)
                    self.xmlParser.delegate = self
                    if self.xmlParser.parse() {
                        print("xml parse: ", self.xmlParser)
                    }
                    else{
                        print("Darn xml parser")
                    }
                } catch let error as NSError {
                    print("dang, couldn't make into json obj", response )
                }
                
            }
        })
        /*NSURLConnection.sendAsynchronousRequest( request, queue: NSOperationQueue(), completionHandler:{
        (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
        if let anError = error
        {
        // got an error in getting the data, need to handle it
        print("error calling GET on Google Resource")
        }
        else // no error returned by URL request
        {
        
        print("No error")
        // parse the result as json, since that's what the API provides
        //var jsonError: NSError?
        //let post = NSJSONSerialization.JSONObjectWithData(data!, options: nil) as! NSDictionary
        /*if let aJSONError = jsonError
        {
        // got an error while parsing the data, need to handle it
        print("error parsing /posts/1")
        }
        else
        {
        // now we have the post, let's just print it to prove we can access it
        println("The post is: " + post.description)
        
        // the post object is a dictionary
        // so we just access the title using the "title" key
        // so check for a title and print it if we have one
        if var postTitle = post["title"] as? String
        {
        print("The title is: " + postTitle)
        }
        }*/
        }
        })*/
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
                        var location =  ""
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
                        
                        _userCalenderInfo!.addEventToCalender(CalenderEvent(CalenderEventSummary: event.summary,EventStartDate:startString,EventEndDate:endString,EventLocation :location ))
                    }
                } else {
                    eventString = "No upcoming events found."
                }
            }
            //output.text = eventString
            
            self.httpCall()
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
        element = elementName
        print(elementName)
    }
    public func parser(parser: NSXMLParser!, foundCharacters string: String!)
    {
        if element == ("value") {
            whirlpoolEmails.append(element)
        }
    }
    
}


