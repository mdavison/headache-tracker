//
//  CalendarViewController.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 2/2/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit
import CoreData

class CalendarCollectionViewController: UICollectionViewController {

    var coreDataStack: CoreDataStack!
    var headaches = [Headache]()
    var monthsAndYears = [MonthYear]()
    
    struct Storyboard {
        static let CalendarCellReuseIdentifier = "CalendarCell"
    }
    
    struct MonthYear {
        var month: Int
        var year: Int
        var headaches: [Headache]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        setHeadaches()
        if !headaches.isEmpty {
            setMonthsAndYears()
        }
        collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return monthsAndYears.count
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfDaysInMonth(forMonthAndYear: monthsAndYears[section])
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Storyboard.CalendarCellReuseIdentifier, forIndexPath: indexPath) as! CalendarCollectionViewCell
        
        configureCell(cell, withIndexPath: indexPath)
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Header", forIndexPath: indexPath) as! CalendarCollectionReusableHeaderView
            
            headerView.backgroundColor = UIColor(red: 230.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, alpha: 1)
            
            let dateFormatter = NSDateFormatter()
            let monthText = dateFormatter.shortMonthSymbols[monthsAndYears[indexPath.section].month - 1]
            let yearText = monthsAndYears[indexPath.section].year
        
            headerView.titleLabel.text = "\(monthText) \(yearText)".uppercaseString
            return headerView
            
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "Footer", forIndexPath: indexPath) 
            
            footerView.backgroundColor = UIColor.greenColor();
            return footerView
            
        default:
            
            assert(false, "Unexpected element kind")
        }
    }
    
    
    
    
    // MARK: UICollectionViewDelegate
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return true
    }
    */
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
    return false
    }
    
    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */
    
    
    // MARK: - Helper Methods
    
