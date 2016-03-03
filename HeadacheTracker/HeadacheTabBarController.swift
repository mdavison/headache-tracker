//
//  HeadacheTabBarController.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 11/11/15.
//  Copyright © 2015 Morgan Davison. All rights reserved.
//

import UIKit

class HeadacheTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.tintColor = Theme.Colors.tint
//        tabBar.barTintColor = Theme.Colors.barTint
        Theme.setup(withView: view, tabBar: tabBar)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
