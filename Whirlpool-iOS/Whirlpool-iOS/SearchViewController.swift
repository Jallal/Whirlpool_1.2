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
    
    var friendsArray = [FriendItem]()
    var filteredFriends = [FriendItem]()
    
    override func viewWillAppear(animated: Bool) {
        self.searchDisplayController?.active = true
        self.searchbar.becomeFirstResponder()
        fetchEvents()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.friendsArray += [FriendItem(name: "Vea Software")]
        self.friendsArray += [FriendItem(name: "Apple")]
        self.friendsArray += [FriendItem(name: "iTunes")]
        self.friendsArray += [FriendItem(name: "iPhone")]
        self.friendsArray += [FriendItem(name: "Mac")]
        self.tableView.reloadData()
        
    }
    
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func fetchEvents(){
        let query = GTLQueryCalendar.queryForEventsListWithCalendarId("primary")
        query.maxResults = 10
        query.timeMin = GTLDateTime(date: NSDate(), timeZone: NSTimeZone.localTimeZone())
        query.singleEvents = true
        query.orderBy = kGTLCalendarOrderByStartTime
        service.executeQuery(
            query,
            delegate: self,
            didFinishSelector: "displayResultWithTicket:finishedWithObject:error:"
        )
        
    }
    
    
    
    // Display the start dates and event summaries in the UITextView
    public func displayResultWithTicket(
        ticket: GTLServiceTicket,
        finishedWithObject events : GTLCalendarEvents?,
        error : NSError?) {
            
            if let error = error {
                showAlertLogin("Error", message: error.localizedDescription)
                return
            }
            
            var eventString = ""
            if events?.items() != nil {
                if events!.items().count > 0 {
                    for event in events!.items() as! [GTLCalendarEvent] {
                        let location = event.location;
                        NSLog(event.summary)
                        self.friendsArray += [FriendItem(name: event.summary)]
                    }
                } else {
                    eventString = "No upcoming events found."
                }
            }
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
            return self.filteredFriends.count
        }
        else
        {
            return self.friendsArray.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell")
        
        var friend : FriendItem
        
        if (tableView == self.searchDisplayController?.searchResultsTableView)
        {
            friend = self.filteredFriends[indexPath.row]
        }
        else
        {
            friend = self.friendsArray[indexPath.row]
        }
        
        cell!.textLabel?.text = friend.name
        
        return cell!
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var friend : FriendItem
        
        if (tableView == self.searchDisplayController?.searchResultsTableView)
        {
            friend = self.filteredFriends[indexPath.row]
        }
        else
        {
            friend = self.friendsArray[indexPath.row]
        }
        
        print(friend.name)
        
        
    }
    
    // MARK: - Search Methods
    
    func filterContenctsForSearchText(searchText: String, scope: String = "Title")
    {
        
        self.filteredFriends = self.friendsArray.filter({( friend : FriendItem) -> Bool in
            
            var categoryMatch = (scope == "Title")
            var stringMatch = friend.name.rangeOfString(searchText)
            
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