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
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
    //Creating class variables
    @IBOutlet weak var tapLocationWidget: UIImageView!
    let tapRecog = UITapGestureRecognizer()
    

    @IBOutlet weak var eventType: UIImageView!
    
    
    
    
    //Calender object being created
    
/*    var calenderEvent: CalenderEvent? {
        didSet {
            if let s = calenderEvent {
                //dateLabel.text = calenderEvent?.getDate()
                titleLabel.text = calenderEvent?.getTitle()
                eventType.backgroundColor = calenderEvent?.getType()
                
                
            }
            
        }
    }
    
    */
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?){
        dateLabel = UILabel(frame: CGRectZero)
        titleLabel = UILabel(frame: CGRectZero)
        eventType = UIImageView(frame: CGRectZero)
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        populateCell()
        
        
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
/*    func configureTitle(text: String?, placeholder: String) {
        titleLabel.text = text
        titleLabel.accessibilityValue = text
    }
    
    func configureDate(text: String?){
        dateLabel.text = calenderEvent?.getDate()
    }
    */
    /*
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    */
    func populateCell(){
        dateLabel.text = "12/13/2015"
        titleLabel.text = "Testing 1"
        
        dateLabel.textAlignment = .Center
        titleLabel.textAlignment = .Left
        
        contentView.addSubview(dateLabel)
        contentView.addSubview(titleLabel)
    }
*/
