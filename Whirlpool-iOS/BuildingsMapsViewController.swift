//
//  NavigationMainViewController.swift
//  Whirlpool-iOS
//
//  Created by Jallal Elhazzat on 9/28/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData
import Foundation

class  BuildingsMapsViewController : UIViewController , CLLocationManagerDelegate,GMSMapViewDelegate,UIPopoverPresentationControllerDelegate, buildingsLoadedDelegate{
    
    /**
     * All the amenities in a room
     *
     */
    //Remove this variable only for beta
    var count = 0
    let locationManager = CLLocationManager()
    var _StartingLocation = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var RoomAmenities = ["Capacity","Whiteboard","Monitor","Polycom","Phone","TV"]
    //The alert view for notification
    var alertView: UIView = UIView()
    //The button that dismiss the view
    var ok_button : UIButton = UIButton()
    //the message on the notification view
    var  label   : UILabel   = UILabel();
    //The room being passed
    internal var _room = RoomData()
    var CurrentFloor : Int = Int()
    var CurrentBuilding : String = String()
    var  NumberOfFloor  : Int = Int()
    var floors   =  [String]()
    //origin marker during navigation
    var originMarker: GMSMarker!
    //distination marker for navigation
    var destinationMarker: GMSMarker!
    //The rout between start and end postions
    var routePolyline: GMSPolyline!
    var _buildings : BuildingsData!
    var _building : Building!
    
    @IBOutlet weak var helpButton: UIButton!
    // The pin that helps locat the user
    @IBOutlet weak var mapPin: UIImageView!
    //Current location for the user
    @IBOutlet weak var Address: UILabel!
    //The map object
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var BottomMapView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var buttomView: UIView!
    //the picker for the floors
    @IBOutlet weak var floorPicker: UITableView!
    
