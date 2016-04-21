//
//  SeverityPieChartViewController.swift
//  HeadacheTracker
//
//  Created by Morgan Davison on 1/5/16.
//  Copyright © 2016 Morgan Davison. All rights reserved.
//

import UIKit
import Charts
import CoreData

class SeverityPieChartViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pieChartView: PieChartView!
    //@IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var coreDataStack: CoreDataStack!
    let severityLevels = ["1", "2", "3", "4", "5"]
    
    var headaches = [Headache]()

    var selectedSegmentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("Severity of Headaches", comment: "")
        Theme.setup(withView: view, navigationBar: navigationController?.navigationBar)
    }
    
    override func viewWillAppear(animated: Bool) {
        setHeadaches()
        shareButton.enabled = false
        pieChartView.clear()

        if let selectedSegment = getSelectedSegment(selectedSegmentIndex) {
            if let headaches = getHeadachesBySeverity(selectedSegment) {
                setChart(severityLevels, values: headaches)
                shareButton.enabled = true
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Actions
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
        if let selectedSegment = getSelectedSegment(selectedSegmentIndex) {
            if let headaches = getHeadachesBySeverity(selectedSegment) {
                setChart(severityLevels, values: headaches)
            }
        }
    }
    
    @IBAction func share(sender: UIBarButtonItem) {
        let image = pieChartView.getChartImage(transparent: false)
        
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = shareButton
        
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - Helper methods
    
    private func setHeadaches() {
        let headacheFetch = NSFetchRequest(entityName: "Headache")
        headacheFetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let results = try coreDataStack.context.executeFetchRequest(headacheFetch) as! [Headache]
            
            if results.count > 0 {
                headaches = results
            }
        } catch let error as NSError {
            print("Error: \(error) " + "description: \(error.localizedDescription)")
        }
    }
    
    private func setChart(dataPoints: [String], values: [Double]) {
        pieChartView.noDataText = NSLocalizedString("There are no headaches", comment: "")
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Severity")
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        
        // Colors need to be set BEFORE data: https://github.com/danielgindi/ios-charts/issues/518
        var colors: [UIColor] = []
        for severity in severityLevels {
            if let int = Int(severity) {
                let color = Headache.colorForSeverity(int)
                colors.append(color)
            }
        }
        pieChartDataSet.colors = colors
        //pieChartDataSet.drawValuesEnabled = false (remove data labels)
        pieChartView.drawSliceTextEnabled = false // remove labels
        
        // Set number format to integer
        let numberFormatter = NSNumberFormatter()
        numberFormatter.generatesDecimalNumbers = false
        pieChartDataSet.valueFormatter = numberFormatter
        
        pieChartView.data = pieChartData
        
        if let segment = getSelectedSegment(selectedSegmentIndex) {
            pieChartView.descriptionText = NSLocalizedString("Headaches by severity for past \(segment)", comment: "")
        } else {
            pieChartView.descriptionText = NSLocalizedString("Headaches by severity", comment: "")
        }
    }
    
    private func getHeadachesBySeverity(timePeriod: String) -> [Double]? {
        var severityArray = [[Headache](), [Headache](), [Headache](), [Headache](), [Headache]()]
        var headacheCountBySeverity = [Double]()
        let headachesForTimePeriod = fetchHeadachesFor(timePeriod)
        
        if let hftp = headachesForTimePeriod {
            if !hftp.isEmpty {
                for headache in hftp {
                    let severityInt = Int(headache.severity!)
                    severityArray[severityInt-1] += [headache]
                }

                for ha in severityArray {
                    headacheCountBySeverity.append(Double(ha.count))
                }
                
                return headacheCountBySeverity
            }
        }
        
        return nil
    }
    
    private func getSelectedSegment(index: Int) -> String? {
        switch index {
        case 0: return "week"
        case 1: return "month"
        case 2: return "year"
        default: return nil
        }
    }
    
    private func fetchHeadachesFor(timePeriod: String) -> [Headache]? {
        let calendar = NSCalendar.currentCalendar()
        var startDate: NSDate
        
        switch timePeriod {
        case "week":
            startDate = calendar.dateByAddingUnit(.Day, value: -7, toDate: NSDate(), options: [])!
        case "month":
            startDate = calendar.dateByAddingUnit(.Month, value: -1, toDate: NSDate(), options: [])!
        case "year":
            startDate = calendar.dateByAddingUnit(.Year, value: -1, toDate: NSDate(), options: [])!
        default:
            return nil
        }

        let headacheFetch = NSFetchRequest(entityName: "Headache")
        headacheFetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        headacheFetch.predicate = NSPredicate(format: "(date >= %@) AND (date <= %@)", startDate, NSDate())
        
        let headacheFetchedResultsController = NSFetchedResultsController(fetchRequest: headacheFetch, managedObjectContext: coreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        
        
        do {
            try headacheFetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Error: \(error) " + "description: \(error.localizedDescription)")
        }
        
        return headacheFetchedResultsController.fetchedObjects as? [Headache]
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        let alert = UIAlertController(title: "", message: "", preferredStyle: .Alert)
        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        
        if let error = error {
            print(error.domain)
            alert.title = NSLocalizedString("Error", comment: "")
            alert.message = NSLocalizedString("Unable to save chart. Please check permissions for this app in Settings.", comment: "")
        } else {
            alert.title = NSLocalizedString("Saved", comment: "")
            alert.message = NSLocalizedString("Chart was saved to Photos", comment: "")
        }
        
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion:nil)
    }



}
