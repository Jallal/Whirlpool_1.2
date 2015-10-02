//
//  NavigationFULLViewController.swift
//  
//
//  Created by Jallal Elhazzat on 9/17/15.
//
//

import UIKit
import GoogleMaps

class NavigationFULLViewController: UIViewController, CLLocationManagerDelegate{
    
    let locationManager = CLLocationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
         var cameraBuilding = GMSCameraPosition.cameraWithLatitude(42.724209, longitude: -84.480803, zoom: 14.7)
        let mapView = GMSMapView.mapWithFrame(CGRectZero, camera: cameraBuilding)
        mapView.settings.compassButton = true
        self.view = mapView
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(42.724209, -84.480803)
       marker.icon = UIImage(named: "mapannotation")
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
  
    
    /*
    
    override func viewWillAppear(animated: Bool) {
        if let url = NSBundle.mainBundle().URLForResource("index", withExtension: "html",subdirectory:"web"){
        let fragurl = NSURL(string:"#FRAG_URL",relativeToURL:url)!
        let request = NSURLRequest(URL:fragurl)
        webView.delegate = self
        webView.loadRequest(request)
        }
        
    }
    
    
    func webView(webView:UIWebView, shouldStartLoadingWithRequest request:NSURLRequest,navigationType: UIWebViewNavigationType)->Bool
    {
        NSLog("request:\(request)")
        
        if let scheme = request.URL?.scheme{
            if(scheme == "Jallal"){
                NSLog("we got mike request:\(scheme)");
                webView.stringByEvaluatingJavaScriptFromString("SomeJavaScriptFunc()")
                return false;
            }
        }
        
        return true;
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
*/

}
