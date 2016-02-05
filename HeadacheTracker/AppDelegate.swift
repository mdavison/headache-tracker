//
//  AppDelegate.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 11/10/15.
//  Copyright © 2015 Morgan Davison. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var coreDataStack = CoreDataStack()


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let tabBarController = window!.rootViewController as! HeadacheTabBarController
        let allHeadachesNavigationController = tabBarController.viewControllers![0] as! UINavigationController
        let calendarViewNavigationController = tabBarController.viewControllers![1] as! UINavigationController
        let monthBarChartViewNavigationController = tabBarController.viewControllers![2] as! UINavigationController
        let severityPieChartViewNavigationController = tabBarController.viewControllers![3] as! UINavigationController
        
        let allHeadachesController = allHeadachesNavigationController.viewControllers[0] as! HeadacheTableViewController
        let calendarCollectionViewController = calendarViewNavigationController.viewControllers[0] as! CalendarCollectionViewController
        let monthBarChartViewController = monthBarChartViewNavigationController.viewControllers[0] as! MonthBarChartViewController
        let severityPieChartViewController = severityPieChartViewNavigationController.viewControllers[0] as! SeverityPieChartViewController

        //allHeadachesController.managedContext = coreDataStack.context
        //monthBarChartViewController.managedContext = coreDataStack.context
        //severityPieChartViewController.managedContext = coreDataStack.context
        
        allHeadachesController.coreDataStack = coreDataStack
        calendarCollectionViewController.coreDataStack = coreDataStack
        monthBarChartViewController.coreDataStack = coreDataStack
        severityPieChartViewController.coreDataStack = coreDataStack
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        coreDataStack.saveContext()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        coreDataStack.saveContext()
    }


}

