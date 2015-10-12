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
    
    override func viewWillAppear(animated: Bool) {
        self.searchDisplayController?.active = true
        self.searchbar.becomeFirstResponder()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.tableview.dataSource = self
        self.tableview.delegate = self
        
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
            print(_roomsData.count())
            return _roomsData.count()
        }
        else
        {
            print(_roomsData.count())
            return _roomsData.count()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell")
        
        var room : RoomData
        
        if (tableView == self.searchDisplayController?.searchResultsTableView)
        {
            room = _roomsData.getAllRooms()[indexPath.row]
            print(room.GetName())
        }
        else
        {
            room = _roomsData.getAllRooms()[indexPath.row]
            print(room.GetName())
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
           room = _roomsData.getAllRooms()[indexPath.row]
            print(room.GetName())
        }
        else
        {
            room = _roomsData.getAllRooms()[indexPath.row]
            print(room.GetName())
        }
        
        print(room.GetName())
        
        
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
        //self.navigationController?.pushViewController(secondViewController, animated: true)
        self.navigationController?.presentViewController(secondViewController, animated: true, completion: nil)
    }
    
    
}