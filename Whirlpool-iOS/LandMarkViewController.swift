//
//  LandMarkViewController.swift
//  Whirlpool-iOS
//
//  Created by Jallal Elhazzat on 9/27/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation


public class LandMarkViewController: UIViewController, UIPickerViewDelegate{
    
    
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

}