//
//  SecondViewController.swift
//  Cupboard Culprit
//
//  Created by Richard Seaman on 01/05/2018.
//  Copyright © 2018 RichApps. All rights reserved.
//

import UIKit
import Firebase
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
    
    // Slider tags for reference
    let sliderTagTimeSensorRead:Int = 10
    let sliderTagTimeSensorUpload:Int = 11
    let sliderTagTimeImageCapture:Int = 12
    let sliderTagTimeImageDelay:Int = 13
    let sliderTagTimeDisplayUpdate:Int = 14
    let sliderTagTimeBackgroundChecks:Int = 15
    
    // Time Labels
    var timeLabels:[Int: UILabel] = [Int: UILabel]()
    
    // Firebase
    var ref: DatabaseReference!
    
    // Firebase config variables (initialised to default)
    var timeSensorRead:Int = 60
    var timeSensorUpload:Int = 900
    var timeImageCapture:Int = 60
    var timeImageDelay:Int = 0
    var timeDisplayUpdate:Int = 10
    var timeBackgroundChecks:Int = 60
    
    // Max / min limits for each
    let minTimeSensorRead:Int = 30
    let maxTimeSensorRead:Int = 60 * 10
    
    let minTimeSensorUpload:Int = 60 * 5
    let maxTimeSensorUpload:Int = 60 * 60
    
    let minTimeImageCapture:Int = 15
    let maxTimeImageCapture:Int = 60 * 5
    
    let minTimeImageDelay:Int = 0
    let maxTimeImageDelay:Int = 5
    
    let minTimeDisplayUpdate:Int = 5
    let maxTimeDisplayUpdate:Int = 15
    
    let minTimeBackgroundChecks:Int = 60
    let maxTimeBackgroundChecks:Int = 60 * 60
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Apply tableview to Table View Controller (needed to get rid of blank space)
        tableViewController.tableView = tableView
        
        // Apply the row height
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        self.tableView.estimatedRowHeight = 44.0;
        
        ref = Database.database().reference()
        
        ref.child("config").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.childrenCount)
            // Get config values
            let config = snapshot.value as? NSDictionary
            self.timeSensorRead = config?["time_between_sensor_reads"] as? Int ?? 60
            self.timeSensorUpload = config?["time_between_sensor_uploads"] as? Int ?? 900
            self.timeImageCapture = config?["time_between_image_captures"] as? Int ?? 60
            self.timeImageDelay = config?["time_delay_bvefore_picture"] as? Int ?? 0
            self.timeDisplayUpdate = config?["time_between_display_updates"] as? Int ?? 10
            self.timeBackgroundChecks = config?["time_between_checks_background"] as? Int ?? 60
            
            // Reload the table
            self.refresh()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func refresh() {
        self.tableView.reloadData()
    }
    
    // UI Updates
    
    @objc func sliderFinished(slider:UISlider) {
        switch slider.tag {
        case self.sliderTagTimeSensorRead:
            print("Sensor Read slider edit did end \(slider.value)")
        default:
            print("Unknown slider did end edit")
        }
    }
    
    @objc func sliderValueChanged(slider:UISlider) {
        switch slider.tag {
        case self.sliderTagTimeSensorRead:
            print("Sensor Read slider changed \(slider.value)")
            let rounded = roundf(slider.value / 5.0) * 5.0;
            self.timeLabels[slider.tag]?.text = "\(Int(rounded))s"
        default:
            print("Unknown slider did end edit")
        }
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
                let timeLabel = cell.viewWithTag(4) as? UILabel
                
                // Set the elements
                if let actTextLabel = textLabel {
                    actTextLabel.text = "Time in seconds between sensor readings. Multiple sensor readings are averaged before uploading."
                }
                if let actTimeLabel = timeLabel {
                    actTimeLabel.text = "\(self.timeSensorRead)s"
                    self.timeLabels[self.sliderTagTimeSensorRead] = actTimeLabel
                }
                if let actSlider = slider {
                    actSlider.tintColor = colourDefault
                    actSlider.minimumValue = Float(self.minTimeSensorRead)
                    actSlider.maximumValue = Float(self.maxTimeSensorRead)
                    actSlider.value = Float(self.timeSensorRead)
                    actSlider.tag = self.sliderTagTimeSensorRead
                    actSlider.addTarget(self, action: #selector(sliderValueChanged(slider:)), for: [UIControlEvents.valueChanged])
                    actSlider.addTarget(self, action: #selector(sliderFinished(slider:)), for: [UIControlEvents.touchUpInside, UIControlEvents.touchUpOutside])
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

