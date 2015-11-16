//
//  SearchTableViewController.swift
//
//
//  Created by Jallal Elhazzat on 9/13/15.
//
//

import UIKit
import SwiftyJSON

public extension UIColor {
    func convertImage() -> UIImage {
        let rect : CGRect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContext(rect.size)
        let context : CGContextRef = UIGraphicsGetCurrentContext()!
        
        CGContextSetFillColorWithColor(context, self.CGColor)
        CGContextFillRect(context, rect)
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

protocol selectedRoomDataDelagate {
    func userSelectedRoom(roomData: RoomData)
}

class SearchViewController: UIViewController,UISearchBarDelegate, UISearchControllerDelegate  {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    
    var searchActive = false
    let getAllRoomsRequest = "https://whirlpool-indoor-maps.appspot.com/room"
    var filteredRooms = [RoomData]()
    var _roomToPass = RoomData()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var _buildings: BuildingsData?
    var roomDelagate: selectedRoomDataDelagate? = nil   //Data delgate to pass back the room choosen to the main page
    var allRooms = [RoomData]()
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = true
        self.navigationController?.navigationBar.hidden = true
        request(getAllRoomsRequest) { (response) -> Void in
            self.parseRoomsAndBuildings(response)
            self.allRooms = self.filteredRooms
            dispatch_async(dispatch_get_main_queue(),{
                self.tableview.reloadData()
            });
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.setUpSearchBarAppearence()
        tableview.reloadData()
    }
    
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Helper for showing an alert
    func showAlertLogin(title : String, message: String) {
        let alert = UIAlertView(
            title: title,
            message: message,
            delegate: nil,
            cancelButtonTitle: "OK"
        )
        alert.show()
    }
    
    func userSelectedRoomToSend(roomData: RoomData) {
        if (roomDelagate != nil) {
            roomDelagate!.userSelectedRoom(roomData)
            UIApplication.sharedApplication().statusBarHidden = false
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func setUpSearchBarAppearence(){
        searchbar.tintColor = UIColor.whiteColor()
        searchbar.setShowsCancelButton(false, animated: false)
        searchbar.backgroundImage = UIColor(red: 250.0/250.0, green: 213.0/250.0, blue: 101.0/250.0, alpha: 1).convertImage()
        searchbar.barTintColor = UIColor(red: 251.0/255.0, green: 225.0/255.0, blue: 131.0/255.0, alpha: 1)
        let textFieldInsideSearchBar = searchbar.valueForKey("searchField") as? UITextField
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.valueForKey("placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = UIColor.whiteColor()
        textFieldInsideSearchBar?.textColor = UIColor.whiteColor()
        textFieldInsideSearchBar?.backgroundColor = UIColor(red: 251.0/255.0, green: 225.0/255.0, blue: 131.0/255.0, alpha: 1)
    }
    
    // MARK: - Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (tableView == self.searchDisplayController?.searchResultsTableView)
        {
            return self.filteredRooms.count
        }
        else
        {
            return self.allRooms.count
        }
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = tableview.dequeueReusableCellWithIdentifier("cell")
        
        var room : RoomData
        
        if (tableView == searchDisplayController?.searchResultsTableView)
        {
            room = filteredRooms[indexPath.row]
        }
        else
        {
            room = allRooms[indexPath.row]
        }
        cell!.textLabel?.text = room.GetRoomName()
        return cell!

        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var room : RoomData
        
        if (tableView == self.searchDisplayController?.searchResultsTableView)
        {
           room = filteredRooms[indexPath.row]
        }
        else
        {
            room = allRooms[indexPath.row]
        }
        
        
        _roomToPass = room
        userSelectedRoomToSend(_roomToPass)
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return screenSize.height * 0.16
    }
    
    
    // MARK: - Search Methods
    
    func filterContentsForSearchText(searchText: String, scope: String = "Title")
    {
        
        self.filteredRooms = allRooms.filter({ (room: RoomData) -> Bool in
            let categoryMatch = (scope == "Title")
            let stringMatch = room.GetRoomName().rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return categoryMatch && (stringMatch != nil)
        })
        
        
    }
    
    func searchDisplayController(controller: UISearchController, shouldReloadTableForSearchString searchString: String)-> Bool
    {
        self.filterContentsForSearchText(searchString, scope: "Title")
        return true
    }
    
    
    func searchDisplayController(controller: UISearchController, shouldReloadTableForSearchScope searchOption: Int) -> Bool
    {
        self.filterContentsForSearchText(self.searchDisplayController!.searchBar.text!, scope: "Title")
        return true
    }

    
    func searchBarCancelButtonClicked(searchBar: UISearchBar){
        UIApplication.sharedApplication().statusBarHidden = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func request( destination : String, successHandler: (response: JSON) -> Void){
        let request = NSMutableURLRequest(URL: NSURL(string: destination as String)!)
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
    
    func parseRoomsAndBuildings(response: JSON){
        for i in 0...response.count-1{
            for x in 0...response[i]["rooms"].count-1{
                var room = response[i]["rooms"][x] as JSON
                createRoomFromJSON(room)
            }
        }
    }
    
    func createRoomFromJSON(roomJson:JSON){
        let room = RoomData()
        room.SetRoomName(roomJson["room_name"].stringValue)
        room.SetRoomEmail(roomJson["email"].stringValue)
        room.SetRoomCapacity(roomJson["capacity"].intValue)
        room.SetRoomStatus(roomJson["occupancy_status"].stringValue)
        room.SetRoomExt(roomJson["extension"].stringValue)
        room.SetRoomType(roomJson["room_type"].stringValue)
        room.SetRoomLocation(roomJson["resource_name"].stringValue)
        room.SetRoomBuildingName(roomJson["building_name"].stringValue)
        filteredRooms.append(room)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        print(segue.identifier)
        if (segue.identifier == "RoomInfo") {
            
            // initialize new view controller and cast it as your view controller
            let viewController = segue.destinationViewController as! RoomInfoViewController
            // your new view controller should have property that will store passed value
            viewController._room = _roomToPass
        }
        
    }
    
    
}