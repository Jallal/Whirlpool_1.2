//
//  AddEventTableViewCell.swift
//  Whirlpool-iOS
//
//  Created by Gregory Richard on 11/13/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation
import UIKit



class AddEventTableViewCell: UITableViewCell, UITextViewDelegate {

    //@IBOutlet weak var cellInputText: UITextField!
    @IBOutlet weak var cellInputText: UITextView!
    @IBOutlet weak var cellImage: UIImageView!

    
    func removeTextFieldBorder(){
        cellInputText.layer.borderColor = UIColor.clearColor().CGColor
    }
    func setCellInputTextHeight(){
        cellInputText.bounds.size.height = self.bounds.size.height
    }
    
}