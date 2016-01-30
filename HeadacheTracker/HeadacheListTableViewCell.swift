//
//  HeadacheListTableViewCell.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 1/29/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit

class HeadacheListTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var severityLabel: UILabel!
    @IBOutlet weak var medicationsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
