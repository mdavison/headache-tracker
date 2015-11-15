//
//  HeadacheTabBarController.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 11/11/15.
//  Copyright © 2015 Morgan Davison. All rights reserved.
//

import UIKit

class HeadacheTabBarController: UITabBarController {

    var dataModel: DataModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    override func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
//        print("did select item: \(item.tag)")
//        print(dataModel.headaches.count)
//        if item.tag == 2 { // WeekView
//            // get the controller
//            // update the numberOfHeadachesLabel
//            //let weekViewController = tabBar.superclass as! WeekViewController
//            //weekViewController.numberOfHeadachesLabel.text = String(dataModel.headaches.count)
//            
//        }
//        // get headacheDetailTableViewController
//        // get weekViewController
//        // set headacheDetailTableViewController.delegate = weekViewController
//    }
    
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }

}
