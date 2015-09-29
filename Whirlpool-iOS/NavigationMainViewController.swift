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


class  NavigationMainViewController: UIViewController, CLLocationManagerDelegate {
    
    
    
    let locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        var cameraBuilding = GMSCameraPosition.cameraWithLatitude(42.96356, longitude: -85.8899, zoom: 14.7)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: cameraBuilding)
        mapView.settings.compassButton = true
        self.view = mapView
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(42.96356, -85.8999)
        marker.title = "Whirlpool"
        marker.snippet = "Harbor, MI"
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = mapView
        
    }
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        updateLocation(false)
        updateLocation(true)
        
        
    }
    
    func updateLocation(running : Bool){
        let mapView = self.view as! GMSMapView
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
        updateLocation(true)
    }
    
    
    
    
    
    
}