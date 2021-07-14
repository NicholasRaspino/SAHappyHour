//
//  FilterViewController.swift
//  HappyHourInterfaceMVP
//
//  Created by Nicholas Raspino on 8/19/19.
//  Copyright © 2019 Nicholas Raspino. All rights reserved.
//

import UIKit

/*
 protocol HappyHourDataSource {
     var restaurantsToShow: [Restaurant] { get }
     var restaurantFilter: Filter { get }
     var date: Date? { get }
     var searchedText: String? { get }
     var favorites: [String] { get set }
     var foodOrDrinkFilter: FoodOrDrink { get set}
     func updateIfNecessary()
     func filterForText(text: String)
     func showAllRestaurants(favoritesOnly: Bool)
     func showCurrentRestaurants(favoritesOnly: Bool)
     func showFutureRestaurants(futureDate: Date, favoritesOnly: Bool)
 }
*/

class FilterViewController: UIViewController {
    
    // MARK: - Properties
    
    var model: Model!
    
    // MARK: - Interface Builder

    @IBOutlet weak var showFavoritesOnlySwitch: UISwitch! 
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func favoriteSwitchValueChanged(_ sender: UISwitch) {
        if segmentedControl.selectedSegmentIndex == 0 {
            if showFavoritesOnlySwitch.isOn == false {
                model.showAllRestaurants(favoritesOnly: false)
            } else if showFavoritesOnlySwitch.isOn == true {
                model.showAllRestaurants(favoritesOnly: true)
            }
        } else if segmentedControl.selectedSegmentIndex == 1 {
            if showFavoritesOnlySwitch.isOn == false {
                model.showCurrentRestaurants(favoritesOnly: false)
            } else if showFavoritesOnlySwitch.isOn == true {
                model.showCurrentRestaurants(favoritesOnly: true)
            }
        } else {
            let date = datePicker.date
            if showFavoritesOnlySwitch.isOn == false {
                model.showFutureRestaurants(futureDate: date, favoritesOnly: false)
            } else if showFavoritesOnlySwitch.isOn == true {
                model.showFutureRestaurants(futureDate: date, favoritesOnly: true)
            }
        }
    }
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            datePicker.isUserInteractionEnabled = false
            datePicker.alpha = 0.4
            if showFavoritesOnlySwitch.isOn == false {
                model.showAllRestaurants(favoritesOnly: false)
            } else if showFavoritesOnlySwitch.isOn == true {
                model.showAllRestaurants(favoritesOnly: true)
            }
        } else if sender.selectedSegmentIndex == 1 {
            datePicker.isUserInteractionEnabled = false
            datePicker.alpha = 0.4
            if showFavoritesOnlySwitch.isOn == false {
                model.showCurrentRestaurants(favoritesOnly: false)
            } else if showFavoritesOnlySwitch.isOn == true {
                model.showCurrentRestaurants(favoritesOnly: true)
            }
        } else {
            datePicker.isUserInteractionEnabled = true
            datePicker.alpha = 1
            let date = datePicker.date
            if showFavoritesOnlySwitch.isOn == false {
                model.showFutureRestaurants(futureDate: date, favoritesOnly: false)
            } else if showFavoritesOnlySwitch.isOn == true {
                model.showFutureRestaurants(futureDate: date, favoritesOnly: true)
            }
        }
    }
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        let date = datePicker.date
        if showFavoritesOnlySwitch.isOn == false {
            model.showFutureRestaurants(futureDate: date, favoritesOnly: false)
        } else if showFavoritesOnlySwitch.isOn == true {
            model.showFutureRestaurants(futureDate: date, favoritesOnly: true)
        }
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Filters"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        switch model.restaurantFilter {
        case .all:
            showFavoritesOnlySwitch.isOn = false
            segmentedControl.selectedSegmentIndex = 0
            datePicker.isUserInteractionEnabled = false
            datePicker.alpha = 0.4
        case .allFavorites:
            showFavoritesOnlySwitch.isOn = true
            segmentedControl.selectedSegmentIndex = 0
            datePicker.isUserInteractionEnabled = false
            datePicker.alpha = 0.4
        case .current:
            showFavoritesOnlySwitch.isOn = false
            segmentedControl.selectedSegmentIndex = 1
            datePicker.isUserInteractionEnabled = false
            datePicker.alpha = 0.4
        case .currentFavorites:
            showFavoritesOnlySwitch.isOn = true
            segmentedControl.selectedSegmentIndex = 1
            datePicker.isUserInteractionEnabled = false
            datePicker.alpha = 0.4
        case .future:
            showFavoritesOnlySwitch.isOn = false
            segmentedControl.selectedSegmentIndex = 2
            datePicker.isUserInteractionEnabled = true
            datePicker.alpha = 1
            datePicker.date = model.date!
        case .futureFavorites:
            showFavoritesOnlySwitch.isOn = true
            segmentedControl.selectedSegmentIndex = 2
            datePicker.isUserInteractionEnabled = true
            datePicker.alpha = 1
            datePicker.date = model.date!
        }
    }
}
