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
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.mapView.delegate = self
        self.reDraw()
        
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    
   func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
    

    
    
    func updateUIMap(){
        for room in _roomsData.getAllRooms(){
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
            for room in _roomsData.getAllRooms(){
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
}

    



