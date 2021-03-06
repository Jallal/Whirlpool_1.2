//
//  FavoritesViewController.swift
//  Whirlpool-iOS
//
//  Created by Team Whirlpool on 10/26/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation
import UIKit
import CoreData

protocol selectedFavoriteDelagate {
    func userSelectedFavorite(favRoom: RoomData)
}

class FavoriteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var _favorites = [NSManagedObject]()
    var favoriteRoomDelagate: selectedFavoriteDelagate? = nil
    @IBOutlet weak var favNavBar: UINavigationBar!
    @IBAction func cancelHit(sender: AnyObject) {
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBOutlet weak var relevant: UITableView!
    
    func userSelectedFavorite(favRoom: RoomData) {
        if favoriteRoomDelagate != nil {
            favoriteRoomDelagate?.userSelectedFavorite(favRoom)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        self.view.backgroundColor = UIColor(red: 251.0/255.0, green: 137.0/255.0, blue: 127.0/255.0, alpha: 1)
        self.favNavBar.barTintColor = UIColor(red: 251.0/255.0, green: 137.0/255.0, blue: 127.0/255.0, alpha: 1)
        
        //1
        let appDelegate =
        UIApplication.sharedApplication().delegate as! AppDelegate
        
        
        let managedContext = appDelegate.managedObjectContext
        
        //2
        let fetchRequest = NSFetchRequest(entityName: "Whirlpool_favorites_table")
//        let resultPredicate = NSPredicate(format: "userEmail == %@", googleAuth.userEmail)
//        fetchRequest.predicate = resultPredicate
        print(service.authorizer.userEmail)
        //3
        do {
            let results =
            try managedContext.executeFetchRequest(fetchRequest)
            let tempResults = results as! [NSManagedObject]
            if tempResults.count>0{
                for x in 0...tempResults.count-1{
                    let email = tempResults[x].valueForKey("userEmail") as? String
                    let appLoginEmail = service.authorizer.userEmail
                    let boolResult = email == appLoginEmail
                    if email != nil {
                        if email == service.authorizer.userEmail{
                            _favorites.append(tempResults[x])
                        }
                    }
                }
            }
            self.relevant.reloadData()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.favNavBar.titleTextAttributes = titleDict as? [String : AnyObject]
        self.relevant.backgroundColor = self.view.backgroundColor
        self.relevant.separatorStyle = .SingleLine
        
        self.relevant.dataSource = self
        self.relevant.delegate = self
        self.relevant.separatorStyle = .None
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        if tableView == self.relevant {
            if _favorites.count != 0 {
                return  _favorites.count
            }
            else {
                return 0
            }
        }
        return 0
        
    }

    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        cell?.textLabel!.font = UIFont(name: "HelveticaNeue-Thin", size: 24.0)
        cell?.textLabel!.textColor = UIColor.blackColor()
        cell?.textLabel!.text =  _favorites[indexPath.row].valueForKey("roomName") as? String
        return cell!
        
    }
    
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return screenSize.height * 0.14
    }
    
    
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath)
    {
        cell.backgroundColor = colorForIndex(indexPath.row)
    }
    
    func colorForIndex(rowIndex: Int)->UIColor
    {
        return UIColor.whiteColor()
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let room = RoomData()
        if (tableView == self.relevant)
        {
            room.SetRoomName((_favorites[indexPath.row].valueForKey("roomName") as? String)!)
            room.SetRoomBuildingName((_favorites[indexPath.row].valueForKey("buildingAbb") as? String)!)
            userSelectedFavorite(room)
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        // 1
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "\t" , handler: { (action:UITableViewRowAction!, indexPath:NSIndexPath!) -> Void in
            do{
                let appDel = UIApplication.sharedApplication().delegate as! AppDelegate
                let context = appDel.managedObjectContext
                context.deleteObject(self._favorites[indexPath.row] as NSManagedObject)
                self._favorites.removeAtIndex(indexPath.row)
                try context.save()
            } catch {
                
            }
            self.relevant.reloadData()
        })
        
        deleteAction.backgroundColor = UIColor(patternImage: UIImage(named: "Delete + Shape.png")!)
        return [deleteAction]
    }

    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}