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

        let locationManager = CLLocationManager()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.locationManager.delegate = self
            self.locationManager.requestAlwaysAuthorization()
            self.mapView.delegate = self
            
            
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
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            
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
                    
                    // 4
                    UIView.animateWithDuration(0.25) {
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
}

