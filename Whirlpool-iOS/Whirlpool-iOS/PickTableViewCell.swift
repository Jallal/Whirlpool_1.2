//
//  PickTableViewCell.swift
//  Whirlpool-iOS
//
//  Created by Gregory Richard on 11/13/15.
//  Copyright © 2015 MSU. All rights reserved.
//

import Foundation
import UIKit

class PickerTableViewCell: UITableViewCell {
    @IBOutlet weak var TimeImage: UIImageView!
    @IBOutlet weak var datePickerCellLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    class var exandedHeight:CGFloat {get{return 220.0}}
    class var defaultHeight: CGFloat {get{return 70.0}}
    var setPickerUp = false
    var isReg = false
    
    
    func checkHeight(){
        datePicker.hidden = (frame.size.height < PickerTableViewCell.exandedHeight)
    }
    
    func watchFrameChanges(){
        addObserver(self, forKeyPath: "frame", options: .New, context: nil)
        checkHeight()
        isReg = true
    }
    
    func ignoreFrameChanges(){
        removeObserver(self, forKeyPath: "frame")
        isReg = false
    }
    
    func checkAndDeregister(){
        if isReg {
            ignoreFrameChanges()
        }
    }
    
    func checkWhichDatePickerAndSetImage(){
        if datePickerCellLabel.text != "Start" {
            TimeImage.hidden = true
        }else{
            TimeImage.hidden = false
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "frame" {
            checkHeight()
        }
    }
}