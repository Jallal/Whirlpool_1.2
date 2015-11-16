//
//  BuildingCollectionViewCell.swift
//  Whirlpool-iOS
//
//  Created by Gregory Richard on 11/6/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import UIKit

protocol buildingButtonTappedDelegate{
    func buildingSelected(buildingAbb:String)
}

class BuildingCollectionViewCell: UICollectionViewCell {
    
    var buildingAbb:String?
    var buildingButtonDelegate:buildingButtonTappedDelegate?
    
    @IBOutlet weak var buildingButton: UIButton!
    @IBAction func buildingButtonTapped(sender: AnyObject) {
        
        if buildingAbb != nil && buildingButtonDelegate != nil{
            buildingButtonDelegate!.buildingSelected(buildingAbb!)
        }
        
    }
    
    func buildingSelected(buildingAbb: String){
        print(buildingAbb)
    }
    
}
