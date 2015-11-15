//
//  HamburgerTableViewController.swift
//  Whirlpool-iOS
//
//  Created by Gregory Richard on 11/14/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation
import UIKit

protocol selectedHamburderOvaron{
    func helpHit()
    func favoritesHit()
}

class HamburgerTableViewController: UITableViewController, selectedFavoriteDelagate {
    @IBOutlet var hamburgerMenu: UITableView!
    var hamburgerSections = [String]()
    var hamburgerSectionsAndBool = [Int:Bool]()
    var _roomToPass:RoomData?
    @IBOutlet weak var emailLabel: UILabel!
    private let kKeychainItemName = "Google Calendar API"
    private let kClientID = "656758157986-ipeuj79t544atfl6fuuc6ij9q7eqh8mh.apps.googleusercontent.com"
    private let kClientSecret = "9--EmDPAMnvbJFhGbWKQyw1p"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hamburgerMenu.dataSource = self
        hamburgerMenu.delegate = self
        if googleAuth.userEmail != nil {
            emailLabel.text = emailLabel.text! + googleAuth.userEmail
        }
    }

    func userSelectedFavorite(favRoom: RoomData) {
        print(favRoom.GetRoomName())
        _roomToPass = favRoom
        var revealController = self.revealViewController()
        revealController.setFrontViewPosition(FrontViewPosition.Left, animated: true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return self.view.bounds.size.height * 0.40
        }
        else{
            return self.view.bounds.size.height * 0.15
        }
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.row{
        case 1:
            hamburgerMenu.deselectRowAtIndexPath(indexPath, animated: true)
            logoutHit()
            break
        case 2:
            hamburgerMenu.deselectRowAtIndexPath(indexPath, animated: true)
            helpHit()
            break
        case 3:
            hamburgerMenu.deselectRowAtIndexPath(indexPath, animated: true)
            favoritesHit()
            break
        default:
            hamburgerMenu.deselectRowAtIndexPath(indexPath, animated: true)
            break
        }
    }
    
    func helpHit(){
        print("help hit")
    }
    
    func logoutHit(){
        GTMOAuth2ViewControllerTouch.revokeTokenForGoogleAuthentication(googleAuth)
        GTMOAuth2ViewControllerTouch.removeAuthFromKeychainForName(kKeychainItemName)
        service = GTLServiceCalendar()
    }
    
    
    func favoritesHit(){
        print("favorites hit")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "popoverFavSeg2" {
            let favVC = segue.destinationViewController as! FavoriteViewController
            favVC.favoriteRoomDelagate = self
        }
    }
}