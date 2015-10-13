//
//  RoomInfoViewController.swift
//  
//
//  Created by Jallal Elhazzat on 9/17/15.
//
//
import GoogleMaps
import UIKit



class RoomInfoViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var roomInfo: UITableView!
    
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var RoomNameLabel: UILabel!
    
    internal var _room = RoomData()
    

    
    @IBAction func direction(sender: AnyObject) {
        
         self.performSegueWithIdentifier("FullView", sender: nil)
        
        
    }
    
    
    
    
     var items = ["Hilltop 211","10 people","2 TVs","Phone"]
    
    
    
    override func viewWillAppear(animated: Bool) {
        if let url = NSBundle.mainBundle().URLForResource("File", withExtension: "html",subdirectory:"web"){
            let fragUrl = NSURL(string:"#FRAG_URL",relativeToURL:url)!
            let request = NSURLRequest(URL:fragUrl)
           // webView.delegate = self
            //webView.loadRequest(request)
        }
        
        if _room.GetName() != "" {
            RoomNameLabel.text = _room.GetName()
        }
        
    }
    
    
    
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //let url = NSURL (string: "http://micello.com/m/23640");
        //let requestObj = NSURLRequest(URL: url!);
        //roomView.loadRequest(requestObj);
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        /*if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "cell")
        }*/
            cell!.textLabel?.textColor = UIColor.whiteColor()
            cell!.textLabel!.text = items[indexPath.row]
        
            return cell!
        
    }
    
    
    func webView(webView:UIWebView, shouldStartLoadingWithRequest request:NSURLRequest,navigationType: UIWebViewNavigationType)->Bool
    {
        NSLog("request:\(request)")
        
        if let scheme = request.URL?.scheme{
            if(scheme == "Jallal"){
                NSLog("we got Jallal request:\(scheme)");
                if let result = webView.stringByEvaluatingJavaScriptFromString("Jallal.SomeJavaScriptFunc()"){
                    NSLog("Result:\(result)")
                }
                return false;
            }
        }
        
        return true;
        
        
    }

    

}
