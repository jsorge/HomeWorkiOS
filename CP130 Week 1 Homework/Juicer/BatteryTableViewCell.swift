//
//  BatteryTableViewCell.swift
//  Juicr
//
//  Created by Jared Sorge on 6/19/16.
//  Copyright © 2016 Taphouse Software. All rights reserved.
//

import UIKit

class BatteryTableViewCell: UITableViewCell {
    private var battery: Battery?

    //IBOutlets
    @IBOutlet private var typeLabel: UILabel!
    @IBOutlet private var countLabel: UILabel!
    

    
    //MARK: API
    func configure(withBattery battery: Battery) {
        self.battery = battery
        
        typeLabel.text = battery.name
        countLabel.text = "Count: \(battery.count)"
    }
}
