//
//  CalenderCell.swift
//  WhirlpoolIndoors
//
//  Created by Gregory Richard on 9/23/15.
//  Copyright © 2015 Team Whirlpool. All rights reserved.
//

import Foundation
import UIKit

class CalenderCell: UITableViewCell {
    
    @IBOutlet weak var dateLabelCalender: UILabel?
    @IBOutlet weak var dateLabelRelavant: UILabel?
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var titleLabelRelavant: UILabel?
    @IBOutlet weak var buildingImage: UIImageView!
    @IBOutlet weak var timeTill: UILabel!
    @IBOutlet weak var LocationLabel: UILabel!
    var building:String?

    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

     required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    }