    @IBAction func cancelMapScreen(sender: AnyObject) {
        self._buildings = nil
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func buildingInfoHasBeenLoaded(){
        if (self._buildings._buildings[CurrentBuilding] != nil){
            
            dispatch_async(dispatch_get_main_queue(),{
                self._building = self._buildings._buildings[self.CurrentBuilding]
                self.NumberOfFloor = self._building.getNumberOfFloors()
                self.populateFloors()
                self.floorPicker.reloadData()
                self.Invalidate(self.CurrentFloor)
            });
            if _room.GetRoomName() != String() {
               dispatch_async(dispatch_get_main_queue(),{
                    self._room = self._building.getARoomInBuilding(self.CurrentBuilding, roomName: self._room.GetRoomName())
                    self._room.SetIsSelected(true)
                    self.Invalidate(self._room.GetRoomFloor())
                });
            }
        }
        
    }
    
    @IBAction func pan(sender: UIPanGestureRecognizer) {
        //Get the size of the screen
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        //let screenWidth : CGFloat  = screenSize.width
        let screenHeight : CGFloat  = screenSize.height
        //View will not go out of the frame of the screen
        let MagicNumber : CGFloat = screenSize.height*0.70
        
        //Translate the PX to the screen size
        let translation = sender.translationInView(self.buttomView)
        if let view = sender.view{
            let d: CGFloat = (self.buttomView.center.y + translation.y)
            if(((MagicNumber)<=d)&&(d<(screenHeight+20))){
                self.buttomView.center = CGPoint(x:self.buttomView.center.x,
                    y:self.buttomView.center.y + translation.y)
            }
        }
        sender.setTranslation(CGPointZero, inView: self.buttomView)
        
    }
    
    /**
     * Add a prticular room into your favorite rooms
     * upon clicking on a button
     */
    @IBAction func favoriteButton(sender: UIButton) {
        if _room.GetRoomName() != String() {
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
    }
    
    @IBAction func book(sender: AnyObject) {
        
        
        
    }
    
    @IBAction func helpButton(sender: AnyObject) {
        
        self.floorPicker.hidden = !self.floorPicker.hidden
        self.floorPicker.reloadData()
        
    }
    
    @IBAction func getDirections(sender: AnyObject) {
        self.mapPin.hidden = !self.mapPin.hidden
         self.Address.hidden = !self.Address.hidden
        self.buttomView.hidden = !self.buttomView.hidden
        
    }
    
    func buildingAbbsHaveBeenLoaded(){

    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        /***********************   MAKE SURE YOU UPDATE THIS VARIABLES******************************/
        self.CurrentFloor = 1 // Make sure you fix this later on
        self._buildings = BuildingsData(delegate: self, buildingAbb: self.CurrentBuilding)
        /*******************************************************************************************/
        self.floorPicker.tableFooterView = UIView(frame: CGRectZero)
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.mapView.delegate = self
        //the pin to help locat the user
        self.mapPin.hidden = true;
        self.floorPicker.hidden = true
        self.Address.hidden = true
        mapPin.userInteractionEnabled = true
        mapPin.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "buttonTapped:"))
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        //Get the windows size infomation
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        //the notification windows to help the user navigate the building
        alertView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 60))
        alertView.backgroundColor = UIColor(red:(244/255.0), green:(179/255.0), blue:(80/255.0), alpha:1.0);
        ok_button = UIButton(frame: CGRect(x:(screenSize.width-70), y: 30, width:50,height:50))
        ok_button.layer.cornerRadius = 0.5 *  ok_button.bounds.size.width
        ok_button.backgroundColor = UIColor.grayColor()
        ok_button.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        ok_button.titleLabel?.font = UIFont(name:"Heiti SC", size: 14)
        ok_button.addTarget(self, action: Selector("onClick_ok"), forControlEvents: UIControlEvents.TouchUpInside)
        label = UILabel(frame: CGRect(x:5, y: 30, width:200,height:20))
        label.font = UIFont(name:"Heiti SC", size: 14)
        label.tintColor = UIColor.blackColor()
        self.view.backgroundColor = UIColor.whiteColor()
        self.floorPicker.tableFooterView = UIView(frame: CGRectZero)

    
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 148.0/255.0, green: 157.0/255.0, blue: 250.0/255.0, alpha: 1)
        self.BottomMapView.backgroundColor = UIColor(red: 148.0/255.0, green: 157.0/255.0, blue: 250.0/255.0, alpha: 1)
     
        updateLocation(true)
        if _room.GetRoomName() != "" {
            self.roomLabel.text = _room.GetRoomName()
        }
 
    }
    
    //Destroy objects in here before leaving the view to free up memory
    func clearMemory(){
        self._building = nil
        self._buildings = nil
    }
    
    //The number of floors in the given building
    func populateFloors(){
        var i : Int = 0
        if(self.NumberOfFloor != 0){
            for index  in (1...NumberOfFloor).reverse(){
                floors.append("\(index)")
                i = i+1
            }
        }
    }
    
    /* The function that handels dismissing the notification during navigation*/
    func onClick_ok(){
        self.alertView.alpha = 0
        self.ok_button.alpha = 0
         self.label.alpha = 0
        
        UIView.animateWithDuration(1, animations: {
            self.alertView.removeFromSuperview()
            self.ok_button.removeFromSuperview()
            self.label.removeFromSuperview()
        })
        
    }
    
      /* The function that handels asking the user for authorization to use the current location*/
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    
      /* This function focus the camera on the given room if no room is given will default to a bird view of the map */
    
   func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    var position =  self._room.GetroomCenter()
    
    if((position.latitude != 0) && (position.longitude != 0)){
        position = CLLocationCoordinate2D(latitude: self._room.GetroomCenter().latitude, longitude: self._room.GetroomCenter().longitude)
        self._room.SetIsSelected(true)
        
    }else if(self._building != nil){
        
       self._room  = self._building.getARoomInBuilding(self.CurrentBuilding)
       position = CLLocationCoordinate2D(latitude: self._room.GetroomCenter().latitude, longitude: self._room.GetroomCenter().longitude)
    }
    if((position.latitude != 0) && (position.longitude != 0)){
    
    if(CLLocationCoordinate2DIsValid(position)){
        mapView.camera = GMSCameraPosition(target: position, zoom: 17.7, bearing: 0, viewingAngle: 0)
       mapView.mapType = GoogleMaps.kGMSTypeNone
        locationManager.stopUpdatingLocation()
        
    }else{
        mapView.camera = GMSCameraPosition(target: position, zoom: 17.7,bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
    }
    }

    }
    
    /* ***********After the view has appeared we update the user location**************************/
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if _room.GetRoomName() != "" {
            roomLabel.text = _room.GetRoomName()
        }
        updateLocation(true)
    }
    
    
    /**************The actual updating of the user location****************************/
    func updateLocation(running : Bool){
        //Get all the floors in the building
        //self.reDraw(self.CurrentFloor)
    
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
    
    
    /* In case we failed getting the user location we print an error*/
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        
        reverseGeocodeCoordinate(position.target)
    }
    
    /* Updating the user's address and location as we moved through the building*/
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        self._StartingLocation = coordinate
        // 1
        let geocoder = GMSGeocoder()
        
        // 2
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            
            if(!self.mapPin.hidden){
                for floorClass in self._building.getFloors() {
                   for room in floorClass.getRoomsInFloor(){
                    for rect in room.GetRoomCoordinates(){
                        if(GMSGeometryContainsLocation(coordinate,rect, true)){
                            if(self.CurrentFloor == room.GetRoomFloor()){
                            
                            let lines = ["Building : \(self.CurrentBuilding)","Floor : \(self.CurrentFloor)"," Room : \(room.GetRoomName())"]
                            self.Address.text = lines.joinWithSeparator(", ")
                            }
                            
                            
                        }
                    }
                    }
                }
            }else{
                let address = response?.firstResult()
                //let lines = address!.lines as! [String]
                //self.Address.text = lines.joinWithSeparator(", ")

                }
                
                // 4
            
                UIView.animateWithDuration(0.25) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    
    
