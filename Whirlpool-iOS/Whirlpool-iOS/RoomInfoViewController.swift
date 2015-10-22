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
import Foundation




class RoomInfoViewController: UIViewController,NSXMLParserDelegate,CLLocationManagerDelegate,GMSMapViewDelegate,GMSIndoorDisplayDelegate {

    struct busyTime {
        let start: NSDate
        let end: NSDate
        let startString: String
        let endString: String
    }
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var roomInfo: UITableView!
    @IBOutlet weak var RoomNameLabel: UILabel!
    internal var _room = RoomData()
    internal var _freeBusyDayInterval = 31.0
    internal var _roomFreeBusyTimes = [busyTime]()
    let locationManager = CLLocationManager()
    var items : Array<String> = []

    
    
    
    
    
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
        items = _room.GetRoomResources();
       
    }
    
      /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        
        // self.performSegueWithIdentifier("FullView", sender: nil)
        
        //if (segue.identifier == "RoomInfo") {
            
            // initialize new view controller and cast it as your view controller
            var viewController = segue.destinationViewController as! RoomInfoViewController
            // your new view controller should have property that will store passed value
            viewController._room = _room
       // }
       
    }*/
    
    
    
    
    //var items = ["Hilltop 211","10 people","2 TVs","Phone"]
    
    
    
    
    override func viewWillAppear(animated: Bool) {
        
        if _room.GetRoomName() != "" {
            RoomNameLabel.text = _room.GetRoomName()
        }
        
        freeBusyTimesGetRequest(_room.GetRoomEmail())
        updateLocation(true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.mapView.delegate = self
        self.reDraw()
        
     
    }
    func updateLocation(running : Bool){
        
        let status = CLLocationManager.authorizationStatus()
        if running{
            
            locationManager.startUpdatingLocation()
            self.mapView.myLocationEnabled = true
            self.mapView.settings.myLocationButton = true
        }else{
            locationManager.startUpdatingLocation()
            self.mapView.settings.myLocationButton = false
            self.mapView.myLocationEnabled = false
        }
    }
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        var position = _room.GetroomCenter();
    
        
        if(CLLocationCoordinate2DIsValid(position)){
             _room.SetIsSelected(true);
            self.mapView.clear();
            self.reDraw();
            mapView.camera = GMSCameraPosition(target: position, zoom: 20, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
            
        }else{
            position = CLLocationCoordinate2D(latitude: 42.1124531749125, longitude: -86.4693216079577)
            mapView.camera = GMSCameraPosition(target: position, zoom: 20, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
      
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
    
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "bookRoomSeg" {
            var eventVC = segue.destinationViewController as! CalendarEventViewController
            
            eventVC.guest = _room.GetRoomEmail()
            eventVC.location = _room.GetRoomName()
            
        }
        
        if (segue.identifier == "MainNavView") {
        // initialize new view controller and cast it as your view controller
        var viewController = segue.destinationViewController as! NavigationMainViewController
        // your new view controller should have property that will store passed value
         viewController._room = _room
         }
        
    }
    
    func updateUIMap(){
        for room in _roomsData.getAllRooms(){
            for rect in room.GetRoomCoordinates(){
                var polygon = GMSPolygon(path: rect)
                if(room.GetIsSelected()){
                    var position = room.GetroomCenter()
                    print(position);
                    var marker = GMSMarker(position: position)
                    marker.appearAnimation = kGMSMarkerAnimationPop
                    // marker.icon = UIImage(named: "restroom.jpg")
                    marker.icon = UIImage(named: "mapannotation.png")
                    marker.flat = true
                    marker.map = self.mapView
                    polygon.fillColor = UIColor(red:(137/255.0), green:196/255.0, blue:244/255.0, alpha:1.0);
                }else{
                    polygon.fillColor = UIColor(red:(255/255.0), green:249/255.0, blue:236/255.0, alpha:1.0);
                }
                
                if(room.GetRoomName()=="B250"){
                    var position = room.GetroomCenter()
                    var restroom = GMSMarker(position: position)
                    restroom.icon = UIImage(named: "wbathroom.jpg")
                    restroom.flat = true
                    restroom.map = self.mapView
                }
                if((room.GetRoomName()=="B240")||(room.GetRoomName()=="B215")){
                    
                    var position = room.GetroomCenter()
                    var conference = GMSMarker(position: position)
                    conference.icon = UIImage(named: "conference.jpg")
                    conference.flat = true
                    conference.map = self.mapView
                }
                if((room.GetRoomName()=="B218")){
                    var position = room.GetroomCenter()
                    var exit = GMSMarker(position: position)
                    exit.icon = UIImage(named: "mbathroom.jpg")
                    exit.flat = true
                    exit.map = self.mapView
                }
                if((room.GetRoomName()=="B242")){
                    var position = room.GetroomCenter()
                    var stairs = GMSMarker(position: position)
                    stairs .icon = UIImage(named: "stairs.jpg")
                    stairs .flat = true
                    stairs .map = self.mapView
                }
                
                if((room.GetRoomName()=="B250")||(room.GetRoomName()=="B205")||(room.GetRoomName()=="B218")||(room.GetRoomName()=="B217")){
                    polygon.fillColor = UIColor(red: 234/255.0, green: 230/255.0, blue: 245/255.0, alpha: 1.0)//purple color
                }
                
                if((room.GetRoomName()=="B241") || (room.GetRoomName()=="B234")||(room.GetRoomName()=="B219")||(room.GetRoomName()=="B251")||(room.GetRoomName()=="B230")){
                    polygon.fillColor  = UIColor.whiteColor()
                }
                if((room.GetRoomName()=="B236")||(room.GetRoomName()=="B232")||(room.GetRoomName()=="B223")){
                    polygon.fillColor  = UIColor.whiteColor()
                }
                
                if((room.GetRoomName()=="B247") || (room.GetRoomName()=="B233-229")||(room.GetRoomName()=="B235-238")||(room.GetRoomName()=="B245-248")||(room.GetRoomName()=="B222-220")){
                    polygon.fillColor  = UIColor.whiteColor()
                }
                
                polygon.strokeColor = UIColor(red:(108/255.0), green:(122/255.0), blue:(137/255.0), alpha:1.0);
                polygon.strokeWidth = 0.5
                polygon.title = room.GetRoomName();
                polygon.tappable = true;
                polygon.map = self.mapView
                self.view.setNeedsDisplay()
                
            }
            
        }
        
        
    }
    
    
    func mapView(mapView: GMSMapView!, didTapOverlay overlay: GMSOverlay!) {
        if((overlay.title) != nil){
            for room in _roomsData.getAllRooms(){
                if(room.GetRoomName() == overlay.title){
                    room.SetIsSelected(true);
                }else{
                    room.SetIsSelected(false);
                }
                
            }
          
        }
        self.mapView.clear();
        self.reDraw();
        
    }
    
    
    func reDraw(){
        dispatch_async(dispatch_get_main_queue()) {
            do {
                self.updateUIMap()
            }
            catch {
                print("Failed to update UI")
            }
        }
        
    }
    
    
}
