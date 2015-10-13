//
//  SearchTableViewController.swift
//
//
//  Created by Jallal Elhazzat on 9/13/15.
//
//

import UIKit

class SearchViewController: UITableViewController,UISearchBarDelegate,UISearchDisplayDelegate  {
    
    @IBOutlet var tableview: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    
    var filteredRooms = [RoomData]()
    var _roomToPass = RoomData()
    
    override func viewWillAppear(animated: Bool) {
        self.searchDisplayController?.active = true
        self.searchbar.becomeFirstResponder()
        self.filteredRooms = _roomsData.getAllRooms()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableview.dataSource = self
        self.tableview.delegate = self
        
        for room in _roomsData.getAllRooms(){
            print(room.GetEmail(), ",",room.GetName())
        }
        
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
    
    // MARK: - Table View
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
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
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell")
        
        var room : RoomData
        
        if (tableView == self.searchDisplayController?.searchResultsTableView)
        {
            room = filteredRooms[indexPath.row]
        }
        else
        {
            room = filteredRooms[indexPath.row]
        }
        
        cell!.textLabel?.text = room.GetName()
        
        return cell!
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
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
        performSegueWithIdentifier("RoomInfo", sender: self)
        
    }
    
    // MARK: - Search Methods
    
    func filterContenctsForSearchText(searchText: String, scope: String = "Title")
    {
        
        self.filteredRooms = _roomsData.getAllRooms().filter({( room : RoomData) -> Bool in
            var categoryMatch = (scope == "Title")
            var stringMatch = room.GetName().rangeOfString(searchText)
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
        let secondViewController = self.storyboard?.instantiateViewControllerWithIdentifier("MainViewController") as! MainViewController
        self.navigationController?.presentViewController(secondViewController, animated: true, completion: nil)
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