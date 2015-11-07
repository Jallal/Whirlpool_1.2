//
//  BuildingCollectionViewCell.swift
//  Whirlpool-iOS
//
//  Created by Gregory Richard on 11/6/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import UIKit

class BuildingCollectionViewCell: UICollectionViewCell {
    

    @IBOutlet weak var buildingButton: UIButton!
    @IBAction func buildingButtonTapped(sender: AnyObject) {
        print("building button tapped")
    }
}
