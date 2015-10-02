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


class  NavigationMainViewController: UIViewController , CLLocationManagerDelegate,GMSMapViewDelegate {
    
    
    @IBOutlet weak var mapPin: UIImageView!
    @IBOutlet weak var Address: UILabel!
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
                 self.Address.text = lines.joinWithSeparator(", ")
                
                // 4
                UIView.animateWithDuration(0.25) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    
    
    /*
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //let mapView = self.view as! GMSMapView
        let location :CLLocation = locations.first!
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        geoCode(location);
        
    }
    
   func geoCode(location : CLLocation!){
        geoCoder.cancelGeocode()
        geoCoder.reverseGeocodeLocation(location, completionHandler : { (data, error) -> Void in
            guard let placeMarks = data as [CLPlacemark]! else {
                return
            }
            let loc : CLPlacemark = placeMarks[0]
            let addressDict : [NSString : NSObject] = loc.addressDictionary  as! [NSString:NSObject]
            let addressList = addressDict["FormattedAddressLines"] as! [String]
            let address = addressList.joinWithSeparator(", ")
            print(address)
            //self.Address.text = address
            self.previousAddress = address
        })
    
        }
    
    
    
    
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        updateLocation(false)
        updateLocation(true)
        
        
    }
    
    func updateLocation(running : Bool){
        //let mapView = self.view as! GMSMapView
        let status = CLLocationManager.authorizationStatus()
        if running{
            if(CLAuthorizationStatus.AuthorizedWhenInUse == status){
                locationManager.startUpdatingLocation()
                mapView.myLocationEnabled = true
                mapView.settings.myLocationButton = true
            }
        }else{
            locationManager.startUpdatingLocation()
            mapView.settings.myLocationButton = false
            mapView.myLocationEnabled = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        //updateLocation(true)
    }*/
    
    }



