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
    
    let buildingToImageSmall = ["Benson Road":"BEN.png", "BHTC":"BHTC.png",
        "Edgewater":"ETC.png", "GHQ":"GHQ.png", "Harbortown": "HBT.png",
        "Hilltop 150":"HTPS.png", "Hilltop 211":"HTPN.png", "MMC":"MMC.png",
        "R&E":"R&E.png", "Riverview":"RV.png", "St. Joe Tech Center":"SJTC.png",
        "":"Whirlpool Default.png"]
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchbar: UISearchBar!
    var searchActive = false
    let getAllRoomsRequest = "https://whirlpool-indoor-maps.appspot.com/room"
    var filteredRooms = [RoomData]()
    var _roomToPass = RoomData()
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var roomDelagate: selectedRoomDataDelagate? = nil   //Data delgate to pass back the room choosen to the main page
    var allRooms = [RoomData]()
    var arrayForBool = [Bool]()
    var sectionContentDict = [String:[RoomData]]()
    var filteredSectionsContent = [String:[RoomData]]()
    var sectionTitleArray = [String]()
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = true
        self.navigationController?.navigationBar.hidden = true
        request(getAllRoomsRequest) { (response) -> Void in
            self.parseRoomsAndBuildings(response)
            self.allRooms = self.filteredRooms
            self.filteredSectionsContent = self.sectionContentDict
            dispatch_async(dispatch_get_main_queue(),{
                self.setUpTableViewSections()
                self.tableview.reloadData()
            });
        }
        tableview.separatorStyle = .SingleLine
        tableview.separatorColor = UIColor.whiteColor()
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
    
    func setUpTableViewSections(){
        for _ in 0...sectionContentDict.count-1{
            arrayForBool.append(false)
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
    
    func clearData(){
        filteredRooms = []
        allRooms = []
    }
    
    func userSelectedRoomToSend(roomData: RoomData) {
        if (roomDelagate != nil) {
            roomDelagate!.userSelectedRoom(roomData)
            clearData()
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
        if arrayForBool.count != 0 {
            return arrayForBool.count-1
        }
        return 0
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (tableView == self.searchDisplayController?.searchResultsTableView)
        {
            //return self.filteredRooms.count
            let tps = sectionTitleArray[section]
            let itemsInSection = filteredSectionsContent[tps]?.count
            return itemsInSection!
        }
        else
        {
            if arrayForBool[section].boolValue == true {
                let tps = sectionTitleArray[section]
                let itemsInSection = sectionContentDict[tps]?.count
                return itemsInSection!
            }
            //return self.allRooms.count
            return 0
        }
    }
    
    func tableView(tableView:UITableView, titleForHeaderInSection section: Int)->String? {
        return "ABC"
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 80))
        headerView.backgroundColor = UIColor.whiteColor()
        headerView.tag = section
        
        let headerImage = UIImageView(image: UIImage(named: sectionTitleArray[section] + ".png"))
        headerImage.frame = CGRect(x: 10, y: 10, width: 70, height: 70)
        headerView.addSubview(headerImage)
        
        let headerString = UILabel(frame: CGRect(x: 100, y: 20, width: tableView.frame.size.width/3, height: 40)) as UILabel
        headerString.text = sectionTitleArray[section]
        headerView.addSubview(headerString)
        
        let headerTapped = UITapGestureRecognizer (target: self, action:"sectionHeaderTapped:")
        headerView .addGestureRecognizer(headerTapped)
        
        return headerView
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        
        let cell = tableview.dequeueReusableCellWithIdentifier("cell")
        
        var room : RoomData
        
        if (tableView == searchDisplayController?.searchResultsTableView)
        {
            //room = filteredRooms[indexPath.row]
            var content = filteredSectionsContent[sectionTitleArray[indexPath.section]]
            room = content![indexPath.row]
            cell?.backgroundColor = UIColor(red: 218.0/255.0, green: 218.0/255.0, blue: 218.0/255.0, alpha: 1)
        }
        else
        {
            var content = sectionContentDict[sectionTitleArray[indexPath.section]]
            room = content![indexPath.row]
            cell?.backgroundColor = UIColor(red: 218.0/255.0, green: 218.0/255.0, blue: 218.0/255.0, alpha: 1)

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
            var content = filteredSectionsContent[sectionTitleArray[indexPath.section]]
            room = content![indexPath.row]
        }
        else
        {
            var content = sectionContentDict[sectionTitleArray[indexPath.section]]
            room = content![indexPath.row]
        }
        
        
        _roomToPass = room
        userSelectedRoomToSend(_roomToPass)
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if(arrayForBool[indexPath.section].boolValue == true || tableView == self.searchDisplayController?.searchResultsTableView){
            return 50
        }
        
        return 2
    }
    
    
    //On tap of section
    
    func sectionHeaderTapped(recognizer: UITapGestureRecognizer) {
        print("Tapping working")
        print(recognizer.view?.tag)
        
        let indexPath : NSIndexPath = NSIndexPath(forRow: 0, inSection:(recognizer.view?.tag as Int!)!)
        if (indexPath.row == 0) {
            
            var collapsed = arrayForBool[indexPath.section].boolValue
            collapsed = !collapsed
            
            arrayForBool[indexPath.section] = collapsed
            
            //reload specific section animated
            let range = NSMakeRange(indexPath.section, 1)
            let sectionToReload = NSIndexSet(indexesInRange: range)
            self.tableview.reloadSections(sectionToReload, withRowAnimation:UITableViewRowAnimation.Fade)
        }
        
    }
    
    
    
    // MARK: - Search Methods
    
    func filterContentsForSearchText(searchText: String, scope: String = "Title")
    {
        let categoryMatch = scope == "Title"
        for i in 0...sectionTitleArray.count-1{
            let buildingRooms = sectionContentDict[sectionTitleArray[i]]!
            var newFilteredRooms = [RoomData]()
            for x in 0...buildingRooms.count-1{
                let stringMatch = buildingRooms[x].GetRoomName().rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                if (categoryMatch && (stringMatch != nil)){
                    newFilteredRooms.append(buildingRooms[x])
                }
                filteredSectionsContent[sectionTitleArray[i]] = newFilteredRooms
                arrayForBool[i] = ((newFilteredRooms.count > 0) ? true : false)
            }
            
        }
        
//        self.filteredRooms = allRooms.filter({ (room: RoomData) -> Bool in
//            let categoryMatch = (scope == "Title")
//            let stringMatch = room.GetRoomName().rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
//            return categoryMatch && (stringMatch != nil)
//        })
        
        
    }
    
    func searchDisplayController(controller: UISearchController, shouldReloadTableForSearchString searchString: String)-> Bool
    {
        self.filterContentsForSearchText(searchString, scope: "Title")
        return true
    }
    
    
    func searchDisplayController(controller: UISearchController, shouldReloadTableForSearchScope searchOption: Int) -> Bool
    {
//        clearData()
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
                let room = response[i]["rooms"][x] as JSON
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
        addToSectionTitleArray(roomJson["building_name"].stringValue, room: room)
        filteredRooms.append(room)
    }
    
    func addToSectionTitleArray(sectionTitle:String, room:RoomData){
        if sectionContentDict[sectionTitle] == nil {
            sectionContentDict[sectionTitle] = [room]
            sectionTitleArray.append(sectionTitle)
        }
        else{
            sectionContentDict[sectionTitle]?.append(room)
        }
    }
    
    
    
    
}