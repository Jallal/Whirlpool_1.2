//
//  NavigationFULLViewController.swift
//  
//
//  Created by Jallal Elhazzat on 9/17/15.
//
//

import UIKit
import GoogleMaps

class NavigationFULLViewController: UIViewController, CLLocationManagerDelegate ,GMSMapViewDelegate {
    
      //  @IBOutlet weak var mapView: GMSMapView!
        
    @IBOutlet weak var mapView: GMSMapView!
    //var _roomToPass = RoomData()
   // var allTheRooms = _roomsData.getAllRooms();
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
        var location :CLLocation = locations.first!
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 20, bearing: 0, viewingAngle: 0)
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
        
        
        let geocoder = GMSGeocoder()
        
        
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                
                let lines = address.lines as! [String]
                //self.Address.text = lines.joinWithSeparator(", ")
                
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
            
            let jsonPath = NSBundle.mainBundle().pathForResource("b0047_01_ROOMS", ofType: "json")
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
                                        RoomInformation.SetRoomNumber(roomNum as! String)
                                        
                                    }
                                    
                                }
                                if let geometry = feature["geometry"] as? NSDictionary {
                                    
                                    
                                    if geometry["type"] as? String == "Polygon" {
                                        
                                        // Create an array to hold the formatted coordinates for our line
                                        
                                        //var coordinates: [CLLocationCoordinate2D] = []
                                        
                                        if let locations = geometry["coordinates"] as? NSArray {
                                            
                                            // Iterate over line coordinates, stored in GeoJSON as many lng, lat arrays
                                            var maxX : double_t = -400
                                            var maxY : double_t = -400
                                            var minX : double_t = 400
                                            var minY : double_t = 400
                                            
                                            for location in locations {
                                                var rec = GMSMutablePath()
                                                
                                                for var i = 0; i < location.count; i++ {
                                                    var lat = 0 as Double
                                                    for var j = 0; j < location[i].count; j++ {
                                                        
                                                        if (j+1 == location[i].count){
                                                            rec.addCoordinate(CLLocationCoordinate2DMake(location[i][j].doubleValue,lat))
                                                            if(maxX < location[i][j].doubleValue){
                                                                maxX = location[i][j].doubleValue
                                                            }
                                                            if(maxY < lat){
                                                                maxY = lat
                                                            }
                                                            if(minX > location[i][j].doubleValue){
                                                                minX = location[i][j].doubleValue
                                                            }
                                                            if(minY > lat){
                                                                minY = lat
                                                            }
                                                            
                                                        }
                                                        else{
                                                            lat = location[i][j].doubleValue
                                                            if(maxY <  lat){
                                                                maxY = lat
                                                            }
                                                            if(minY >  lat){
                                                                minY = lat
                                                            }
                                                            
                                                        }
                                                    }

                                                    
                                                }
                                                RoomInformation.SetroomCenter((minX+maxX)/2, y: ((minY+maxY)/2))
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
                    
                    
                    print("^^^^^^^^^^^^^^^^^^^^^^^^^^")
                    print(room.GetRoomNumber())
                    
                    
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
                    polygon.fillColor = UIColor(red:1.0, green:0.2, blue:0.3, alpha:0.9);
                }else{
                    polygon.fillColor = UIColor(red:0.25, green:0, blue:0, alpha:0.05);
                }
               
                if(room.GetRoomNumber()=="105B"){
                    var position = room.GetroomCenter()
                    var restroom = GMSMarker(position: position)
                    restroom.icon = UIImage(named: "restroom.jpg")
                   restroom.flat = true
                   restroom.map = self.mapView
                }
                if((room.GetRoomNumber()=="111")||(room.GetRoomNumber()=="109")){
                   
                    var position = room.GetroomCenter()
                    var conference = GMSMarker(position: position)
                    conference.icon = UIImage(named: "conference.jpg")
                    conference.flat = true
                    conference.map = self.mapView
                }
                if((room.GetRoomNumber()=="SW1")){
                    var position = room.GetroomCenter()
                    var exit = GMSMarker(position: position)
                    exit.icon = UIImage(named: "exit.jpg")
                    exit.flat = true
                    exit.map = self.mapView
                }
                
                polygon.strokeColor = UIColor.blackColor()
                polygon.strokeWidth = 1
                polygon.title = room.GetRoomNumber();
                polygon.tappable = true;
                polygon.map = self.mapView
                self.view.setNeedsDisplay()
                
            }
            
        }
        
        
        
    }
    
    func mapView(mapView: GMSMapView!, didTapOverlay overlay: GMSOverlay!) {
        if((overlay.title) != nil){
            for room in self.roomdata.getAllRooms(){
                if(room.GetRoomNumber() == overlay.title){
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
}

