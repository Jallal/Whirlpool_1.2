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
    
    
    @IBAction func cancelFavoriteViewButton(sender: AnyObject) {
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
            self.relevant.reloadData()
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            userSelectedFavorite(room)
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}