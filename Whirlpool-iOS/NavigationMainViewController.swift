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



var coordinates  = [GMSMutablePath()];

class  NavigationMainViewController: UIViewController , CLLocationManagerDelegate,GMSMapViewDelegate,GMSIndoorDisplayDelegate {
    @IBOutlet weak var mapPin: UIImageView!
    @IBOutlet weak var Address: UILabel!
    @IBOutlet weak var mapView: GMSMapView!

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.mapView.delegate = self
        parseJson( );
      
        
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // 3
        if status == .AuthorizedWhenInUse {
            
            // 4
            locationManager.startUpdatingLocation()
            
            //5
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    
   func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var location :CLLocation = locations.first!
            
            // 7
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 23, bearing: 0, viewingAngle: 0)
    
            // 8
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
                
                let jsonPath = NSBundle.mainBundle().pathForResource("b0047_01_ROOMS", ofType: "json")
                let jsonData = NSData(contentsOfFile: jsonPath!)
                
                do {
                    
                    // Load and serialize the GeoJSON into a dictionary filled with properly-typed objects
                    
                    if let jsonDict = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: []) as? NSDictionary {
                        
                        //print(jsonDict);
                        
                        // Load the `features` array for iteration
                        if let features = jsonDict["features"] as? NSArray {
                            for feature in features {

                                if let feature = feature as? NSDictionary {

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
                                                                print("Latitude:", lat)
                                                                print("Longitude:", location[i][j].doubleValue)
                                                            }
                                                            else{
                                                                lat = location[i][j].doubleValue
                                                            }

                                                        }
                                                    
                                                    }
                                                   coordinates.append(rec);
                             
                                                }
                                         
                                          
                                            }
                                           
                                            
                                        }
                                        
                                    }
                                    
                                }

                            }

                        }

                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        do {
                            self.updateUIMap()
                        }
                        catch {
                            print("Failed to update UI")
                        }
                    }
                    
                }
               
                    
                catch
                    
                {
                    
                    print("GeoJSON parsing failed")
                    
                }
                
            })

        
        }
    
    
    func updateUIMap(){
        for rect in coordinates{
            var polygon = GMSPolygon(path: rect)
            polygon.fillColor = UIColor(red:0.25, green:0, blue:0, alpha:0.05);
            polygon.strokeColor = UIColor.blackColor()
            polygon.strokeWidth = 1
            polygon.map = self.mapView
            self.view.setNeedsDisplay()
        }
    }
    
    
    /***************************************************/
    func didChangeActiveBuilding(building: GMSIndoorBuilding!) {
        
        //currentBuilding = building
        
       // var levels = currentBuilding.levels as! [GMSIndoorLevel]
        
      //  mapView.indoorDisplay.activeLevel = levels[2] // set the level (key)
        
    }
    
    func didChangeActiveLevel(level: GMSIndoorLevel!) {
        
       // println("will be called after activeBuilding")
        
    }
    /*****************************************************************/
}

    



