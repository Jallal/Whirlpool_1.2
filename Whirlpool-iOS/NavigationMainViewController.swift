//
//  NavigationMainViewController.swift
//  Whirlpool-iOS
//
//  Created by Jallal Elhazzat on 9/28/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps



class  NavigationMainViewController: UIViewController , CLLocationManagerDelegate,GMSMapViewDelegate,GMSIndoorDisplayDelegate {
    let baseURLDirections = "https://maps.googleapis.com/maps/api/directions/json?"
    
    var selectedRoute: Dictionary<NSObject, AnyObject>!
    
    var overviewPolyline: Dictionary<NSObject, AnyObject>!
    
    var originCoordinate: CLLocationCoordinate2D!
    
    var destinationCoordinate: CLLocationCoordinate2D!
    
    var totalDistanceInMeters: UInt = 0
    
    var totalDistance: String!
    
    var totalDurationInSeconds: UInt = 0
    
    var totalDuration: String!
    
    var originMarker: GMSMarker!
    
    var destinationMarker: GMSMarker!
    
    var routePolyline: GMSPolyline!
    
    var markersArray: Array<GMSMarker> = []
    
    var waypointsArray: Array<String> = []
    
    var originAddress : String = "2000 N. M-63 Benton Harbor, MI, 49022-2692"
    var destinationAddress : String = "220 Trowbridge Rd, East Lansing, MI 48824"
    @IBOutlet weak var mapPin: UIImageView!
    @IBOutlet weak var Address: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    
    
    @IBAction func startDirections(sender: AnyObject) {
        self.getDirections(self.originAddress, destination: self.destinationAddress, waypoints: waypointsArray, travelMode: nil, completionHandler: { (status, success) -> Void in
            
            if success {
                self.configureMapAndMarkersForRoute()
                self.drawRoute()
                self.displayRouteInfo()
            }
            else {
                print("********************************************************")
                print(status)
                print("********************************************************")
            }
        })
        }
    
    
    
    var roomdata  =  RoomsData();
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.mapView.delegate = self
        parseJson( );
        
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    
   func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //var location :CLLocation = locations.first!
            //mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 20, bearing: 0, viewingAngle: 0)
    
        let position = CLLocationCoordinate2D(latitude: 42.1124531749125, longitude: -86.4693216079577)
      mapView.camera = GMSCameraPosition(target: position, zoom: 20, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        updateLocation(true)
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
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        
        reverseGeocodeCoordinate(position.target)
    }
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        // 1
        let geocoder = GMSGeocoder()
        
        // 2
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                
                // 3
                let lines = address.lines as! [String]
                 self.Address.text = lines.joinWithSeparator(", ")
                
                // 4
                UIView.animateWithDuration(0.25) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    

    func parseJson( ){
            
            // Parsing GeoJSON can be CPU intensive, do it on a background thread
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                
                // Get the path for example.geojson in the app's bundle
                
                let jsonPath = NSBundle.mainBundle().pathForResource("RVCB2B_P_ROOMS", ofType: "json")
                let jsonData = NSData(contentsOfFile: jsonPath!)
                
                do {
                    
                    // Load and serialize the GeoJSON into a dictionary filled with properly-typed objects
                    
                    if let jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: []) as? NSDictionary {
                        
                        //print(jsonDict);
                        
                        // Load the `features` array for iteration
                        if let features = jsonDict["features"] as? NSArray {
                            
                            for feature in features {
                                var RoomInformation  = RoomData();
                                if let feature = feature as? NSDictionary {
                                    if let  property = feature["properties"] as? NSDictionary {
  
                                        if let roomNum = property["room"]{
                                            RoomInformation.SetRoomName(roomNum as! String)
                                            
                                        }

                                    }
                                    if let geometry = feature["geometry"] as? NSDictionary {
                                        
                                        
                                        if geometry["type"] as? String == "Polygon" {
                                            
                                            // Create an array to hold the formatted coordinates for our line
                                            
                                            //var coordinates: [CLLocationCoordinate2D] = []
                                           
                                            if let locations = geometry["coordinates"] as? NSArray {
                                                
                                                // Iterate over line coordinates, stored in GeoJSON as many lng, lat arrays

                                                for location in locations {
                                                    var rec = GMSMutablePath()
                                                 
                                                    for var i = 0; i < location.count; i++ {
                                                        var lat = 0 as Double
                                                        for var j = 0; j < location[i].count; j++ {
                                                            
                                                            if (j+1 == location[i].count){
                                                                rec.addCoordinate(CLLocationCoordinate2DMake(location[i][j].doubleValue,lat))
                                                            }
                                                            else{
                                                                lat = location[i][j].doubleValue
                                                            }

                                                        }
                                                    
                                                    }
                                                 RoomInformation.SetRoomCoordinates(rec)
                                                }
                                         
                                          
                                            }
                                          
                                            
                                        }
                                    }
                                }
                                self.roomdata.addARoom(RoomInformation)
                            }
                        }

                    }
                    self.reDraw()
                }
               
                    
                catch
                    
