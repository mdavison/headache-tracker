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
    
    let severityLevels = ["1", "2", "3", "4", "5"]
    
    var managedContext: NSManagedObjectContext!
    var headaches = [Headache]()
    
    var weekModel: Week?
    var monthModel: Month?
    var yearModel: Year?
    var selectedSegmentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        setHeadaches()

        weekModel = Week(headaches: headaches)
        monthModel = Month(headaches: headaches)
        yearModel = Year(headaches: headaches)

        if let selectedSegment = getSelectedSegment(selectedSegmentIndex) {
            if let headaches = getHeadaches(selectedSegment) {
                setChart(severityLevels, values: headaches)
            }
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
    
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        selectedSegmentIndex = sender.selectedSegmentIndex
        if let selectedSegment = getSelectedSegment(selectedSegmentIndex) {
            if let headaches = getHeadaches(selectedSegment) {
                setChart(severityLevels, values: headaches)
            }
        }
    }
    
    @IBAction func saveChart(sender: UIBarButtonItem) {
        pieChartView.saveToCameraRoll()
    }
    
    
    // MARK: - Helper methods
    
    private func setHeadaches() {
        let headacheFetch = NSFetchRequest(entityName: "Headache")
        headacheFetch.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            let results = try managedContext.executeFetchRequest(headacheFetch) as! [Headache]
            
            if results.count > 0 {
                headaches = results
            }
        } catch let error as NSError {
            print("Error: \(error) " + "description: \(error.localizedDescription)")
        }
    }
    
    private func setChart(dataPoints: [String], values: [Double]) {
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
            pieChartView.descriptionText = "Headaches by severity for past \(segment)"
        } else {
            pieChartView.descriptionText = "Headaches by severity"
        }
    }
    
    private func getHeadaches(timePeriod: String) -> [Double]? {
        var severityArray = [[Headache](), [Headache](), [Headache](), [Headache](), [Headache]()]
        var headacheCountBySeverity = [Double]()
        var headachesForTimePeriod = [Headache]()
        
        switch timePeriod {
        case "week":
            if let headaches = weekModel?.headachesForPastWeek {
                headachesForTimePeriod = headaches
            }
        case "month":
            if let headaches = monthModel?.headachesForPastMonth {
                headachesForTimePeriod = headaches
            }
        case "year":
            if let headaches = yearModel?.headachesForPastYear {
                headachesForTimePeriod = headaches
            }
        default:
            return nil
        }
        
        for headache in headachesForTimePeriod {
            let severityInt = Int(headache.severity!)
            severityArray[severityInt-1] += [headache]
        }
        
        for ha in severityArray {
            headacheCountBySeverity.append(Double(ha.count))
        }
        return headacheCountBySeverity
    }
    
    private func getSelectedSegment(index: Int) -> String? {
        switch index {
        case 0: return "week"
        case 1: return "month"
        case 2: return "year"
        default: return nil
        }
    }

}