/**************Function the handels drawing the floor plan of each building****************************************/
    func updateUIMap(floor : Int){
        for floorClass in self._building.getFloors() {
            if(floorClass._floorNumber==floor){
            for room in floorClass.getRoomsInFloor(){
                for rect in room.GetRoomCoordinates(){
                //Label HW and restroom with different colors
                let polygon = GMSPolygon(path: rect)
                if(room.GetIsSelected()){
                    self._room = room
                    self.roomLabel.text = room.GetRoomName()
                    self.tableView.reloadData()
                    let marker = GMSMarker(position: room.GetroomCenter())
                    marker.icon = UIImage(named: "Location End.png")
                    marker.flat = true
                    marker.appearAnimation =   GoogleMaps.kGMSMarkerAnimationPop
                    polygon.fillColor = UIColor(red:(137/255.0), green:196/255.0, blue:244/255.0, alpha:1.0);
                    marker.map = self.mapView
                }else{
                    polygon.fillColor = UIColor(red:(255/255.0), green:249/255.0, blue:236/255.0, alpha:1.0);
                }
                if((room.GetRoomName()=="WB") || (room.GetRoomName()=="MB") ){
                    polygon.fillColor = UIColor(red: 234/255.0, green: 230/255.0, blue: 245/255.0, alpha: 1.0)//purple color
                }
                 if((room.GetRoomName()=="STR") || (room.GetRoomName()=="ELV") ){
                    polygon.fillColor = UIColor(red:(244/255.0), green:(179/255.0), blue:(80/255.0), alpha:1.0)//orange
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
                    overlay.bearing = -15
                    overlay.map = self.mapView
                }else if(room.GetRoomName()=="STR"){
                    let icon = UIImage(named: "STR.png")
                    //UIColor(red:(244/255.0), green:(179/255.0), blue:(80/255.0), alpha:1.0);
                    let overlay = GMSGroundOverlay(position: room.GetroomCenter(), icon: icon, zoomLevel:20)
                    overlay.bearing = -15
                    overlay.map = self.mapView
                    
                }else if(room.GetRoomName()=="ELV"){
                    let icon = UIImage(named: "ELV.png")
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
                    
        

            }
            
        }
        }
        }
      self.view.setNeedsDisplay()
        
    }

/**************Function to detect the user has tapped on a particular room in the floor**********************/
    func mapView(mapView: GMSMapView!, didTapOverlay overlay: GMSOverlay!) {
        for floorClass in self._building.getFloors() {
                
                for room in floorClass.getRoomsInFloor(){
                    if(room.GetRoomName() == overlay.title){
                        room.SetIsSelected(true);
                    }else{
                        room.SetIsSelected(false);
                    }
                
            }
        }
        self.mapView.clear();
        self.Invalidate(self.CurrentFloor);
    }
    
    
    /******************************  Redraw  function  *************************/

    
    func Invalidate(floor : Int){
        dispatch_async(dispatch_get_main_queue()) {
            do {
                self.updateUIMap(floor)

            }
        }
        
    }
    
    func distanceInMetersFrom(otherCoord : CLLocationCoordinate2D) -> CLLocationDistance {
        let firstLoc = CLLocation(latitude: self._StartingLocation.latitude, longitude: self._StartingLocation.longitude)
        let secondLoc = CLLocation(latitude: otherCoord.latitude, longitude: otherCoord.longitude)
        return firstLoc.distanceFromLocation(secondLoc)
    }
    
    
    /****************************** Drawing the navigation path for the user*************************/
    func drawRoute() {
        //let graph = SwiftGraph()
        //let getPath =   Path()

        
        let walkingSpeed = 1.4
        let distance  = self.distanceInMetersFrom(self._room.GetroomCenter())//distance in meters
        let totalDistance = Double(round(distance*3.28084)) // distance in feets
        let totalTime = Double(round((distance/walkingSpeed)/60))
        self.BannerView("\(totalTime)  Minutes  (\(totalDistance)  ft)", button_message:"GO");
        
        /*/******************/
        graph.readFromFile()
        //getPath.processDijkstra(0, des: 60)
        let myPath = getPath.traverseGraphBFS(60,end: 128)
        
        
        let path1 = GMSMutablePath()
        //path1.addCoordinate(CLLocationCoordinate2D(latitude: 42.1124842505816, longitude: -86.4693117141724))
        for node in myPath{
            path1.addCoordinate(CLLocationCoordinate2D(latitude: node.lat, longitude: node.long))
            
        }*/
        
        if(self.count==0){
        //First path delete after
        let path1 = GMSMutablePath()
        //path1.addCoordinate(CLLocationCoordinate2D(latitude: 42.1124842505816, longitude: -86.4693117141724))
         path1.addCoordinate(CLLocationCoordinate2D(latitude: 0, longitude: 0))
        let polyline = GMSPolyline(path: path1)
        polyline.strokeColor = UIColor.blueColor()
        polyline.strokeWidth = 2.0
        polyline.geodesic = true
        polyline.map = mapView;
        self.count = self.count+1
        }else{
            //second path delete after
            let path1 = GMSMutablePath()
            //path1.addCoordinate(CLLocationCoordinate2D(latitude: 42.1124842505816, longitude: -86.4693117141724))
            path1.addCoordinate(CLLocationCoordinate2D(latitude: 0, longitude: 0))
            let polyline = GMSPolyline(path: path1)
            polyline.strokeColor = UIColor.blueColor()
            polyline.strokeWidth = 2.0
            polyline.geodesic = true
            polyline.map = mapView;
            self.count = self.count+1

        }
    }
    
    func buttonTapped(sender: UITapGestureRecognizer) {
        if (sender.state == .Ended) {
            self.drawRoute();
        }
    }
    
    
    /****************** The banner view for notifying the user and guiding them through floors****************************/
    func BannerView(label_message : String,button_message : String){
        self.ok_button.setTitle(button_message, forState: UIControlState.Normal)
        self.label.text = label_message
        self.alertView.alpha = 0
        self.ok_button.alpha = 0
        self.label.alpha = 0
        self.view.addSubview(alertView)
        self.view.addSubview(ok_button)
        self.view.addSubview(label)
        UIView.transitionWithView(self.alertView, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve, animations: {
            self.alertView.alpha = 1
            self.ok_button.alpha = 1
            self.label.alpha = 1
            }, completion: {
                (value: Bool) in
        })
        
        
    }
    
    
     /********************************* CREAT A NEW IMAGE FOR GoogleMaps****************************************/
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
    
    
    
     /********************************* SAGUES****************************************/
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "bookRoomSeg" {
            let eventVC = segue.destinationViewController as! CalendarEventViewController
            eventVC.guest = _room.GetRoomEmail()
            eventVC.location = _room.GetRoomName()
            
        }
        
    }
    
    
    /*********************************ADD ROOM TO FAVORITE****************************************/
    
    func saveFavoriteRoom(room: RoomData){
        let appDelagate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelagate.managedObjectContext
        
        
        let entity = NSEntityDescription.entityForName("Whirlpool_favorites_table", inManagedObjectContext: managedContext)
        
        let favoriteRoom = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        
        favoriteRoom.setValue(room.GetRoomName(), forKey: "roomName")
        favoriteRoom.setValue(room.GetRoomEmail(), forKey: "roomEmail")
        favoriteRoom.setValue(CurrentBuilding, forKey: "buildingAbb")
        //4
        do {
            try managedContext.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
    
    
    /*********************************ROOM INFO TABLE AND FLOOR PICKER TABLE ***********************/
    /* Get the number of floors to be displayed*/
    func tableView(floorPicker: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(floorPicker == self.floorPicker){
            
            return floors.count
            
        }else{
            return RoomAmenities.count
            
        }
        
    }
    
    /* Display the floor picker and and the room details in the each tableView*/
    func tableView(tableViews: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if(tableViews == self.floorPicker){
            cell!.textLabel!.text = floors[indexPath.row]
            cell!.detailTextLabel!.text = ""
            return cell!
           // var RoomAmenities = ["Capacity","Whiteboard","Monitor","Polycom","Phone","TV"]
            
        }else{
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
            }
            
            return cell!
            
        }
    }
    
    /* Function to handel selecting a particular floor*/
    func tableView(floorPicker: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if(floorPicker==self.floorPicker){
            
            //floorPicker.deselectRowAtIndexPath(indexPath, animated: true)
            if let myNumber = NSNumberFormatter().numberFromString(floors[indexPath.row]) {
                
                let selectedCell:UITableViewCell = floorPicker.cellForRowAtIndexPath(indexPath)!
                selectedCell.contentView.backgroundColor = UIColor(red:(255/255.0), green:127/255.0, blue:80/255.0, alpha:1.0);
                self.mapView.clear()
                self.CurrentFloor = myNumber.integerValue
                self.Invalidate(self.CurrentFloor)
            }
            
        }
        
    }
    
    
    func tableView(floorPicker: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cellToDeSelect:UITableViewCell = floorPicker.cellForRowAtIndexPath(indexPath)!
        cellToDeSelect.contentView.backgroundColor = UIColor.clearColor()
    }

    
}