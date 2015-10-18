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


class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UITabBarDelegate {
    
    
    @IBOutlet weak var calender: UITableView!

    @IBOutlet weak var relevant: UITableView!
    
    var items = ["one","two"]
    var tableData = ["nine","six"]
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    
    var _favorites = [NSManagedObject]()
    var _roomToPass = RoomData()
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "Favorites")
        
        //3
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            _favorites = results as! [NSManagedObject]
            self.calender.reloadData()
            self.relevant.reloadData()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.calender.dataSource = self
        
        self.calender.delegate = self
        self.calender.backgroundColor = self.view.backgroundColor
        self.relevant.backgroundColor = self.view.backgroundColor
        self.calender.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.relevant.delegate = self
        self.relevant.separatorStyle = .None
        
        self.navigationItem.setHidesBackButton(true, animated:true);
        _roomsData.updateRoomsInfo();
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        
        if tableView == relevant {
            return _favorites.count
        }
        
        return 0
        
    }
    
    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var calenderInfoTable = _userCalenderInfo?.getCalenderInfo()
        if(tableView == self.calender){
            let cell = tableView.dequeueReusableCellWithIdentifier("CalenderCellID") as! CalenderCell
            cell.dateLabelCalender!.font = UIFont(name: "HelveticaNeue-Thin", size: 16.0)
            cell.titleLabel!.font = UIFont(name: "HelveticaNeue-Thin", size: 24.0)
            cell.titleLabel!.textColor = UIColor.whiteColor()
            cell.dateLabelCalender!.textColor = UIColor(red: 242.0/255, green: 241.0/255, blue: 239.0/255, alpha: 1.0)
            cell.dateLabelCalender!.backgroundColor = self.view.backgroundColor
            
            cell.titleLabel!.text =  calenderInfoTable![indexPath.row].title
            cell.dateLabelCalender!.text = calenderInfoTable![indexPath.row].startDate! + "\n" + calenderInfoTable![indexPath.row].endDate!
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCellWithIdentifier("RelevantCellID") as! CalenderCell
            cell.dateLabelRelavant!.font = UIFont(name: "HelveticaNeue-Thin", size: 16.0)
            cell.titleLabelRelavant!.font = UIFont(name: "HelveticaNeue-Thin", size: 24.0)
            cell.dateLabelRelavant!.backgroundColor = self.view.backgroundColor
            cell.titleLabel!.textColor = UIColor.whiteColor()
            cell.dateLabelRelavant!.textColor = UIColor(red: 242.0/255, green: 241.0/255, blue: 239.0/255, alpha: 1.0)
            cell.titleLabelRelavant!.text =  _favorites[indexPath.row].valueForKey("roomName") as? String
            cell.dateLabelRelavant!.text = "12/13/2015"
            return cell
        }
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return screenSize.height * 0.1
    }
    
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        cell.backgroundColor = colorForIndex(indexPath.row)
    }
    
    func colorForIndex(rowIndex: Int)->UIColor
    {
        return UIColor(red: 82.0/255.0 , green: 179.0/255.0, blue: 217.0/255.0, alpha: 1)
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let room = RoomData()
        
        if (tableView == self.relevant)
        {
            room.SetRoomName((_favorites[indexPath.row].valueForKey("roomName") as? String)!)
            _roomToPass = room
            performSegueWithIdentifier("relevantSeg", sender: self)
        }
        
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "relevantSeg" {
            let roomVC = segue.destinationViewController as! RoomInfoViewController
            let room = _roomsData.getRoomWithName(_roomToPass.GetRoomName())
            if room.GetRoomName() != String(){
                roomVC._room = room
            }
        }
        
    }

    
}
