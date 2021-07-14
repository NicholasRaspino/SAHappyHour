//
//  ReportViewController.swift
//  HappyHourInterfaceMVP
//
//  Created by Nicholas Raspino on 8/12/19.
//  Copyright © 2019 Nicholas Raspino. All rights reserved.
//

import UIKit
import CloudKit

class ReportViewController: UIViewController {
    
    // MARK: - Properties
    
    var restaurant: Restaurant!
    var checkedCheckBoxes: [UIButton] = []
    var issueStrings = ["The restaurant is closed.", "The menu is out of date.", "The website is out of date.", "The hours are incorrect.", "The phone number is incorrect.", "Other information is incorrect.", "Other features aren't working.", "There are grammatical errors."]
    
    // MARK: - Interface Builder
    
    @IBOutlet var checkBox: [UIButton]!
    @IBOutlet var issueLabels: [UILabel]!
    @IBOutlet weak var sendButton: UIButton!
    @IBAction func checkBoxButtonPressed(_ sender: UIButton) {
        if checkedCheckBoxes.contains(sender) {
            if let index = checkedCheckBoxes.firstIndex(of: sender) {
                checkedCheckBoxes.remove(at: index)
                sender.setImage(UIImage(named: "CheckboxOff"), for: .normal)
            }
        } else {
            checkedCheckBoxes.append(sender)
            sender.setImage(UIImage(named: "CheckboxOn"), for: .normal)
        }
    }
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        saveReportToCloud()
    }
    
    // MARK: - Methods
    
    func saveReportToCloud() {
        if checkedCheckBoxes.count == 0 {
            let ac = UIAlertController(title: "Nothing selected", message: "Please select one or more issues before submitting", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        } else {
            let date = Date()
            let calendar = Calendar.current
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            var reportString = "\(month)/\(day) - \(restaurant.title!):"
            for button in checkedCheckBoxes {
                let index = button.tag
                let issue = issueStrings[index]
                reportString.append(" \(issue)")
            }
            let reportRecord = CKRecord(recordType: "Report")
            reportRecord["issue"] = reportString as CKRecordValue
            let myContainer = CKContainer.default()
            myContainer.publicCloudDatabase.save(reportRecord) { [unowned self] record, error in
                DispatchQueue.main.async {
                    if let error = error {
                        let ac = UIAlertController(title: "Error", message: "Please try again later", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                            self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(ac, animated: true)
                        print("could not save to cloud \(error.localizedDescription)")
                    } else {
                        
                        let ac = UIAlertController(title: "Report sent", message: "Thank you for your feedback!", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                            self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(ac, animated: true)
                    }
                }
            }
        }
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendButton.layer.cornerRadius = 5
        for issue in issueLabels {
            if let index = issueLabels.firstIndex(of: issue) {
                issue.text = issueStrings[index]
            }
        }
    }
}
