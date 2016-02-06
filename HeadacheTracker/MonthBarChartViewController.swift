//
//  MonthBarChartViewController.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 1/2/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit
import Charts
import CoreData

class MonthBarChartViewController: UIViewController {

    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var coreDataStack: CoreDataStack!
    var fetchedResultsController: NSFetchedResultsController!
    var yearsFetchedResultsController: NSFetchedResultsController!
    
    let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    var years = [Int]()
    var selectedYear = 0
    var segmentedControlSelectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(animated: Bool) {
        fetchYears()
        fetchHeadaches()
        setSegmentedControl()
        
        if let headaches = setHeadachesForYear(selectedYear) {
            setChart(months, values: headaches)
        }
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
    
    
    @IBAction func segementChanged(sender: UISegmentedControl) {
        segmentedControlSelectedIndex = sender.selectedSegmentIndex
        selectedYear = years[sender.selectedSegmentIndex]
        
        if let headaches = setHeadachesForYear(selectedYear) {
            setChart(months, values: headaches)
        }
        
    }
    
    @IBAction func saveChart(sender: UIBarButtonItem) {
        //barChartView.saveToCameraRoll()
        
        let image = barChartView.getChartImage(transparent: false)
        UIImageWriteToSavedPhotosAlbum(image, self, Selector("image:didFinishSavingWithError:contextInfo:"), nil)
        
    }
    
    
    private func fetchHeadaches() {
        let headacheFetch = NSFetchRequest(entityName: "Headache")
        headacheFetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: headacheFetch, managedObjectContext: coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error) " + "description: \(error.localizedDescription)")
        }
    }
    

    private func fetchYears() {
        let yearFetch = NSFetchRequest(entityName: "Year")
        let sortDescriptor = NSSortDescriptor(key: "number", ascending: true)
        yearFetch.sortDescriptors = [sortDescriptor]
        
        yearsFetchedResultsController = NSFetchedResultsController(fetchRequest: yearFetch, managedObjectContext: coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try yearsFetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error) " + "description: \(error.localizedDescription)")
        }
    }
    
    private func loadYears() {
        years = [] // reset so don't keep appending and getting duplicates
        
        // Yes, I end up looping through the years twice but it's just a lot easier
        // to deal with a simple array and there shouldn't ever be that many years
        for year in yearsFetchedResultsController.fetchedObjects as! [Year] {
            years.append(Int(year.number!))
        }
    }

    private func setSegmentedControl() {
        segmentedControl.removeAllSegments()
        loadYears()

        for year in years {
            var index = 0
            if let i = years.indexOf(year) {
                index = i
            }
            segmentedControl.insertSegmentWithTitle("\(year)", atIndex: index, animated: false)
        }
        
        if let index = segmentedControlSelectedIndex {
            segmentedControl.selectedSegmentIndex = index
            selectedYear = years[index]
        } else {
            if let latestYear = years.last {
                selectedYear = latestYear
                segmentedControl.selectedSegmentIndex = years.count - 1
            }
        }
    }
    
    private func setChart(dataPoints: [String], values: [Double]) {
        barChartView.noDataText = "There are no headaches"
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "Number of Headaches")
        let chartData = BarChartData(xVals: months, dataSet: chartDataSet)
        
        barChartView.data = chartData
        
        // Set number format to integer
        let numberFormatter = NSNumberFormatter()
        numberFormatter.generatesDecimalNumbers = false
        //numberFormatter.numberStyle = NSNumberFormatterStyle.NoStyle
        chartDataSet.valueFormatter = numberFormatter
        // Converting to Int for small numbers rounds weird
        //barChartView.rightAxis.valueFormatter = numberFormatter
        //barChartView.leftAxis.valueFormatter = numberFormatter
        
        barChartView.descriptionText = "Total headaches by month"
    }
    
    private func setHeadachesForYear(year: Int) -> [Double]? {
        var noData = true
        
        var headachesForMonths = [
            1: [Headache](),
            2: [Headache](),
            3: [Headache](),
            4: [Headache](),
            5: [Headache](),
            6: [Headache](),
            7: [Headache](),
            8: [Headache](),
            9: [Headache](),
            10: [Headache](),
            11: [Headache](),
            12: [Headache]()]
        
        let monthNumbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
        var numberOfHeadachesPerMonth = [Double]()
        
        let calendar = NSCalendar.currentCalendar()
        
        if let headachesForYear = fetchHeadachesForYear(year) {
            
            for headache in headachesForYear {
                let headacheMonth = calendar.components(NSCalendarUnit.Month, fromDate: headache.date!).month
                
                headachesForMonths[headacheMonth]?.append(headache)
            }

            for month in monthNumbers {
                if let ha = headachesForMonths[month] {
                    if ha.count > 0 { noData = false }
                    numberOfHeadachesPerMonth.append(Double(ha.count))
                }
            }

            if noData { return nil }
            
            return numberOfHeadachesPerMonth
        } else {
            return nil
        }
    }
    
    private func fetchHeadachesForYear(year: Int) -> [Headache]? {
        let yearFetch = NSFetchRequest(entityName: "Year")
        yearFetch.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
        yearFetch.relationshipKeyPathsForPrefetching = ["headaches"]
        yearFetch.predicate = NSPredicate(format: "number == %d", year)
        
        let headachesForYearFetchedResultsController = NSFetchedResultsController(fetchRequest: yearFetch, managedObjectContext: coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)

        
        do {
            try headachesForYearFetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error) " + "description: \(error.localizedDescription)")
        }
        
        if let yearFetched = headachesForYearFetchedResultsController.fetchedObjects?.first as? Year {
            
            var headaches = [Headache]()
            for headache in yearFetched.headaches! {
                headaches.append(headache as! Headache)
            }

            return headaches
        } else {
            return nil
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        if let error = error {
            print(error.domain)
            alert.title = "Error"
            alert.message = "Unable to save chart. Please check permissions for this app in Settings."
        } else {
            alert.title = "Saved"
            alert.message = "Chart was saved to Photos"
        }
        
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion:nil)
    }

}
