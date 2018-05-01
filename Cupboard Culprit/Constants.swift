//
//  Constants.swift
//  Cupboard Culprit
//
//  Created by Richard Seaman on 01/05/2018.
//  Copyright © 2018 RichApps. All rights reserved.
//

import Foundation
import UIKit

let colourDefault = UIColor(red: 0/255, green: 153/255, blue: 204/255, alpha: 1.0)

func returnHeader(_ sender:UIView) -> UITableViewHeaderFooterView {
    
    // Recast the view as a UITableViewHeaderFooterView
    let header: UITableViewHeaderFooterView = sender as! UITableViewHeaderFooterView
    
    // Make the text white
    header.textLabel!.textColor = UIColor.white
    
    // Make the header transparent
    header.alpha = 0.8
    
    // Set the background colour
    header.contentView.backgroundColor = colourDefault
    
    return header
}