//    private func scrollToBottom() {
//        let lastSectionIndex = (collectionView?.numberOfSections())! - 1
//        let lastItemIndex = (collectionView?.numberOfItemsInSection(lastSectionIndex))! - 1
//        let indexPath = NSIndexPath(forItem: lastItemIndex, inSection: lastSectionIndex)
//        
//        collectionView!.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Bottom, animated: false)
//    }
    
    private func getNSDateFromComponents(year: Int, month: Int, day: Int?) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        let components = NSDateComponents()
        components.month = month
        components.year = year
        if let day = day {
            components.day = day
        }
        
        return calendar.dateFromComponents(components)!
    }
    
    private func configureCell(cell: CalendarCollectionViewCell, withIndexPath indexPath: NSIndexPath) {
        cell.backgroundColor = UIColor.whiteColor()
        
        // Create top border
        let topBorder = UIView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: 1))
        topBorder.backgroundColor = UIColor.lightGrayColor()
        cell.contentView.addSubview(topBorder)

        
        // Determine if this cell should be empty
        let padding = getPadding(forMonthAndYear: monthsAndYears[indexPath.section])
        var day = 0
        
        if indexPath.row + 1 > padding {
            day = (indexPath.row + 1) - padding
        }
        
        // Clear any existing red circles, otherwise they will stay and show up in wrong places
        removeRedCircle(forCell: cell)
        
        if day > 0 { // Not a blank cell
            cell.dayNumberLabel.text = "\(day)"

            // Draw red circle if there was a headache on this day
            let dateOfThisCell = getNSDateFromComponents(monthsAndYears[indexPath.section].year, month: monthsAndYears[indexPath.section].month, day: day)
            let headachesForThisMonth = monthsAndYears[indexPath.section].headaches
            //print("date of this cell: \(dateOfThisCell)")
            for ha in headachesForThisMonth {
                //print("ha date: \(ha.date)")
                if let headacheDate = ha.date { // Make sure it doesn't crash if we delete a headache
                    if headacheDate == dateOfThisCell {
                        drawCircle(forCell: cell, andHeadache: ha)
                    }
                }
            }
        } else { // Cell is a blank padding cell
            cell.dayNumberLabel.text = ""
        }
    }
    
    private func numberOfDaysInMonth(forMonthAndYear monthYear: MonthYear) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let date = getNSDateFromComponents(monthYear.year, month: monthYear.month, day: nil)
        let numberOfDaysInMonth = calendar.rangeOfUnit(.Day, inUnit: .Month, forDate: date)
        let padding = getPadding(forMonthAndYear: monthYear)
        
        return numberOfDaysInMonth.toRange()!.last! + padding
    }
    
    private func getPadding(forMonthAndYear monthAndYear: MonthYear) -> Int {
        let calendar = NSCalendar.currentCalendar()
        
        // Get day of the week for the first day of the month
        let date = getNSDateFromComponents(monthAndYear.year, month: monthAndYear.month, day: 1)
        let components = calendar.components([.Weekday], fromDate: date)

        return components.weekday - 1
    }
    
    private func setHeadaches() {
        let fetchRequest = NSFetchRequest(entityName: "Headache")
        let nameSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [nameSortDescriptor]
        
        do {
            let results = try coreDataStack.context.executeFetchRequest(fetchRequest) as! [Headache]
            if results.count > 0 {
                headaches = results
            }
        } catch let error as NSError {
            print("Error: \(error) " + "description \(error.localizedDescription)")
        }
    }
    
    private func getNumberOfMonths(forHeadaches headaches: [Headache]) -> Int {
        let calendar = NSCalendar.currentCalendar()
        
        // Get the number of months between the first and last headache
        if !headaches.isEmpty {
            let months = calendar.components(NSCalendarUnit.Month, fromDate: headaches.last!.date!, toDate: headaches.first!.date!, options: [])
            
            return months.month + 1 // Need to add one to make it inclusive on both ends
        }
        return 0
    }
    
    private func setMonthsAndYears() {
        // Empty the array, otherwise it keeps appending every time view loads
        monthsAndYears.removeAll()
        
        let calendar = NSCalendar.currentCalendar()
        let monthSpan = getNumberOfMonths(forHeadaches: headaches)
        let components = calendar.components([.Month, .Year], fromDate: headaches.first!.date!)
        
        // Create var to hold month component of each item in the loop,
        // Initial value set to first headache
        var nsDateCounter = calendar.dateFromComponents(components)

        for _ in 1...monthSpan {
            let components = calendar.components([.Month, .Year], fromDate: nsDateCounter!)
            var headachesArray = [Headache]()
            
            for headache in headaches {
                // Get month and year components from the headache
                let headacheComponents = calendar.components([.Month, .Year], fromDate: headache.date!)
                // When they match the outer loop components, add to headache array
                if (headacheComponents.month == components.month) && (headacheComponents.year == components.year) {
                    headachesArray.append(headache)
                }
            }
            
            let monthYear = MonthYear(month: components.month, year: components.year, headaches: headachesArray)
            monthsAndYears.append(monthYear)
            
            // decrement nsDateCounter by 1 month
            nsDateCounter = calendar.dateByAddingUnit(.Month, value: -1, toDate: nsDateCounter!, options: [])
        }
    }
    
    private func drawCircle(forCell cell: CalendarCollectionViewCell, andHeadache headache: Headache) {
        // Draw a circle
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: cell.frame.width/2,y: cell.frame.width/2), radius: CGFloat(cell.frame.width/3.3), startAngle: CGFloat(0), endAngle:CGFloat(M_PI * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.CGPath
        
        //change the fill color
        //shapeLayer.fillColor = UIColor.redColor().CGColor
        let severityColor = headache.severityColor()
        if let red = severityColor["red"], green = severityColor["green"], blue = severityColor["blue"] {
            shapeLayer.fillColor = UIColor.init(red: red, green: green, blue: blue, alpha: 1).CGColor
        }
        
        cell.layer.addSublayer(shapeLayer)
        
        // Add a label on top, since the drawn circle covers the existing label
        let label = UILabel(frame: CGRect(x: 19, y: 18, width: 20, height: 20))
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.preferredFontForTextStyle("caption 1")
        
        label.translatesAutoresizingMaskIntoConstraints = false // So we can set constraints
        label.text = cell.dayNumberLabel.text
        cell.addSubview(label)
        
        // Add constraints
        let centerXConstraint = NSLayoutConstraint(item: label, attribute: .CenterX, relatedBy: .Equal, toItem: cell, attribute: .CenterX, multiplier: 1.0, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: label, attribute: .CenterY, relatedBy: .Equal, toItem: cell, attribute: .CenterY, multiplier: 1.0, constant: 0)
        cell.addConstraints([centerXConstraint, centerYConstraint])
        label.frame.size = label.intrinsicContentSize()
    }
    
    private func removeRedCircle(forCell cell: CalendarCollectionViewCell) {
        // Remove label (subview)
        if let label = cell.subviews[safe: 1] {
            label.removeFromSuperview()
        }
        
        // Remove circle (sublayer)
        if let circle = cell.layer.sublayers?[safe: 1] {
            if circle.isKindOfClass(CAShapeLayer) {
                circle.removeFromSuperlayer()
            }
        }
    }

}


extension CalendarCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let width = view.frame.size.width / 7
        return CGSize(width: width, height: width)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {

        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        
        return 0
    }
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}

// Prevent array out of bounds error when checking for sublayers
extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
