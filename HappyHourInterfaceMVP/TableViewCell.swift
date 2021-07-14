//
//  TableViewCell.swift
//  HappyHourInterfaceMVP
//
//  Created by Nicholas Raspino on 8/8/19.
//  Copyright © 2019 Nicholas Raspino. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    // MARK: - Properties
    
    var showAllHours = false
    
    // MARK: - Interface Builder
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var numbersLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    
    // MARK: - View Controller Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        directionsButton.layer.cornerRadius = 5
        callButton.layer.cornerRadius = 5
        websiteButton.layer.cornerRadius = 5
        favoriteButton.layer.cornerRadius = 5
        shareButton.layer.cornerRadius = 5
        reportButton.layer.cornerRadius = 5
    }
    
    // MARK: - Methods
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
