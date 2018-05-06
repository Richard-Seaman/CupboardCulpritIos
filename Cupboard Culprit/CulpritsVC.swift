//
//  CulpritsVC.swift
//  Cupboard Culprit
//
//  Created by Richard Seaman on 05/05/2018.
//  Copyright © 2018 RichApps. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class CulpritsVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var culpritPickerButton: UIButton!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    // Picker View
    @IBOutlet weak var culpritPickerBackgroundView: UIControl!
    @IBOutlet weak var culpritPickerContainerView: UIView!
    @IBOutlet weak var culpritPickerLabel: UILabel!
    @IBOutlet weak var culpritPicker: UIPickerView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    let pickerShaded:CGFloat = 0.75
    
    // Firebase
    var ref: DatabaseReference!
    
    var culprits:NSDictionary? = nil
    var keys: [Int]? = nil
    var key:Int? = nil
    
    var pickerMap:[String:Int] = [String:Int]()
    var pickerKeys: [String] = [String]()
    var pickerKey: String = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up nav bar
        self.navigationItem.titleView = getNavImageView(UIApplication.shared.statusBarOrientation)

        // Set Firebase reference
        ref = Database.database().reference()
        
        // Set up Firebase oberservation (called every time realtime data changes)
        ref.child("culprits").observe(DataEventType.value, with: { (snapshot) in
            print("Culprits updated...")
            self.pickerMap = [String:Int]()  // reset
            self.culprits = snapshot.value as? NSDictionary
            if let culprits = self.culprits {
                let stringKeys = culprits.allKeys as? [String]
                if let stringKeys = stringKeys {
                    self.keys = stringKeys.map { Int($0)!}
                    self.keys! = self.keys!.sorted()
                    
                    for stringKey in stringKeys {
                        let dict = self.culprits![stringKey] as? [String:String]
                        if let dict = dict {
                            let timestamp:String = dict["timestamp"]!.replacingOccurrences(of: ":", with: " : ")
                            self.pickerMap[timestamp] = Int(stringKey)
                        }
                    }
                    
                    self.pickerKeys = self.pickerMap.keys.sorted()
                }
            }
            self.culpritPicker.reloadAllComponents()
            self.changeCulprit()
            
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // Add targets to buttons
        self.prevButton.addTarget(self, action: #selector(self.prevButtonTapped), for: UIControlEvents.touchUpInside)
        self.nextButton.addTarget(self, action: #selector(self.nextButtonTapped), for: UIControlEvents.touchUpInside)
        self.culpritPickerButton.addTarget(self, action: #selector(self.culpritPickerButtonTapped), for: UIControlEvents.touchUpInside)
        self.cancelButton.addTarget(self, action: #selector(self.hidePicker), for: UIControlEvents.touchUpInside)
        self.confirmButton.addTarget(self, action: #selector(self.confirmButtonTapped), for: UIControlEvents.touchUpInside)
        
        // Picker view init
        self.culpritPickerContainerView.clipsToBounds = true
        self.culpritPickerContainerView.layer.borderWidth = 1
        self.culpritPickerContainerView.layer.borderColor = UIColor.black.cgColor
        self.culpritPickerContainerView.layer.cornerRadius = 5
        self.culpritPickerBackgroundView.addTarget(self, action: #selector(self.hidePicker), for: UIControlEvents.touchUpInside)
        self.culpritPicker.delegate = self
        self.culpritPicker.dataSource = self
        self.culpritPicker.tintColor = colourDefault
        self.cancelButton.tintColor = colourDefault
        self.confirmButton.tintColor = colourDefault
        
        // Picker is intially hidden
        self.hidePicker()
        
        if (self.culprits == nil) {
            self.initUi()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initUi() {
        self.culpritPickerButton.setTitle("--", for: UIControlState())
        self.prevButton.isEnabled = false
        self.nextButton.isEnabled = false
        self.loadingView.alpha = 1
        self.loadingActivityIndicator.alpha = 0
    }
    
    // MARK: Direct UI Actions
    
    @objc func prevButtonTapped() {
        if let keys = self.keys {
            if let currentKey = self.key {
                let currentIndex:Int? = keys.index(of: currentKey)
                if let currentIndex = currentIndex {
                    if (currentIndex != 0) {
                        self.key = keys[currentIndex - 1]
                        print("New Key: \(self.key!)")
                        self.changeCulprit()
                    }
                }
            }
        }
    }
    @objc func nextButtonTapped() {
        if let keys = self.keys {
            if let currentKey = self.key {
                let currentIndex:Int? = keys.index(of: currentKey)
                if let currentIndex = currentIndex {
                    if (currentIndex != keys.count - 1) {
                        self.key = keys[currentIndex + 1]
                        print("New Key: \(self.key!)")
                        self.changeCulprit()
                    }
                }
            }
        }
    }
    
    @objc func culpritPickerButtonTapped() {
        
        // Figure out the picker key (timestamp string) from the current key (time Int)
        for tempPickerKey in self.pickerKeys {
            if (self.pickerMap[tempPickerKey] == self.key) {
                self.pickerKey = tempPickerKey
                break
            }
        }
        
        if (self.culpritPickerBackgroundView.alpha == 0) {
            // If it was hidden, show the picker and assign it to the currently selected culprit
            self.culpritPicker.selectRow(self.pickerKeys.index(of: self.pickerKey)!, inComponent: 0, animated: true)
            self.showPicker()
        } else {
            // If it was shown, hide it and set the currently selected culprit
            self.pickerKey = self.pickerKeys[self.culpritPicker.selectedRow(inComponent: 0)]
            self.key = Int(self.pickerMap[self.pickerKey]!)
            self.hidePicker()
        }
        
    }
    
    @objc func confirmButtonTapped() {
        print("confirmButtonTapped")
        
        // Select the question
        self.pickerKey = self.pickerKeys[self.culpritPicker.selectedRow(inComponent: 0)]
        self.key = Int(self.pickerMap[self.pickerKey]!)
        // Hide the picker view
        self.hidePicker()
        // Update the UI
        self.changeCulprit()
        
    }
    
    // MARK: Indirect UI Actions
    
    func showLoading() {
        self.loadingView.alpha = 1
        self.loadingActivityIndicator.alpha = 1
        self.loadingLabel.text = "Loading image, please wait..."
    }
    
    func hideLoading() {
        self.loadingView.alpha = 0
    }
    
    func showLoadingError() {
        self.loadingActivityIndicator.alpha = 0
        self.loadingLabel.text = "Sorry, image not available."
    }
    
    func changeCulprit() {
        
        self.imageView.image = nil
        
        // Update UI depending on what's available
        if (self.culprits == nil) {
            // culprits not yet loaded (or none)
            self.initUi()
        }
        else if (self.keys != nil) {
            // culprits available and keys extracted
            
            // If no key assigned, assign most recent
            if (self.key == nil) {
                self.key = self.keys!.last
            }
            
            // Get the timestamp & image name for the culprit
            var imageLocation: String? = nil
            var imageName: String? = nil
            let dict = self.culprits![String(self.key!)] as? [String:String]
            if let dict = dict {
                let timestamp:String = dict["timestamp"]!.replacingOccurrences(of: ":", with: " : ")
                self.culpritPickerButton.setTitle(timestamp, for: UIControlState())
                imageName = dict["imageName"]!
                print("Image = \(imageName!)")
                imageLocation = "gs://cupboard-culprit.appspot.com/" + imageName!
            }
            
            // Enable / disable the next/prev buttons
            if (key! == self.keys!.last) {
                self.nextButton.isEnabled = false
            } else {
                self.nextButton.isEnabled = true
            }
            
            if (key! == self.keys!.first) {
                self.prevButton.isEnabled = false
            } else {
                self.prevButton.isEnabled = true
            }
            
            // Load the image
            if let imageName = imageName {
                
                if let localImage = self.getImage(imageFileName: imageName) {
                    // Local image available, load it
                    self.imageView.image = localImage
                    self.hideLoading()
                }
                else {
                    // Must download image
                    // Construct the image url
                    if let imageLocation = imageLocation {
                        let storageRef = Storage.storage().reference(forURL: imageLocation)
                        storageRef.downloadURL(completion: { (url, error) in
                            do {
                                var data:Data? = nil
                                if let actUrl = url {
                                    try data = Data(contentsOf: actUrl)
                                    let imageFromData = UIImage(data: data! as Data)
                                    self.saveImage(imageFileName: imageName, image: imageFromData!)
                                    self.imageView.image = imageFromData
                                    self.hideLoading()
                                } else {
                                    // If no image file found, this happens
                                    self.showLoadingError()
                                }
                            }
                            catch {
                                print(error)
                            }
                        })
                    }
                }
            }
            
            // if not yet complete, show loading
            if (self.imageView.image == nil) {
                self.showLoading()
            }
            
        }
    }
    
    
    // MARK: Picker Delegate Methods
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pickerKeys.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pickerKeys[row]
    }
    
    // MARK: Image persistance
    
    func saveImage(imageFileName:String, image:UIImage) {
        do {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent("\(imageFileName)")
            if let pngImageData = UIImagePNGRepresentation(image) {
                try pngImageData.write(to: fileURL, options: .atomic)
                print("Image saved: \(imageFileName)")
            }
        } catch {
            print(error)
        }
    }
    
    func getImage(imageFileName:String) -> UIImage? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent("\(imageFileName)").path
        if FileManager.default.fileExists(atPath: filePath) {
            return UIImage(contentsOfFile: filePath)
        }
        return nil
    }
    
    
    // MARK: Animations
    
    func showPicker() {
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.1, options: [], animations: {
                        self.culpritPickerContainerView.alpha = 1
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.1, options: [], animations: {
                        self.culpritPickerBackgroundView.alpha = self.pickerShaded
        }, completion: nil)
        
    }
    
    @objc func hidePicker() {
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.1, options: [], animations: {
                        self.culpritPickerContainerView.alpha = 0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.1, options: [], animations: {
                        self.culpritPickerBackgroundView.alpha = 0
        }, completion: nil)
        
    }


}
