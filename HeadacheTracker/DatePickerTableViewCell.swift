//
//  DatePickerTableViewCell.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 1/27/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit

class DatePickerTableViewCell: UITableViewCell {

    @IBOutlet weak var datePicker: UIDatePicker!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // Prevent future dates
        datePicker.maximumDate = NSDate()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
