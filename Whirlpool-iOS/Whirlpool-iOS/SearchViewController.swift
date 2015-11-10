//
//  SearchTableViewController.swift
//
//
//  Created by Jallal Elhazzat on 9/13/15.
//
//

import UIKit


protocol selectedRoomDataDelagate {
    func userSelectedRoom(roomData: RoomData)
}

class SearchViewController: UIViewController,UISearchBarDelegate,UISearchDisplayDelegate  {
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    
    
    var filteredRooms = [RoomData]()
    var _roomToPass = RoomData()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var roomDelagate: selectedRoomDataDelagate? = nil   //Data delgate to pass back the room choosen to the main page
    
    
    
    override func viewWillAppear(animated: Bool) {
        self.searchDisplayController?.active = true
        searchbar.becomeFirstResponder()
//        searchbar.backgroundColor = UIColor(colorLiteralRed: 250.0/250.0, green: 213.0/250.0, blue: 101.0/250.0, alpha: 1)
        searchbar.barTintColor = UIColor(colorLiteralRed: 250.0/250.0, green: 213.0/250.0, blue: 101.0/250.0, alpha: 1)
        searchbar.translucent = false
        self.navigationController?.navigationBar.hidden = true
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
         self.filteredRooms = _roomsData.getAllRooms()
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
            self.dismissViewControllerAnimated(true, completion: nil)
        }
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
            return self.filteredRooms.count
        }
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = tableview.dequeueReusableCellWithIdentifier("cell")
        
        var room : RoomData
        
        if (tableView == self.searchDisplayController?.searchResultsTableView)
        {
            room = filteredRooms[indexPath.row]
        }
        else
        {
            room = filteredRooms[indexPath.row]
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
            room = filteredRooms[indexPath.row]
        }
        
        
        _roomToPass = room
        userSelectedRoomToSend(_roomToPass)
        //performSegueWithIdentifier("RoomInfo", sender: self)
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return screenSize.height * 0.16
    }
    
    
    // MARK: - Search Methods
    
    func filterContenctsForSearchText(searchText: String, scope: String = "Title")
    {
        
        self.filteredRooms = _roomsData.getAllRooms().filter({( room : RoomData) -> Bool in
            var categoryMatch = (scope == "Title")
            var stringMatch = room.GetRoomName().rangeOfString(searchText)
            return categoryMatch && (stringMatch != nil)
            
        })
        
        
    }
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchString searchString: String!) -> Bool
    {
        
        self.filterContenctsForSearchText(searchString, scope: "Title")
        return true
        
        
    }
    
    
    func searchDisplayController(controller: UISearchDisplayController, shouldReloadTableForSearchScope searchOption: Int) -> Bool
    {
        
        self.filterContenctsForSearchText(self.searchDisplayController!.searchBar.text!, scope: "Title")
        return true
        
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar){
        //self.navigationController?.popToRootViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        print(segue.identifier)
        if (segue.identifier == "RoomInfo") {
            
            // initialize new view controller and cast it as your view controller
            var viewController = segue.destinationViewController as! RoomInfoViewController
            // your new view controller should have property that will store passed value
            viewController._room = _roomToPass
        }
        
    }
    
    
}