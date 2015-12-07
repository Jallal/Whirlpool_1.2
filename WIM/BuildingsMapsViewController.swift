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
import SwiftyJSON

class  BuildingsMapsViewController : UIViewController , CLLocationManagerDelegate,GMSMapViewDelegate,UIPopoverPresentationControllerDelegate, buildingsLoadedDelegate{
    
    /**
     * All the amenities in a room
     *
     */
     //Remove this variable only for beta
    
    
    var BuildingView = true
    var finishedDrawingTheMap = false
    var endpoint  = CLLocationCoordinate2D(latitude: 0,longitude: 0)
    var locationManager = CLLocationManager()
    var PassedFloorNumber : Int = Int()
    var _StartingLocation = RoomData()
    var _EndNav = RoomData()
    var RoomAmenities = ["Capacity","Whiteboard","Monitor","Polycom","Phone","TV"]
    //The alert view for notification
    var alertView: UIView = UIView()
    
    //The button that dismiss the view
    var ok_button : UIButton = UIButton()
    //the message on the notification view
    var  label   : UILabel   = UILabel();
    //The room being passed
    internal var _room = RoomData()
    var CurrentFloor  = FloorData!()
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
    @IBOutlet weak var bookingButton: UIButton!
    // The pin that helps locat the user
    @IBOutlet weak var mapPin: UIImageView!
    //Current location for the user
    @IBOutlet weak var Address: UILabel!
    //The map object
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var BottomMapView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var buttomView: UIView!
    //the picker for the floors
    @IBOutlet weak var floorPicker: UITableView!
    
