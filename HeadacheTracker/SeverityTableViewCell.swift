//
//  SeverityTableViewCell.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 1/27/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit

class SeverityTableViewCell: UITableViewCell {

    
    @IBOutlet weak var severitySlider: UISlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
