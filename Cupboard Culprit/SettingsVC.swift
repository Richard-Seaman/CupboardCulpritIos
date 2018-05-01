//
//  SecondViewController.swift
//  Cupboard Culprit
//
//  Created by Richard Seaman on 01/05/2018.
//  Copyright © 2018 RichApps. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SettingsVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    // Table Variables
    var tableViewController = UITableViewController()
    
    // Sections
    let sectionHeadings:[String] = ["Sensor Settings", "Image Settings", "Misc. Settings"]
    let sectionRows:[Int] = [2, 2, 2]
    let sIndexSensor:Int = 0
    let sIndexImage:Int = 1
    let sIndexMisc:Int = 2
    
    // Sensors
    let rIndexSensorRead:Int = 0
    let rIndexSensorUpload:Int = 1
    
    // Images
    let rIndexImageCapture:Int = 0
    let rIndexImageDelay:Int = 1
    
    // misc
    let rIndexDisplayTime:Int = 0
    let rIndexBackgroundCheck:Int = 1
    
    // Identifiers
    let sliderIdentifier:String = "SliderCell"
    
    // Firebase values
    var ref: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply tableview to Table View Controller (needed to get rid of blank space)
        tableViewController.tableView = tableView
        
        // Apply the row height
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44.0;
        
        ref = Database.database().reference()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func refresh() {
        self.tableView.reloadData()
    }
    
    // MARK: - Tableview methods
    
    // Assign the rows per section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionRows[section]
    }
    
    // Determine Number of sections
    func numberOfSections(in tableView: UITableView) -> Int{
        return sectionRows.count
    }
    
    // Set properties of section header
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        returnHeader(view)
    }
    
    // Assign Section Header Text
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
        return sectionHeadings[section]
    }
    
    // Explicityly decide the sections and rows
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell:UITableViewCell = UITableViewCell()
        cell.isUserInteractionEnabled = true
        cell.accessoryType = UITableViewCellAccessoryType.none
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        switch indexPath.section {
            
        case sIndexSensor:
            
            // Sensor section
            switch indexPath.row {
                
            case rIndexSensorRead:
                // Slider Row
                cell = tableView.dequeueReusableCell(withIdentifier: sliderIdentifier) as UITableViewCell!
                
                // Grab the elements using the tag
                let background = cell.viewWithTag(1) as? UIView
                let textLabel = cell.viewWithTag(2) as? UILabel
                let slider = cell.viewWithTag(3) as? UISlider
                let textField = cell.viewWithTag(4) as? UITextView
                
                // Set the elements
                if let actTextLabel = textLabel {
                    actTextLabel.text = "Time in seconds between sensor readings. Multiple sensor readings are averaged before uploading."
                }
                if let actTextField = textField {
                    
                }
                if let actSlider = slider {
                    slider?.tintColor = colourDefault
                }
                
            case rIndexSensorUpload:
                // Slider Row
                cell = tableView.dequeueReusableCell(withIdentifier: sliderIdentifier) as UITableViewCell!
                
                // Grab the elements using the tag
                let background = cell.viewWithTag(1) as? UIView
                let textLabel = cell.viewWithTag(2) as? UILabel
                let slider = cell.viewWithTag(3) as? UISlider
                let textField = cell.viewWithTag(4) as? UITextView
                
                // Set the elements
                if let actTextLabel = textLabel {
                    actTextLabel.text = "Time in seconds between sensor uploads. This will be the increment between timestamps."
                }
                if let actTextField = textField {
                    
                }
                
            default:
                cell = UITableViewCell()
                cell.isUserInteractionEnabled = false
            }
            
        case sIndexImage:
            
            // Image section
            switch indexPath.row {
                
            case rIndexImageCapture:
                // Slider Row
                cell = tableView.dequeueReusableCell(withIdentifier: sliderIdentifier) as UITableViewCell!
                
                // Grab the elements using the tag
                let background = cell.viewWithTag(1) as? UIView
                let textLabel = cell.viewWithTag(2) as? UILabel
                let slider = cell.viewWithTag(3) as? UISlider
                let textField = cell.viewWithTag(4) as? UITextView
                
                // Set the elements
                if let actTextLabel = textLabel {
                    actTextLabel.text = "Minimum number of seconds between image captures."
                }
                if let actTextField = textField {
                    
                }
                
            case rIndexImageDelay:
                // Slider Row
                cell = tableView.dequeueReusableCell(withIdentifier: sliderIdentifier) as UITableViewCell!
                
                // Grab the elements using the tag
                let background = cell.viewWithTag(1) as? UIView
                let textLabel = cell.viewWithTag(2) as? UILabel
                let slider = cell.viewWithTag(3) as? UISlider
                let textField = cell.viewWithTag(4) as? UITextView
                
                // Set the elements
                if let actTextLabel = textLabel {
                    actTextLabel.text = "Delay in seconds between detecting the door is open and taking the picture."
                }
                if let actTextField = textField {
                    
                }
                
            default:
                cell = UITableViewCell()
                cell.isUserInteractionEnabled = false
            }
        
        case sIndexMisc:
            
            // Image section
            switch indexPath.row {
                
            case rIndexDisplayTime:
                // Slider Row
                cell = tableView.dequeueReusableCell(withIdentifier: sliderIdentifier) as UITableViewCell!
                
                // Grab the elements using the tag
                let background = cell.viewWithTag(1) as? UIView
                let textLabel = cell.viewWithTag(2) as? UILabel
                let slider = cell.viewWithTag(3) as? UISlider
                let textField = cell.viewWithTag(4) as? UITextView
                
                // Set the elements
                if let actTextLabel = textLabel {
                    actTextLabel.text = "Minimum number of seconds that each display message is shown for."
                }
                if let actTextField = textField {
                    
                }
                
            case rIndexBackgroundCheck:
                // Slider Row
                cell = tableView.dequeueReusableCell(withIdentifier: sliderIdentifier) as UITableViewCell!
                
                // Grab the elements using the tag
                let background = cell.viewWithTag(1) as? UIView
                let textLabel = cell.viewWithTag(2) as? UILabel
                let slider = cell.viewWithTag(3) as? UISlider
                let textField = cell.viewWithTag(4) as? UITextView
                
                // Set the elements
                if let actTextLabel = textLabel {
                    actTextLabel.text = "Time in seconds between checking for images to process."
                }
                if let actTextField = textField {
                    
                }
                
            default:
                cell = UITableViewCell()
                cell.isUserInteractionEnabled = false
            }
            
        default:
            cell = UITableViewCell()
            cell.isUserInteractionEnabled = false
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Animate de-selection regardless of cell...
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
}

