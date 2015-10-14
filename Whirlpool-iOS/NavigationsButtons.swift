//
//  NavigationsButtons.swift
//  Whirlpool-iOS
//
//  Created by Jallal Elhazzat on 9/27/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation

class NavigationsButtons: UIViewController{
    

    @IBOutlet weak var BottomView: UIView!
    
    @IBAction func LandMark(sender: AnyObject) {
        self.BottomView.removeFromSuperview();
        
    }
    
    
    @IBAction func Location(sender: AnyObject) {
        //self.BottomView.removeFromSuperview();
        
         self.performSegueWithIdentifier("NavigationSague", sender: nil)
        
        
        
    }
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        
    }
    
}
