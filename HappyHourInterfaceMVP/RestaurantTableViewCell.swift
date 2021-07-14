//
//  RestaurantTableViewCell.swift
//  HappyHourInterfaceMVP
//
//  Created by Nicholas Raspino on 8/19/19.
//  Copyright © 2019 Nicholas Raspino. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {
    
    // MARK: - Interface Builder

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    // MARK: - View Controller Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: - Methods

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
