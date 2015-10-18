//
//  RoomInfoViewController.swift
//  
//
//  Created by Jallal Elhazzat on 9/17/15.
//
//
import GoogleMaps
import UIKit
import CoreData




class RoomInfoViewController: UIViewController,UIWebViewDelegate,NSXMLParserDelegate {

    struct busyTime {
        let start: NSDate
        let end: NSDate
        let startString: String
        let endString: String
    }
    
    @IBOutlet weak var roomInfo: UITableView!
    
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var RoomNameLabel: UILabel!
    
    internal var _room = RoomData()
    @IBAction func favoriteButton(sender: UIButton) {
        let alert = UIAlertController(title: _room.GetRoomName(), message: "New Favorite Added", preferredStyle: .Alert)
        let attributeString = NSAttributedString(string: "New Favorite", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(15),
            NSBackgroundColorDocumentAttribute: UIColor.blueColor()])
        alert.setValue(attributeString, forKey: "attributedMessage")

        //Add to favorite Data Core right here
        self.saveFavoriteRoom(_room)
        presentViewController(alert, animated: true) { () -> Void in
            sleep(1)
            alert.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    internal var _freeBusyDayInterval = 31.0
    internal var _roomFreeBusyTimes = [busyTime]()
    @IBAction func direction(sender: AnyObject) {
        
         //self.performSegueWithIdentifier("FullView", sender: nil)
       
        
        
    }
    
    
    
    
    var items = ["Hilltop 211","10 people","2 TVs","Phone"]
    //var items  = _room.GetRoomResources();
    
    
    
    override func viewWillAppear(animated: Bool) {
        if let url = NSBundle.mainBundle().URLForResource("File", withExtension: "html",subdirectory:"web"){
            let fragUrl = NSURL(string:"#FRAG_URL",relativeToURL:url)!
            let request = NSURLRequest(URL:fragUrl)
        }
        
        if _room.GetRoomName() != "" {
            RoomNameLabel.text = _room.GetRoomName()
        }
        
        freeBusyTimesGetRequest(_room.GetRoomEmail())
        
    }
    
    
    
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let url = NSURL (string: "http://micello.com/m/23640");
        //let requestObj = NSURLRequest(URL: url!);
        //roomView.loadRequest(requestObj);
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func saveFavoriteRoom(room: RoomData){
        let appDelagate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelagate.managedObjectContext
        
        
        let entity = NSEntityDescription.entityForName("Favorites", inManagedObjectContext: managedContext)
        
        let favoriteRoom = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        favoriteRoom.setValue(room.GetRoomName(), forKey: "roomName")
        favoriteRoom.setValue(room.GetRoomEmail(), forKey: "roomEmail")
        
        //4
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
    func freeBusyTimesGetRequest(roomEmail: String) {
        var freeBusyTicket = GTLServiceTicket()
        let requestItem = GTLCalendarFreeBusyRequestItem()
        requestItem.identifier = roomEmail
        
        let now = GTLDateTime(date: NSDate(), timeZone: NSTimeZone.localTimeZone())
        print(NSTimeZone.localTimeZone())
        let endOfDay = GTLDateTime(date: NSDate().dateByAddingTimeInterval(60.0 * 60.0 * 24.0 * _freeBusyDayInterval), timeZone: NSTimeZone.localTimeZone())
        
        let query = GTLQueryCalendar.queryForFreebusyQuery()
        query.items = [requestItem]
        query.timeZone = NSTimeZone.localTimeZone().name
        query.maxResults = 20
        query.timeMin = now
        query.timeMax = endOfDay
        query.singleEvents = true
        //query.orderBy = kGTLCalendarOrderByStartTime
        freeBusyTicket = service.executeQuery(query, completionHandler: { (ticket, object, error) -> Void in
            if error == nil {
                let freeBusyResponse = object as! GTLCalendarFreeBusyResponse
                let responseCal = freeBusyResponse.calendars
                var properties = responseCal.additionalProperties()
                let calBusyTimes = properties[roomEmail]?.busy
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
            }
            else {
                print("Error: ", error)
                return
            }
            self.roomInfo.reloadData()
        })
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _roomFreeBusyTimes.count
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
    
            cell!.textLabel?.textColor = UIColor.whiteColor()
            let cellTextTimeZone = _roomFreeBusyTimes[indexPath.row].startString  + " - " + _roomFreeBusyTimes[indexPath.row].endString
            cell!.textLabel!.text = cellTextTimeZone
            return cell!
        
    }
    
    
    func webView(webView:UIWebView, shouldStartLoadingWithRequest request:NSURLRequest,navigationType: UIWebViewNavigationType)->Bool
    {
        NSLog("request:\(request)")
        
        if let scheme = request.URL?.scheme{
            if(scheme == "Jallal"){
                NSLog("we got Jallal request:\(scheme)");
                if let result = webView.stringByEvaluatingJavaScriptFromString("Jallal.SomeJavaScriptFunc()"){
                    NSLog("Result:\(result)")
                }
                return false;
            }
        }
        
        return true;
        
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "bookRoomSeg" {
            var eventVC = segue.destinationViewController as! CalendarEventViewController
            
            eventVC.guest = _room.GetRoomEmail()
            eventVC.location = _room.GetRoomName()
            
            
        }
    }
    

    
    
}
