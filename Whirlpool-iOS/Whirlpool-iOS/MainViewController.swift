//
//  MainViewController.swift
//  
//
//  Created by Jallal Elhazzat on 9/16/15.
//
//
import Foundation
import UIKit
import CoreData


var FAVORITE_ROOM_SELECTED:RoomData?

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate,UITabBarDelegate, selectedRoomDataDelagate,selectedFavoriteDelagate, buildingsLoadedDelegate, UICollectionViewDelegateFlowLayout, buildingButtonTappedDelegate{
    
    let buildingToImageLarge = ["Benson Road":"BEN - L.png", "BHTC":"BHTC - L.png",
    "Edgewater":"ETC - L.png", "GHQ":"GHQ - L.png", "Harbortown": "HBT - L.png",
        "Hilltop 150":"HTPS - L.png", "Hilltop 211":"HTPN - L.png", "MMC":"MMC - L.png",
        "R&E":"R&E - L.png", "Riverview":"RV - L.png", "St. Joe Tech Center":"SJTC - L.png",
        "":"Whirlpool Default - L.png"]
    
    let buildingToImageSmall = ["Benson Road":"BEN.png", "BHTC":"BHTC.png",
        "Edgewater":"ETC.png", "GHQ":"GHQ.png", "Harbortown": "HBT.png",
        "Hilltop 150":"HTPS.png", "Hilltop 211":"HTPN.png", "MMC":"MMC.png",
        "R&E":"R&E.png", "Riverview":"RV.png", "St. Joe Tech Center":"SJTC.png",
        "":"Whirlpool Default.png"]
    
    let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    var buildings: BuildingsData!
    var items = ["one","two"]
    var tableData = ["nine","six"]
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var _favorites = [NSManagedObject]()
    var _roomToPass = RoomData()
    var searchedForRoom = false
    var specificSearchedRoom: RoomData? = nil
    var clickedEdit = false
    var editingEventToPass: CalenderEvent?
    var _buildingAbb:String?
    @IBOutlet weak var calender: UITableView!
    @IBOutlet weak var buildingScroller: UICollectionView!
    @IBAction func favoriteListButton(sender: AnyObject) {
        self.navigationController?.navigationBar.hidden = true
    }
    func userSelectedRoom(roomData: RoomData) {
            specificSearchedRoom = roomData
            performSegueWithIdentifier("searchSegToRoom", sender: self)
    }
    func userSelectedFavorite(favRoom: RoomData) {
        _roomToPass = favRoom
        print(_roomToPass.GetRoomName())
        performSegueWithIdentifier("relevantSeg", sender: self)
    }
    func buildingAbbsHaveBeenLoaded(){
        dispatch_async(dispatch_get_main_queue(),{
            self.buildingScroller.reloadData()
        });
    }
    func buildingInfoHasBeenLoaded(){
    //print( _buildings._buildings["GHQ"]?._floors)
    }
    
    func buildingSelected(buildingAbb:String) {
        _buildingAbb = buildingAbb
        performSegueWithIdentifier("buildingMaps", sender: self)
    }
    
    @IBAction func clickedOnSearch(sender: AnyObject) {
        performSegueWithIdentifier("popUpSearchSeg", sender: self)
    }
    
    @IBOutlet weak var OpenHamburger: UIBarButtonItem!
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.buildings = BuildingsData(delegate: self) //Grabs the abbreviations
        self.calender.reloadData()
        //Check to see if we are coming from the search page and we need to segue to room info page
        if searchedForRoom == true {
            performSegueWithIdentifier("RoomInfo", sender: self)
        }
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 70.0/255.0, green: 136.0/255.0, blue: 239.0/255.0, alpha: 1)
        //1
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        //2
        let fetchRequest = NSFetchRequest(entityName: "Whirlpool_favorites_table")
        //3
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            _favorites = results as! [NSManagedObject]
            self.calender.reloadData()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        //self.buildings = BuildingsData(delegate: self, buildingAbb: "GHQ")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            OpenHamburger.target = self.revealViewController()
            OpenHamburger.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        if FAVORITE_ROOM_SELECTED != nil {
            performSegueWithIdentifier("relevantSeg", sender: self)
        }
        let date = NSDate()
        let dayFormatter = NSDateFormatter()
        dayFormatter.dateFormat = "EEEE"
        let day = dayFormatter.stringFromDate(date)
        self.title = day + "'s Events"
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : AnyObject]
        self.calender.dataSource = self
        self.calender.delegate = self
        self.calender.backgroundColor = self.view.backgroundColor
        self.calender.separatorStyle = .SingleLine
        self.buildingScroller.delegate = self
        self.buildingScroller.dataSource = self
        self.navigationItem.setHidesBackButton(true, animated:true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.calender {
            if _userCalenderInfo != nil {
                return  (_userCalenderInfo?.getCalenderEventsCount())!
            }
            else {
                return 0
            }
        }
        return 0
    }
    
    func parseLocationString(location: String)->String {
        if !location.containsString("-") {
            return String()
        }
        if location == String() {
            return ""
        }
        let locationSplit = location.componentsSeparatedByString("-")
        return locationSplit[2].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
    
    func checkIfRoomLocation(locationString: String)->String {
        let roomToFind = locationString.componentsSeparatedByString("-")
        if roomToFind.count > 3 {
            let roomName = roomToFind[3].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            return roomName
        }
        else {
            return String()
        }
    }
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var calenderInfoTable = _userCalenderInfo?.getCalenderInfo()
        let cell = tableView.dequeueReusableCellWithIdentifier("CalenderCellID") as! CalenderCell
        cell.dateLabelCalender!.font = UIFont(name: "HelveticaNeue-Thin", size: 12.0)
        cell.titleLabel!.font = UIFont(name: "HelveticaNeue-Medium", size: 20.0)
        cell.titleLabel!.textColor = UIColor.blackColor()
        cell.dateLabelCalender!.textColor = UIColor.blackColor()
        cell.titleLabel!.text =  calenderInfoTable![indexPath.row].title
        if calenderInfoTable![indexPath.row].location?.componentsSeparatedByString("-").count >= 3 {
            let buidlingName = parseLocationString(calenderInfoTable![indexPath.row].location!)
            let buildingPicString = buildingToImageLarge[buidlingName]
            cell.buildingImage.image = UIImage(named: buildingPicString!)
        }
        else {
            let buildingName = buildingToImageLarge[String()]
            cell.buildingImage.image = UIImage(named: buildingName!)
        }
            cell.dateLabelCalender!.text = calenderInfoTable![indexPath.row].startDate! + "-" + calenderInfoTable![indexPath.row].endDate!
            cell.timeTill.text = calenderInfoTable![indexPath.row].getTimeUntilEventStart()
            return cell
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return screenSize.height * 0.18
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = colorForIndex(indexPath.row)
    }
    
    func colorForIndex(rowIndex: Int)->UIColor {
        return UIColor.whiteColor()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        // 1
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "\t" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            _userCalenderInfo!.getCalenderInfo()[indexPath.row].deleteNewEvent()
            _userCalenderInfo!.CalenderInfo.removeAtIndex(indexPath.row)
            self.calender.reloadData()
        })
        
        deleteAction.backgroundColor = UIColor(patternImage: UIImage(named: "Delete + Shape.png")!)
        let editAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "\t" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            self.clickedEdit = true
            self.editingEventToPass = _userCalenderInfo?.getCalenderInfo()[indexPath.row]
            self.performSegueWithIdentifier("eventHandleSeg", sender: self)
        })
        
        editAction.backgroundColor = UIColor(patternImage: UIImage(named: "Edit + Shape.png")!)
        let locationToParseForRoom =  _userCalenderInfo!.getCalenderInfo()[indexPath.row].location
        if checkIfRoomLocation(locationToParseForRoom!) != String() {
            let navigationAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "\t") { (action: UITableViewRowAction!, indexPath: NSIndexPath!) -> Void in
                let locationToParseForRoom =  _userCalenderInfo!.getCalenderInfo()[indexPath.row].location
                let potentialRoom = self.checkIfRoomLocation(locationToParseForRoom!)
                    self._roomToPass.SetRoomName(potentialRoom)
                    self.performSegueWithIdentifier("relevantSeg", sender: self)
            }
            navigationAction.backgroundColor = UIColor(patternImage: UIImage(named: "Navigate + Shape.png")!)
            return [deleteAction,editAction, navigationAction]
        }
        else{
            return [deleteAction,editAction]
        }
    }
    
    
    // Here we are implimenting the UICollectionView function needed for the virtical building scroller
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if buildings._buildingAbbr.count != 0 {
            return buildings._buildingAbbr.count
        }
        else{
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) ->UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("buildingScollerCell", forIndexPath: indexPath) as! BuildingCollectionViewCell
        let picName = buildings._buildingAbbr[indexPath.row] + ".png"
        cell.buildingButton.setImage(UIImage(named: picName), forState: UIControlState.Normal)
        cell.buildingAbb = buildings._buildingAbbr[indexPath.row]
        cell.buildingButtonDelegate = self
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 75, height: 75)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if segue.identifier == "relevantSeg" {
            let buildingVC = segue.destinationViewController as! BuildingsMapsViewController
            let room = FAVORITE_ROOM_SELECTED
            if room!.GetRoomName() != String(){
                buildingVC._room = room!
            }
            FAVORITE_ROOM_SELECTED = nil
        }
        if segue.identifier == "searchSegToRoom" {
            let buildingVC = segue.destinationViewController as! BuildingsMapsViewController
            let room = specificSearchedRoom!
            specificSearchedRoom = nil
            buildingVC._room = room
            buildingVC.CurrentBuilding = room.GetBuildingOfRoom()
        }
        
        if segue.identifier == "popUpSearchSeg" {
            let searchVC = segue.destinationViewController as! SearchViewController
            searchVC.roomDelagate = self
        }
        if segue.identifier == "popoverFavSeg" {
            let favVC = segue.destinationViewController as! FavoriteViewController
            favVC.favoriteRoomDelagate = self
        }
        if segue.identifier == "eventHandleSeg" {
            if clickedEdit == true {
                let editEventVC = segue.destinationViewController as! CalendarEventViewController
                editEventVC.editingEvent = editingEventToPass
                editEventVC.editingEventBool = true
                editingEventToPass = nil
                clickedEdit = false
            }
        }
        
        if segue.identifier == "buildingMaps" {
            let BuildingVC = segue.destinationViewController as! BuildingsMapsViewController
            /************* PASS ANY DATA YOU WOULD LIKE TO THE MAPS *****/
//            let buildingABR = "GHQ"
            print(_buildingAbb)
            BuildingVC.CurrentBuilding = _buildingAbb!
            BuildingVC._room  = RoomData()
            BuildingVC.CurrentFloor = 1
            
    }
    }
}