                {
                    
                    print("GeoJSON parsing failed")
                    
                }
                
            })
        
        }
    
    
    func updateUIMap(){
        for room in self.roomdata.getAllRooms(){
            for rect in room.GetRoomCoordinates(){
                var polygon = GMSPolygon(path: rect)
                if(room.GetIsSelected()){
                    var position = room.GetroomCenter()
                    var marker = GMSMarker(position: position)
                    marker.appearAnimation = kGMSMarkerAnimationPop
                    // marker.icon = UIImage(named: "restroom.jpg")
                    marker.icon = UIImage(named: "mapannotation.png")
                    marker.flat = true
                    marker.map = self.mapView
                    //var london = GMSMarker(position: position)
                    //london.icon = UIImage(named: "restroom")
                    //london.flat = true
                    //london.map = self.mapView
                    //polygon.fillColor = UIColor(red:1.0, green:0.2, blue:0.3, alpha:0.9);
                    polygon.fillColor = UIColor(red:(137/255.0), green:196/255.0, blue:244/255.0, alpha:1.0);
                }else{
                    polygon.fillColor = UIColor(red:(255/255.0), green:249/255.0, blue:236/255.0, alpha:1.0);
                    // polygon.fillColor = UIColor(red:(191/255.0), green:191/255.0, blue:191/255.0, alpha:1.0);
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
            for room in self.roomdata.getAllRooms(){
                if(room.GetRoomName() == overlay.title){
                    room.SetIsSelected(true);
                }else{
                    room.SetIsSelected(false);
                }
                
            }
            self.mapView.clear();
            self.reDraw();
        }
        
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
    

    
    
    
    func getDirections(origin: String!, destination: String!, waypoints: Array<String>!, travelMode: AnyObject!, completionHandler: ((status: String, success: Bool) -> Void)) {
        
        
        print("********************************************************")
        print(origin)
        print(destination)
        print(waypoints)
        //print(travelMode)
        //print(completionHandler)
        print("********************************************************")
        /*if let originLocation = origin {
            if let destinationLocation = destination {
                var directionsURLString = baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation
                
                directionsURLString = directionsURLString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!*/
        var originalLoc =  CLLocationCoordinate2D(latitude: 42.1124531749125, longitude: -86.4693216079577)
        
        var destinationLoc =  CLLocationCoordinate2D(latitude: 42.1124531749125, longitude: -86.4693216079577)
        
                if let originLocation = origin {
                    if let destinationLocation = destination {
                        var directionsURLString = baseURLDirections + "origin=" + self.originAddress + "&destination=" + self.destinationAddress
                        
                          //var directionsURLString = baseURLDirections + "origin=" + originLocation + "&destination=" + destinationLocation
                        
                        if let routeWaypoints = waypoints {
                            directionsURLString += "&waypoints=optimize:true"
                            
                            for waypoint in routeWaypoints {
                                directionsURLString += "|" + waypoint
                            }
                        }
                
                
                
                
                
                let directionsURL = NSURL(string: directionsURLString)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let directionsData = NSData(contentsOfURL: directionsURL!)
                    
                    var error: NSError?
                    //let dictionary: Dictionary<NSObject, AnyObject> = NSJSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<NSObject, AnyObject>
                    
                    
                    do {
                        let dictionary : Dictionary<NSObject, AnyObject> = try NSJSONSerialization.JSONObjectWithData(directionsData!, options: NSJSONReadingOptions.MutableContainers) as! Dictionary<NSObject, AnyObject>
                        let status = dictionary["status"] as! String
                        
                        if status == "OK" {
                            self.selectedRoute = (dictionary["routes"] as! Array<Dictionary<NSObject, AnyObject>>)[0]
                            self.overviewPolyline = self.selectedRoute["overview_polyline"] as! Dictionary<NSObject, AnyObject>
                            
                            let legs = self.selectedRoute["legs"] as! Array<Dictionary<NSObject, AnyObject>>
                            
                            let startLocationDictionary = legs[0]["start_location"] as! Dictionary<NSObject, AnyObject>
                            self.originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                            
                            let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<NSObject, AnyObject>
                            self.destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)
                            
                            self.originAddress = legs[0]["start_address"] as! String
                            self.destinationAddress = legs[legs.count - 1]["end_address"] as! String
                            
                            self.calculateTotalDistanceAndDuration()
                            
                            completionHandler(status: status, success: true)
                        }
                        else {
                            completionHandler(status: status, success: false)
                        }
                    }catch let error as NSError    {
                        print(error)
                        completionHandler(status: "", success: false)
                    }
                })
            }
            else {
                completionHandler(status: "Destination is nil.", success: false)
            }
        }
        else {
            completionHandler(status: "Origin is nil", success: false)
        }
    }
    
    func calculateTotalDistanceAndDuration() {
        let legs = self.selectedRoute["legs"] as! Array<Dictionary<NSObject, AnyObject>>
        
        totalDistanceInMeters = 0
        totalDurationInSeconds = 0
        
        for leg in legs {
            totalDistanceInMeters += (leg["distance"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
            totalDurationInSeconds += (leg["duration"] as! Dictionary<NSObject, AnyObject>)["value"] as! UInt
        }
        
        
        let distanceInKilometers: Double = Double(totalDistanceInMeters / 1000)
        totalDistance = "Total Distance: \(distanceInKilometers) Km"
        
        
        let mins = totalDurationInSeconds / 60
        let hours = mins / 60
        let days = hours / 24
        let remainingHours = hours % 24
        let remainingMins = mins % 60
        let remainingSecs = totalDurationInSeconds % 60
        
        totalDuration = "Duration: \(days) d, \(remainingHours) h, \(remainingMins) mins, \(remainingSecs) secs"
    }
    
    
    @IBAction func createRoute(sender: AnyObject) {
        let addressAlert = UIAlertController(title: "Create Route", message: "Connect locations with a route:", preferredStyle: UIAlertControllerStyle.Alert)
        
        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Origin?"
        }
        
        addressAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Destination?"
        }
        
        
        let createRouteAction = UIAlertAction(title: "Create Route", style: UIAlertActionStyle.Default) { (alertAction) -> Void in
            let origin = (addressAlert.textFields![0] ).text as! String?
            let destination = (addressAlert.textFields![1] ).text as! String?
            
            self.getDirections(origin, destination: destination, waypoints: nil, travelMode: nil, completionHandler: { (status, success) -> Void in
                if success {
                    self.configureMapAndMarkersForRoute()
                    self.drawRoute()
                    self.displayRouteInfo()
                }
                else {
                    print(status)
                }
            })
        }
        
        let closeAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel) { (alertAction) -> Void in
            
        }
        
        addressAlert.addAction(createRouteAction)
        addressAlert.addAction(closeAction)
        
        presentViewController(addressAlert, animated: true, completion: nil)
    }
    
    func configureMapAndMarkersForRoute() {
        self.mapView.camera = GMSCameraPosition.cameraWithTarget(self.originCoordinate, zoom: 9.0)
        originMarker = GMSMarker(position: self.originCoordinate)
        originMarker.map = self.mapView
        originMarker.icon = GMSMarker.markerImageWithColor(UIColor.greenColor())
        //originMarker.title = self.originAddress
        
        destinationMarker = GMSMarker(position: self.destinationCoordinate)
        destinationMarker.map = self.mapView
        destinationMarker.icon = GMSMarker.markerImageWithColor(UIColor.redColor())
        //destinationMarker.title = self.destinationAddress
        if waypointsArray.count > 0 {
            for waypoint in waypointsArray {
                let lat: Double = (waypoint.componentsSeparatedByString(",")[0] as NSString).doubleValue
                let lng: Double = (waypoint.componentsSeparatedByString(",")[1] as NSString).doubleValue
                
                let marker = GMSMarker(position: CLLocationCoordinate2DMake(lat, lng))
                marker.map = self.mapView
                marker.icon = GMSMarker.markerImageWithColor(UIColor.purpleColor())
                
                markersArray.append(marker)
            }
        }
    }
    
    func drawRoute() {
        let route = self.overviewPolyline["points"] as! String
        
        let path: GMSPath = GMSPath(fromEncodedPath: route)
        routePolyline = GMSPolyline(path: path)
        routePolyline.map = self.mapView
    }
    
    func displayRouteInfo() {
        Address.text = self.totalDistance + "\n" + self.totalDuration
    }
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        if let polyline = routePolyline {
            let positionString = String(format: "%f", coordinate.latitude) + "," + String(format: "%f", coordinate.longitude)
            waypointsArray.append(positionString)
            
            recreateRoute()
        }
    }
    
    func clearRoute() {
        originMarker.map = nil
        destinationMarker.map = nil
        routePolyline.map = nil
        
        originMarker = nil
        destinationMarker = nil
        routePolyline = nil
        
        if markersArray.count > 0 {
            for marker in markersArray {
                marker.map = nil
            }
            
            markersArray.removeAll(keepCapacity: false)
        }
    }
    
    func recreateRoute() {
        print("********************************************************")
        //print(status)
        print("********************************************************")
        if let polyline = routePolyline {
           clearRoute()
            
            self.getDirections(self.originAddress, destination: self.destinationAddress, waypoints: waypointsArray, travelMode: nil, completionHandler: { (status, success) -> Void in
                
                if success {
                    self.configureMapAndMarkersForRoute()
                    self.drawRoute()
                    self.displayRouteInfo()
                }
                else {
                    print("********************************************************")
                    print(status)
                    print("********************************************************")
                }
            })
        }
    }
    
    
}

    



