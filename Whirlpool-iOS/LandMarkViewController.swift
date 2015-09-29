//
//  LandMarkViewController.swift
//  Whirlpool-iOS
//
//  Created by Jallal Elhazzat on 9/27/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation


public class LandMarkViewController: UIViewController, UIPickerViewDelegate{
    
    var selectedValue = " ";
    
    @IBAction func GO(sender: AnyObject) {
        NSLog("THE SELECTED VALUE IS "+selectedValue)
        
        ///self.performSegueWithIdentifier("NavigationSague", sender: nil)

        
    }
    
    var landMarks = [" Building A "," Building B "," Building C ", " Building D"]
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        }
    
    
    func numberOfComponentsInPickerView(pickerView : UIPickerView!) ->Int{
    
        return 1;
    
    }
    
    
    func pickerView(pickerView: UIPickerView!, numberOfRowsInComponent component: Int) -> Int{
        
        return self.landMarks.count;
        
        
    }
    
    public func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return self.landMarks[row]
    }
    
    
    // Catpure the picker view selection
    public func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedValue = self.landMarks[row];
        
        //NSLog("You have selected "+self.landMarks[row])
        
        //self.performSegueWithIdentifier("NavigationSague", sender: nil)
        
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
    }
    
    
    
    ///when you pick something go to this sague
    //self.performSegueWithIdentifier("NavigationSague", sender: nil)

}