//
//  Theme.swift
//  Headaches
//
//  Created by Morgan Davison on 3/3/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit

class Theme {
    
    struct Colors {
        // Color of the buttons
        static var tint = UIColor(red: 165.0/255.0, green: 48.0/255.0, blue: 174.0/255.0, alpha: 1)
        
        // Nav bar and toolbar backgrounds
        static var barTint = UIColor(red: 234.0/255.0, green: 219.0/255.0, blue: 239.0/255.0, alpha: 1)
    }
    
    struct TextAttributes {
        static var font: UIFont {
            get {
                if let avenir = UIFont(name: "Avenir", size: 20) {
                    return avenir
                } else {
                    return UIFont.systemFontOfSize(20)
                }
            }
        }
        
        //static var color = UIColor.darkGrayColor()
        static var color = UIColor.blackColor()
    }
    
    static func setup(withView view: UIView?, navigationBar: UINavigationBar?) {
        if let view = view {
            view.tintColor = Theme.Colors.tint
        }
        
        if let navigationBar = navigationBar {
            navigationBar.barTintColor = Theme.Colors.barTint
            navigationBar.tintColor = Theme.Colors.tint
//            navigationBar.titleTextAttributes =
//                [NSFontAttributeName: Theme.TextAttributes.font,
//                NSForegroundColorAttributeName: Theme.TextAttributes.color]
        }
    }
    
    static func setup(withView view: UIView?, tabBar: UITabBar?) {
        if let view = view {
            view.tintColor = Theme.Colors.tint
        }
        
        if let tabBar = tabBar {
            tabBar.barTintColor = Theme.Colors.barTint
        }
    }
}