    @IBAction func cancelMapScreen(sender: AnyObject) {
        clearMemory()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    func buildingInfoHasBeenLoaded(){
        if (self._buildings._buildings[CurrentBuilding] != nil){
            
            dispatch_async(dispatch_get_main_queue(),{
                self._building = self._buildings._buildings[self.CurrentBuilding]
                self.NumberOfFloor = self._building.getNumberOfFloors()
                self.populateFloors()
                self.floorPicker.reloadData()
                self.CurrentFloor =  self._building.getFloorInBuilding(self.PassedFloorNumber)
//                self.Invalidate(self.PassedFloorNumber)
            });
            if _room.GetRoomName() != String() {
                dispatch_async(dispatch_get_main_queue(),{
                    for x in (self._buildings._buildings[self.CurrentBuilding]?._floors)!{
                        if x._rooms[self._room.GetRoomName()] != nil {
                            self._room = x._rooms[self._room.GetRoomName()]!
                            self._room.SetIsSelected(true)
                            self.PassedFloorNumber = self._room.GetRoomFloor()!
                            self.CurrentFloor =  self._building.getFloorInBuilding(self.PassedFloorNumber)
                            //self.Invalidate(self.PassedFloorNumber)
                        }
                    }
                });
            }
            dispatch_async(dispatch_get_main_queue(),{
//                if self._room.GetRoomFloor() == Int(){
//                    self.Invalidate(1)
//                }
                if let roomFloor = self._room.GetRoomFloor(){
                    self.Invalidate(roomFloor)
                }
                else{
                    self.Invalidate(1)
                }
            });
            self._buildings._buildings[CurrentBuilding]?.buildingStartRoomUpdateTimer()
        }else{
            dispatch_async(dispatch_get_main_queue(),{
                self.MapUnderConstructions(" Map Under Construction ")
            });
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
        if _room.GetRoomName() != String() && _room.GetRoomEmail() != String() && CurrentBuilding != String() {
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
    
    @IBAction func bookRoom(sender: AnyObject) {
        findRoomInfo(_room.GetRoomName()) { (response) -> Void in
            let room = self.parseRoomJson(response)
            if room.GetRoomEmail() != String() {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self._room = room
                    self.performSegueWithIdentifier("bookRoomSeg", sender: self)
                })
            }
        }
    }
    
    func parseRoomJson(roomInfo: JSON)->RoomData{
        if roomInfo["rooms"][0]["room_name"].stringValue == _room.GetRoomName() {
            let room = RoomData()
            room.SetRoomName(roomInfo["rooms"][0]["room_name"].stringValue)
            room.SetRoomEmail(roomInfo["rooms"][0]["email"].stringValue)
            room.SetRoomLocation(roomInfo["rooms"][0]["resource_name"].stringValue)
            room.SetRoomCapacity(roomInfo["rooms"][0]["capacity"].intValue)
            room.SetRoomExt(roomInfo["rooms"][0]["extension"].stringValue)
            room.SetRoomType(roomInfo["rooms"][0]["room_type"].stringValue)
            room.SetRoomBuildingName(roomInfo["rooms"][0]["building_name"].stringValue)
            room.SetRoomStatus(roomInfo["rooms"][0]["occupancy_status"].stringValue)
            for i in 0...roomInfo["amenities"].count-1{
                room.SetRoomResources(roomInfo["amenities"][i].stringValue)
            }
            return room
        }
        return RoomData()
    }
    
    @IBAction func helpButton(sender: AnyObject) {
        
        self.floorPicker.hidden = !self.floorPicker.hidden
        self.floorPicker.reloadData()
        
    }
    
    @IBAction func getDirections(sender: AnyObject) {
        self.mapPin.hidden = !self.mapPin.hidden
        self.goButton.hidden = !self.goButton.hidden
        self.Address.hidden = !self.Address.hidden
        self.buttomView.hidden = true//!self.buttomView.hidden
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.Invalidate(self.CurrentFloor._floorNumber)
        }
        
    }
    
    func buildingAbbsHaveBeenLoaded(){
        
    }
    
    func buildingUpdated() {
        if(self.Address.hidden){
            dispatch_async(dispatch_get_main_queue(),{
                if self._building != nil {
                    if self.PassedFloorNumber != 0 {
                        self.CurrentFloor =  self._building.getFloorInBuilding(self.PassedFloorNumber)
                        self.Invalidate(self.PassedFloorNumber)
                    }
                    if self._room.GetRoomFloor() != nil {
                        self.CurrentFloor =  self._building.getFloorInBuilding(self._room.GetRoomFloor()!)
                        self.Invalidate(self._room.GetRoomFloor()!)
                    }
                    else{
                        self.CurrentFloor =  self._building.getFloorInBuilding(1)
                        self.Invalidate(1)
                    }
                }
                self.updateLocation(true)
            });
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.settings.compassButton = true
        self.mapView.buildingsEnabled = false
        self.mapView.indoorEnabled = false
        self._buildings = BuildingsData(delegate: self, buildingAbb: self.CurrentBuilding)
        self.floorPicker.tableFooterView = UIView(frame: CGRectZero)
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.mapView.delegate = self
        //the pin to help locat the user
        self.mapPin.hidden = true;
        self.floorPicker.hidden = true
        self.Address.hidden = true
        mapPin.userInteractionEnabled = false
        goButton.hidden = true
        goButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "buttonTapped:"))
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        //Get the windows size infomation
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        //the notification windows to help the user navigate the building
        alertView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 60))
        alertView.backgroundColor = UIColor(red:(244/255.0), green:(179/255.0), blue:(80/255.0), alpha:1.0);
        
        ok_button = UIButton(frame: CGRect(x:(screenSize.width-70), y: 7, width:50,height:50))
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
        mapView.camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: 42.1111, longitude: -86.4483), zoom: 10,bearing: 0, viewingAngle: 0)
        
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
        for (buildingName, building) in self._buildings._buildings{
            building.removeTimer()
        }
        self._buildings = nil
        self.mapView.clear()
        self.mapView = nil
        self.BottomMapView = nil
        self.buttomView = nil
        self.roomLabel = nil
        self.tableView = nil
        self.helpButton = nil
        self.bookingButton = nil
        self.mapPin = nil
        self.goButton = nil
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
    
    
    /* The function that handels asking the user for authorization to use the current location*/
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = false
            mapView.settings.compassButton = true
            
        }
    }
    
    
    /* This function focus the camera on the given room if no room is given will default to a bird view of the map */
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var position =  self._room.GetroomCenter()
        
        if((position.latitude != 0) && (position.longitude != 0)){
            LoadingView.hide()
            position = CLLocationCoordinate2D(latitude: self._room.GetroomCenter().latitude, longitude: self._room.GetroomCenter().longitude)
            self._room.SetIsSelected(true)
            self.CurrentFloor.SetFloorNumber(self._room.GetRoomFloor()!)
            
            
        }else if(self._building != nil){
            LoadingView.hide()
            self._room  = self._building.getARoomInBuilding(self.CurrentBuilding)
            position = CLLocationCoordinate2D(latitude: self._room.GetroomCenter().latitude, longitude: self._room.GetroomCenter().longitude)
            self.CurrentFloor.SetFloorNumber(self._room.GetRoomFloor()!)
            
        }
        if((position.latitude != 0) && (position.longitude != 0)){
            LoadingView.hide()
            if(CLLocationCoordinate2DIsValid(position)){
                mapView.camera = GMSCameraPosition(target: position, zoom: 18, bearing: 0, viewingAngle: 0)
                mapView.mapType = GoogleMaps.kGMSTypeNormal
                locationManager.stopUpdatingLocation()
                
            }else{
                LoadingView.hide()
                mapView.camera = GMSCameraPosition(target: position, zoom: 18,bearing: 0, viewingAngle: 0)
                locationManager.stopUpdatingLocation()
                
            }
        }else{
            if(self.BuildingView){
                LoadingView.show("Loading building map...")
            }
        }
        
    }
    
    /* ***********After the view has appeared we update the user location**************************/
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if _room.GetRoomName() != "" {
            roomLabel.text = _room.GetRoomName()
        }
    }
    
    
    /**************The actual updating of the user location****************************/
    func updateLocation(running : Bool){
        //Get all the floors in the building
        let status = CLLocationManager.authorizationStatus()
        if running{
            
            locationManager.startUpdatingLocation()
            self.mapView.myLocationEnabled = true
            self.mapView.settings.myLocationButton = false
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
        
        self._StartingLocation.SetroomCenter(coordinate)
        if(self.CurrentFloor == nil ){
            self._StartingLocation.SetRoomFloor(self.PassedFloorNumber)
        }else{
            self._StartingLocation.SetRoomFloor(self.CurrentFloor.getFloorNumber())
        }
        // 1
        let geocoder = GMSGeocoder()
        
        // 2
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if(!self.mapPin.hidden){
                for floorClass in self._building.getFloors() {
                    for (roomName,room) in floorClass.getRoomsInFloor(){
                        for rect in room.GetRoomCoordinates(){
                            if(GMSGeometryContainsLocation(coordinate,rect, true)){
                                if(self.CurrentFloor.getFloorNumber() == room.GetRoomFloor()){
                                    
                                    let lines = ["Building : \(self.CurrentBuilding)","Floor : \(self.CurrentFloor.getFloorNumber())"," Room : \(room.GetRoomName())"]
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
                for (roomName,room) in floorClass.getRoomsInFloor(){
                    for rect in room.GetRoomCoordinates(){
                        //Label HW and restroom with different colors
                        let polygon = GMSPolygon(path: rect)
                        if(room.GetIsSelected()){
                            self._room = room
                            self.roomLabel.text = room.GetRoomName()
                            self.tableView.reloadData()
                            self._EndNav = room
                            let marker = GMSMarker(position: room.GetroomCenter())
                            marker.icon = UIImage(named: "Location End.png")
                            marker.flat = true
                            marker.appearAnimation =   GoogleMaps.kGMSMarkerAnimationPop
                            polygon.fillColor = UIColor(red:(137/255.0), green:196/255.0, blue:244/255.0, alpha:1.0);
                            marker.map = self.mapView
                            bookingButton.hidden = ((room.GetRoomType() == "C") ? false: true)
                            
                        }else{
                            polygon.fillColor = UIColor(red:(255/255.0), green:249/255.0, blue:236/255.0, alpha:1.0);
                        }
                        if((room.GetRoomType()=="WB") || (room.GetRoomType()=="MB") ){
                            polygon.fillColor = UIColor(red: 234/255.0, green: 230/255.0, blue: 245/255.0, alpha: 1.0)//purple color
                        }
                        if((room.GetRoomType()=="STR") || (room.GetRoomType()=="ELV") ){
                            polygon.fillColor = UIColor(red: 234/255.0, green: 230/255.0, blue: 245/255.0, alpha: 1.0)//purple color
                        }
                        
                        if(room.GetRoomType()=="HW"){
                            polygon.fillColor  = UIColor.whiteColor()
                        }
                        if(room.GetRoomStatus()=="N"){
                            
                            polygon.fillColor = UIColor(red: 27/255.0, green: 188/255.0, blue: 155/255.0, alpha: 1.0)// busy conferance rooms
                        }
                        if(room.GetRoomStatus()=="Y"){
                            
                            polygon.fillColor = UIColor(red: 211/255.0, green: 84/255.0, blue:0/255.0, alpha: 1.0)// open conferance rooms
                        }
                        polygon.strokeColor = UIColor(red:(108/255.0), green:(122/255.0), blue:(137/255.0), alpha:1.0);
                        polygon.strokeWidth = 0.5
                        polygon.title = room.GetRoomName();
                        polygon.tappable = true;
                        polygon.map = self.mapView
                        
                        
                        // Add imge to the bathrooms and Exit/entrance
                        if(room.GetRoomType()=="WB"){
                            let icon = UIImage(named: "accessibility womans.png")
                            let overlay = GMSGroundOverlay(position: room.GetroomCenter(), icon: icon, zoomLevel:20)
                            overlay.bearing = -10
                            overlay.map = self.mapView
                        }else if(room.GetRoomType()=="MB"){
                            let icon = UIImage(named: "accessibility mens.png")
                            let overlay = GMSGroundOverlay(position: room.GetroomCenter(), icon: icon, zoomLevel:20)
                            overlay.bearing = -15
                            overlay.map = self.mapView
                        }else if(room.GetRoomType()=="STR"){
                            let icon = UIImage(named: "sort.png")
                            //UIColor(red:(244/255.0), green:(179/255.0), blue:(80/255.0), alpha:1.0);
                            let overlay = GMSGroundOverlay(position: room.GetroomCenter(), icon: icon, zoomLevel:20)
                            overlay.bearing = -15
                            overlay.map = self.mapView
                            
                        }else if(room.GetRoomType()=="ELV"){
                            let icon = UIImage(named: "Elevator.png")
                            let overlay = GMSGroundOverlay(position: room.GetroomCenter(), icon: icon, zoomLevel:20)
                            overlay.bearing = -10
                            overlay.map = self.mapView
                            
                        }else if(room.GetRoomType()=="EXT"){
                            let icon = UIImage(named: "exit.jpg")
                            let overlay = GMSGroundOverlay(position: room.GetroomCenter(), icon: icon, zoomLevel:20)
                            overlay.bearing = -10
                            overlay.map = self.mapView
                        }else if(room.GetRoomType()=="UX"){
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
        
        self.finishedDrawingTheMap  = true
        
    }
    
    /**************Function to detect the user has tapped on a particular room in the floor**********************/
    func mapView(mapView: GMSMapView!, didTapOverlay overlay: GMSOverlay!) {
        for floorClass in self._building.getFloors() {
            
            for (roomName,room) in floorClass.getRoomsInFloor(){
                if(room.GetRoomName() == overlay.title){
                    room.SetIsSelected(true);
                }else{
                    room.SetIsSelected(false);
                }
                
            }
        }
        self.mapView.clear();
        self.Invalidate(self.CurrentFloor.getFloorNumber());
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
        var startlocation = self._StartingLocation.GetroomCenter()
        let firstLoc = CLLocation(latitude: startlocation.latitude, longitude: startlocation.longitude)
        let secondLoc = CLLocation(latitude: otherCoord.latitude, longitude: otherCoord.longitude)
        return firstLoc.distanceFromLocation(secondLoc)
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
    
    
    /****************** The banner view for notifying the user and guiding them through floors****************************/
    func MapUnderConstructions(label_message : String){
     self.BuildingView = false
        dispatch_async(dispatch_get_main_queue(),{
            LoadingView.show(label_message).addTapHandler({
                LoadingView.hide()
                self.navigationController?.popViewControllerAnimated(true)

                }, subtitle: "Tap to go back !")
            
        });
        
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
            eventVC.location = _room.GetRoomLocation()
            clearMemory()
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
    
    
    
    /******************************Request Info on Room****************************************/
    
    func findRoomInfo(roomName: String, successHandler: (response: JSON) -> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: "https://whirlpool-indoor-maps.appspot.com/room?building_name=\(CurrentBuilding)&room_name=\(roomName)" as String)!)
        request.HTTPMethod = "GET"
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            do {
                let readableJSON = JSON(data: data!, options: NSJSONReadingOptions.MutableContainers, error: nil)
                successHandler(response: readableJSON)
            }
        }
        task.resume()
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
    public func tableView(floorPicker: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        if(floorPicker==self.floorPicker){
            
            self.floorPicker.reloadData()
            
            
            //floorPicker.deselectRowAtIndexPath(indexPath, animated: true)
            if let myNumber = NSNumberFormatter().numberFromString(floors[indexPath.row]) {
                
                let selectedCell:UITableViewCell = floorPicker.cellForRowAtIndexPath(indexPath)!
                self.mapView.clear()
                self.CurrentFloor = self._building.getFloorInBuilding(myNumber.integerValue)
                self.Invalidate(self.CurrentFloor.getFloorNumber())
                selectedCell.contentView.backgroundColor = UIColor(red:(255/255.0), green:127/255.0, blue:80/255.0, alpha:1.0);
                selectedCell.backgroundColor = UIColor(red:(255/255.0), green:127/255.0, blue:80/255.0, alpha:1.0);
                
            }
            
        }
        
    }
    
    
    func tableView(floorPicker: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cellToDeSelect:UITableViewCell = floorPicker.cellForRowAtIndexPath(indexPath)!
        cellToDeSelect.contentView.backgroundColor = UIColor.clearColor()
        cellToDeSelect.backgroundColor = UIColor.whiteColor()
    }
    
    
    
    
    
    /****************************** Drawing the navigation path for the user*************************/
    func drawRoute() {
        let graph = SwiftGraph()
        let getPath =   Path()
        let walkingSpeed = 1.4
        let distance  = self.distanceInMetersFrom(self._room.GetroomCenter())//distance in meters
        let totalDistance = Int(round(distance*3.28084)) // distance in feets
        let totalTime = Double(round((distance/walkingSpeed)/60))
        self.BannerView("\(totalTime)  Minutes  (\(totalDistance)  ft)", button_message:"GO");
        
        
    }
    
    
    
    
    
    
    
    
    public func ShowPathFinal(p : Path){
        
        
        while(!self.finishedDrawingTheMap){
            
        }
        
        let path1 = GMSMutablePath()
        self.mapPin.hidden = true
        self.goButton.hidden = true
        
        for node in p.ActualPath {
            path1.addCoordinate(node.location)
            
        }
        let polyline = GMSPolyline(path: path1)
        polyline.strokeColor = UIColor.blueColor()
        polyline.strokeWidth = 2.0
        polyline.geodesic = true
        polyline.map = self.mapView;
        
        
    }
    
    
    
    public func ShowPath(p : Path,inout endpoint : CLLocationCoordinate2D){
        
        let path1 = GMSMutablePath()
        self.mapPin.hidden = true
        self.goButton.hidden = true
        let pos = self._StartingLocation.GetroomCenter()
        let marker = GMSMarker(position: pos)
        marker.icon = UIImage(named: "Location Start.png")
        marker.flat = true
        marker.appearAnimation =   GoogleMaps.kGMSMarkerAnimationPop
        marker.map = self.mapView
        endpoint = (p.ActualPath.first?.location)!
        
        
        for node in p.ActualPath {
            path1.addCoordinate(node.location)
            
        }
        let polyline = GMSPolyline(path: path1)
        polyline.strokeColor = UIColor.blueColor()
        polyline.strokeWidth = 2.0
        polyline.geodesic = true
        polyline.map = self.mapView;
        
        
    }
    
    
    
    
    /* The function that handels dismissing the notification during navigation*/
    func onClick_ok(){
        var EndingFloor  = self._building.getFloorInBuilding(self._EndNav.GetRoomFloor()!)
        var startingFloor =  self.CurrentFloor
        
        if(self.ok_button.titleLabel?.text == "Yes"){
            var index = NSNumberFormatter().numberFromString(self.floors[EndingFloor.getFloorNumber()]) as! Int
            var indexPath = NSNumberFormatter().numberFromString(self.floors[startingFloor.getFloorNumber()]) as! Int
            let rowToDeSelect:NSIndexPath = NSIndexPath(forRow: indexPath , inSection: 0)
            self.tableView(floorPicker,didDeselectRowAtIndexPath: rowToDeSelect)
            let rowToSelect:NSIndexPath = NSIndexPath(forRow: index , inSection: 0)
            self.tableView(floorPicker, didSelectRowAtIndexPath: rowToSelect);
            
            let paths = Path()
            let filereading = SwiftGraph()
            filereading.readFromFile("\(self._building._buildingAbbr)_\(EndingFloor.getFloorNumber())")
            var pa2   = paths.traverseGraphBFSFinalPath(self._EndNav.GetroomCenter(),end: endpoint,SameFloor: false,StartingFloor: self.CurrentFloor,EndingFloor: EndingFloor)!
            
            self.finishedDrawingTheMap = false
            
            dispatch_async(dispatch_get_main_queue(),{
                self.ShowPathFinal(pa2)
            });
            
            
            self.alertView.alpha = 0
            self.ok_button.alpha = 0
            self.label.alpha = 0
            
            UIView.animateWithDuration(1, animations: {
                self.alertView.removeFromSuperview()
                self.ok_button.removeFromSuperview()
                self.label.removeFromSuperview()
            })
            
            
            
        } else{
            
            
            /*********************************NAVIGATION********************/
            let paths = Path()
            let filereading = SwiftGraph()
            
            filereading.readFromFile("\(self._building._buildingAbbr)_\( startingFloor.getFloorNumber())")
             //filereading.populateEdges()
            
            
            if(startingFloor.getFloorNumber() != EndingFloor.getFloorNumber()){
                let pa1   = paths.traverseGraphBFS(self._StartingLocation.GetroomCenter(),end: self._EndNav.GetroomCenter(),SameFloor: false,StartingFloor: startingFloor,EndingFloor: EndingFloor)
                self.ShowPath(pa1!,endpoint: &endpoint)
                self.BannerView(" Are you in \(EndingFloor.getFloorNumber()) floor yet ?", button_message:"Yes");
                
                
                
            }else{
                let p   = paths.traverseGraphBFS(self._StartingLocation.GetroomCenter(),end: self._EndNav.GetroomCenter(),SameFloor: true,StartingFloor: startingFloor,EndingFloor: EndingFloor)
                self.ShowPath(p!,endpoint: &endpoint)
                
                
                self.alertView.alpha = 0
                self.ok_button.alpha = 0
                self.label.alpha = 0
                
                UIView.animateWithDuration(1, animations: {
                    self.alertView.removeFromSuperview()
                    self.ok_button.removeFromSuperview()
                    self.label.removeFromSuperview()
                })
                
                
            }
            
        }
        
        
    }
    
}
