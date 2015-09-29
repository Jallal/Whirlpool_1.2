//
//  LoginViewController.swift
//  WhirlpoolIndoors
//
//  Created by Team Whirlpool on 9/10/15.
//  Copyright (c) 2015 Team Whirlpool. All rights reserved.
//

import UIKit


var UserCalandenerInfo = [CalenaderEvents]()

public class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var GoogoleView: UIView!
    private let kKeychainItemName = "Google Calendar API"
    private let kClientID = "656758157986-ipeuj79t544atfl6fuuc6ij9q7eqh8mh.apps.googleusercontent.com"
    private let kClientSecret = "9--EmDPAMnvbJFhGbWKQyw1p"
    
    private let scopes = [kGTLAuthScopeCalendarReadonly]
    
    private let service = GTLServiceCalendar()
    let output = UITextView()
    
    // When the view loads, create necessary subviews
    // and initialize the Google Calendar API service
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        output.frame = self.GoogoleView.bounds
        output.editable = false
        output.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        output.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.GoogoleView.addSubview(output);
        
        GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(
            kKeychainItemName,
            clientID: kClientID,
            clientSecret: kClientSecret
        )
        
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
        finishedWithObject events : GTLCalendarEvents,
        error : NSError?) {
          
            if let error = error {
                showAlert("Error", message: error.localizedDescription)
                return
            }
            
           var eventString = ""
            
            if events.items().count > 0 {
                for event in events.items() as! [GTLCalendarEvent] {
                    var location = event.location;
                    var start : GTLDateTime! = event.start.dateTime ?? event.start.date
                    /*var startString = NSDateFormatter.localizedStringFromDate(
                        start.date,
                        dateStyle: .ShortStyle,
                        timeStyle: .ShortStyle
                    )*/
                    var startingString = NSDateFormatter()
                    startingString.dateFormat = "hh:mm a"
                    var startString = startingString.stringFromDate(start.date)
                    
                    /***********************************/
                    var EndDate   : GTLDateTime! = event.end.dateTime ?? event.end.date
                    /*var endString = NSDateFormatter.localizedStringFromDate(
                        EndDate.date,
                        dateStyle: .ShortStyle,
                        timeStyle: .ShortStyle
                    )*/
                  
                    var endingString = NSDateFormatter()
                    endingString.dateFormat = "hh:mm a"
                    
                    var endString = startingString.stringFromDate(EndDate.date)
                    /***********************************/
                    
                    eventString += "\(startString) - \(event.summary)\n"
                
                    
                    UserCalandenerInfo += [CalenaderEvents(EventSummary: event.summary,EventStartDate:startString,EventEndDate:endString,EventLocation :location )]
                }
            } else {
                eventString = "No upcoming events found."
            }
            
            //output.text = eventString
            
            
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
                showAlert("Authentication Error", message: error.localizedDescription)
                return
            }
            
            service.authorizer = authResult
            dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Helper for showing an alert
    func showAlert(title : String, message: String) {
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
    
    
}


