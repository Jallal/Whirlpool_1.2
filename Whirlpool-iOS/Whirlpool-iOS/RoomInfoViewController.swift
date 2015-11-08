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




/**
 * The hatter view. Displays an image with a hat drawn over
 * it that we can manipulate.
 */

class RoomInfoViewController: UIViewController,NSXMLParserDelegate,CLLocationManagerDelegate,GMSMapViewDelegate,GMSIndoorDisplayDelegate,UIScrollViewDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var roomInfo: UITableView!
    @IBOutlet weak var RoomNameLabel: UILabel!
    @IBOutlet weak var newView: UIView!
    internal var _room = RoomData()
    //var _roomsData = RoomsData()


    /**
     * Create the dialog box
     * @param savedInstanceState The saved instance bundle
     */
    @IBAction func PanGesture(sender: UIPanGestureRecognizer) {
       
        //Get the size of the screen
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        //let screenWidth : CGFloat  = screenSize.width
        let screenHeight : CGFloat  = screenSize.height
        //View will not go out of the fram of the screen
        let MagicNumber : CGFloat = screenSize.height*0.55
        let translation = sender.translationInView(self.newView)
        if let view = sender.view{
            let d: CGFloat = (self.view.center.y + translation.y)
            if(((MagicNumber)<=d)&&(d<(screenHeight))){
        view.center = CGPoint(x:view.center.x,
               y:view.center.y + translation.y)
            }
        }
        sender.setTranslation(CGPointZero, inView: self.view)
        
    }
    
  
    let locationManager = CLLocationManager()
      var RoomAmenities = ["Capacity","Whiteboard","Monitor","Polycom","Phone","TV","Video Conference"]
    
    @IBAction func cancelRoomView(sender: AnyObject) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    
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
    
    
    override func viewWillAppear(animated: Bool) {
       
       self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        updateLocation(true)
        if _room.GetRoomName() != "" {
            RoomNameLabel.text = _room.GetRoomName()
        }
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.mapView.delegate = self
        self.mapView.clear();
        self.mapView.center = self.view.center
          _roomsData.getTheGeoJson("RV")// Change this the building being passed
        self.reDraw()
    }
    
    
    
    func updateLocation(running : Bool){
        
       // let status = CLLocationManager.authorizationStatus()
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
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
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
            mapView.camera = GMSCameraPosition(target: position, zoom: 18, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
            
        }else{
            position = CLLocationCoordinate2D(latitude: 42.1124531749125, longitude: -86.4693216079577)
            mapView.camera = GMSCameraPosition(target: position, zoom: 18, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
        }
      
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RoomAmenities.count
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        let items = _room.GetRoomResources()
        cell!.textLabel!.text = RoomAmenities[indexPath.row]
        if(cell!.textLabel!.text=="Capacity"){
            cell!.detailTextLabel!.text = "\(_room.GetRoomCapacity())"
            
        }else if(cell!.textLabel!.text=="Whiteboard"){
            if(items.contains("White Board")){
                
                cell!.detailTextLabel!.text = "Yes"
            }else{
                cell!.detailTextLabel!.text = "No"
            }
        }else if(cell!.textLabel!.text=="Monitor"){
            if(items.contains("Monitor")){
                
                cell!.detailTextLabel!.text = "Yes"
            }else{
                cell!.detailTextLabel!.text = "No"
            }
        }else if(cell!.textLabel!.text=="Polycom"){
            if(items.contains("Polycom")){
                
                cell!.detailTextLabel!.text = "Yes"
            }else{
                cell!.detailTextLabel!.text = "No"
            }
        }else if(cell!.textLabel!.text=="Phone"){
            if(items.contains("Telephone")){
                
                cell!.detailTextLabel!.text = "Yes"
            }else{
                cell!.detailTextLabel!.text = "No"
            }
            
        }else if(cell!.textLabel!.text=="TV"){
            if(items.contains("TV")){
                
                cell!.detailTextLabel!.text = "Yes"
            }else{
                cell!.detailTextLabel!.text = "No"
            }
        }else if(cell!.textLabel!.text=="Video Conference"){
            
            if(items.contains("Video Conference")){
            
             cell!.detailTextLabel!.text = "Yes"
            }else{
                cell!.detailTextLabel!.text = "No"
            }
            
        }
        
        return cell!
        
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "bookRoomSeg" {
            let eventVC = segue.destinationViewController as! CalendarEventViewController
            eventVC.guest = _room.GetRoomEmail()
            eventVC.location = _room.GetRoomName()
            
        }
        
    }
    
    func updateUIMap(){
        for room in _roomsData.getAllRooms(){
            for rect in room.GetRoomCoordinates(){
                //Label HW and restroom with different colors
                let polygon = GMSPolygon(path: rect)
                if(room.GetIsSelected()){
                    self._room = room
                    self.RoomNameLabel.text = room.GetRoomName()
                    self.roomInfo.reloadData()
                    let position = room.GetroomCenter()
                    let marker = GMSMarker(position: position)
                    marker.icon = UIImage(named: "mapannotation.png")
                    marker.flat = true
                     //marker.appearAnimation = kGMSMarkerAnimationPop
                    marker.map = self.mapView
                    polygon.fillColor = UIColor(red:(137/255.0), green:196/255.0, blue:244/255.0, alpha:1.0);
                }else{
                    polygon.fillColor = UIColor(red:(255/255.0), green:249/255.0, blue:236/255.0, alpha:1.0);
                }
                if((room.GetRoomName()=="WB") || (room.GetRoomName()=="MB") ){
                    polygon.fillColor = UIColor(red: 234/255.0, green: 230/255.0, blue: 245/255.0, alpha: 1.0)//purple color
                }
                
                if(room.GetRoomName()=="HW"){
                    polygon.fillColor  = UIColor.whiteColor()
                }
                if(room.GetRoomStatus()=="Open"){
                    
                    polygon.fillColor = UIColor(red: 27/255.0, green: 188/255.0, blue: 155/255.0, alpha: 1.0)// open conferance rooms
                }
                if(room.GetRoomStatus()=="Busy"){
                    
                    polygon.fillColor = UIColor(red: 211/255.0, green: 84/255.0, blue:0/255.0, alpha: 1.0)// busy conferance rooms
                }
                
                polygon.strokeColor = UIColor(red:(108/255.0), green:(122/255.0), blue:(137/255.0), alpha:1.0);
                polygon.strokeWidth = 0.5
                polygon.title = room.GetRoomName();
                polygon.tappable = true;
                polygon.map = self.mapView
                
                // Add imge to the bathrooms and Exit/entrance
                if(room.GetRoomName()=="WB"){
                    let icon = UIImage(named: "wbathroom.jpg")
                    let overlay = GMSGroundOverlay(position: room.GetroomCenter(), icon: icon, zoomLevel:20)
                    overlay.bearing = -10
                    overlay.map = self.mapView
                }else if(room.GetRoomName()=="MB"){
                    let icon = UIImage(named: "mbathroom.jpg")
                    let overlay = GMSGroundOverlay(position: room.GetroomCenter(), icon: icon, zoomLevel:20)
                    overlay.bearing = -10
                    overlay.map = self.mapView
                }else if(room.GetRoomName()=="EXT"){
                    let icon = UIImage(named: "exit.jpg")
                    let overlay = GMSGroundOverlay(position: room.GetroomCenter(), icon: icon, zoomLevel:20)
                    overlay.bearing = -10
                    overlay.map = self.mapView
                }else if(room.GetRoomName()=="UX"){
                    let icon = UIImage(named: "UX.jpg")
                    let overlay = GMSGroundOverlay(position: room.GetroomCenter(), icon: icon, zoomLevel:20)
                    overlay.bearing = -10
                    overlay.map = self.mapView
                }else if(room.GetRoomType()=="C" || room.GetRoomType()=="H" ){
                    let overlay = GMSGroundOverlay(position: room.GetroomCenter(), icon: newImage(room.GetRoomName(), size: CGSizeMake(12, 12)), zoomLevel:20)
                    overlay.bearing = 0
                    overlay.map = self.mapView
                    
                }
                
                
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
    
    func newImage(text: String, size: CGSize) -> UIImage {
        
        let data = text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        let drawText = NSString(data: data!, encoding: NSUTF8StringEncoding)
        
        let textFontAttributes = [
            NSFontAttributeName: UIFont(name: "Helvetica Bold", size: 4)!,
            NSForegroundColorAttributeName: UIColor.blackColor(),
        ]
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        drawText?.drawInRect(CGRectMake(0, 0, size.width, size.height), withAttributes: textFontAttributes)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    
}





