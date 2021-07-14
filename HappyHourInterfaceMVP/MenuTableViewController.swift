//
//  MenuTableViewController.swift
//  HappyHourInterfaceMVP
//
//  Created by Nicholas Raspino on 9/30/19.
//  Copyright © 2019 Nicholas Raspino. All rights reserved.
//

import UIKit
import MobileCoreServices
import MapKit

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

class MenuTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    var model: Model!
    var restaurant: Restaurant!
    private var restaurantCell: TableViewCell?
    
    // MARK: - Interface Builder
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBAction func segmentedChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            model.foodOrDrinkFilter = .food
        } else {
            model.foodOrDrinkFilter = .drink
        }
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    @IBAction func moreButtonPressed(_ sender: UIButton) {
        if restaurantCell!.showAllHours == false {
            restaurantCell!.showAllHours = true
            restaurantCell!.moreButton.setTitle("less", for: .normal)
        } else {
            restaurantCell!.showAllHours = false
            restaurantCell!.moreButton.setTitle("more", for: .normal)
        }
        tableView.reloadData()
    }
    @IBAction func callButtonPressed(_ sender: UIButton) {
        if restaurant.phoneNumber != nil {
            guard let number = URL(string: "tel://" + restaurant.phoneNumber!) else { return }
            UIApplication.shared.open(number)
        } else {
            showAllertController(missingInfo: "Phone Number")
        }
    }
    @IBAction func websiteButtonPressed(_ sender: UIButton) {
        if restaurant.website != nil {
            if let url = URL(string: "http://\(restaurant.website!)") {
                UIApplication.shared.open(url)
            }
        } else {
            showAllertController(missingInfo: "Website")
        }
    }
    @IBAction func favoriteButtonPressed(_ sender: UIButton) {
        if let id = restaurant.id {
            if model.favorites.contains(id) {
                if let index = model.favorites.firstIndex(of: id) {
                    model.favorites.remove(at: index)
                    sender.tintColor = UIColor.systemBlue
                }
            } else {
                model.favorites.append(id)
                sender.tintColor = UIColor.systemRed
            }
        } else {
            showAllertController(missingInfo: "Restaurant ID")
        }
    }
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        showActivityViewController(button: sender)
    }
    @IBAction func reportButtonPressed(_ sender: UIButton) {
        showReportViewController()
    }
    @IBAction func directionsButtonPressed(_ sender: UIButton) {
        showDirectionsInAppleMaps()
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if model.foodOrDrinkFilter == .drink {
            segmentedControl.selectedSegmentIndex = 1
        }
        tableView.reloadData()
    }
    
    // MARK: - Methods
    
    private func showAllertController(missingInfo: String) {
        let ac = UIAlertController(title: missingInfo, message: "We don't seem to have the \(missingInfo).", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(ac, animated: true)
    }
    
    private func activityItems(latitude: Double, longitude: Double) -> [AnyObject]? {
        var items = [AnyObject]()
        let title = "Join me at \(restaurant.title!) for happy hour!"
        let hours = "\(restaurant.hours!)"
        let addressLineOne = "\(restaurant.address!)"
        let addressLineTwo = "San Antonio, TX"
        var phoneNumber = "\(restaurant.phoneNumber!)"
        let indexOne = phoneNumber.index(phoneNumber.startIndex, offsetBy: 6)
        phoneNumber.insert("-", at: indexOne)
        let indexTwo = phoneNumber.index(phoneNumber.startIndex, offsetBy: 3)
        phoneNumber.insert("-", at: indexTwo)
        let website = "\(restaurant.website!)"
        var message = title + "\n\n" + hours + "\n\n" + addressLineOne + "\n" + addressLineTwo + "\n\n" + website + "\n\n" + phoneNumber
        if restaurant.additionalInfo != nil {
            if restaurant.additionalInfo == "" {
                // do nothing
            } else {
                let info = "\(restaurant.additionalInfo!)"
                message += "\n\n"
                message += info
            }
        }
        items.append(message as AnyObject)
        return items
    }
    
    private func makeAttributedString(title: String, subtitle: String?, price: String) -> NSAttributedString {
        if #available(iOS 13.0, *) {
            let titleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline), NSAttributedString.Key.foregroundColor: UIColor.label]
            let subtitleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline), NSAttributedString.Key.foregroundColor: UIColor.secondaryLabel]
            let titleString = NSMutableAttributedString(string: "$\(price) \(title)\n", attributes: titleAttributes)
            if subtitle != nil {
                let subtitleString = NSAttributedString(string: subtitle!, attributes: subtitleAttributes)
                titleString.append(subtitleString)
            }
            return titleString
        } else {
            let titleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
            let subtitleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)]
            let titleString = NSMutableAttributedString(string: "$\(price) \(title)\n", attributes: titleAttributes)
            if subtitle != nil {
                let subtitleString = NSAttributedString(string: subtitle!, attributes: subtitleAttributes)
                titleString.append(subtitleString)
            }
            return titleString
        }
        
    }
    
    private func makeAllHoursString() -> [String] {
        var days = ""
        var numbers = ""
        if restaurant.mondayHours != nil {
            let components = restaurant.mondayHours!.split(separator: " ")
            days.append(contentsOf: components[0])
            numbers.append(contentsOf: components[1])
            if components.count > 2 {
                let secondNumberComponent = components[2]
                numbers.append(" \(secondNumberComponent)")
            }
        }
        if restaurant.tuesdayHours != nil {
            if days != "" {
                days.append("\n")
            }
            if numbers != "" {
                numbers.append("\n")
            }
            let components = restaurant.tuesdayHours!.split(separator: " ")
            days.append(contentsOf: components[0])
            numbers.append(contentsOf: components[1])
            if components.count > 2 {
                let secondNumberComponent = components[2]
                numbers.append(" \(secondNumberComponent)")
            }
        }
        if restaurant.wednesdayHours != nil {
            if days != "" {
                days.append("\n")
            }
            if numbers != "" {
                numbers.append("\n")
            }
            let components = restaurant.wednesdayHours!.split(separator: " ")
            days.append(contentsOf: components[0])
            numbers.append(contentsOf: components[1])
            if components.count > 2 {
                let secondNumberComponent = components[2]
                numbers.append(" \(secondNumberComponent)")
            }
        }
        if restaurant.thursdayHours != nil {
            if days != "" {
                days.append("\n")
            }
            if numbers != "" {
                numbers.append("\n")
            }
            let components = restaurant.thursdayHours!.split(separator: " ")
            days.append(contentsOf: components[0])
            numbers.append(contentsOf: components[1])
            if components.count > 2 {
                let secondNumberComponent = components[2]
                numbers.append(" \(secondNumberComponent)")
            }
        }
        if restaurant.fridayHours != nil {
            if days != "" {
                days.append("\n")
            }
            if numbers != "" {
                numbers.append("\n")
            }
            let components = restaurant.fridayHours!.split(separator: " ")
            days.append(contentsOf: components[0])
            numbers.append(contentsOf: components[1])
            if components.count > 2 {
                let secondNumberComponent = components[2]
                numbers.append(" \(secondNumberComponent)")
            }
        }
        if restaurant.saturdayHours != nil {
            if days != "" {
                days.append("\n")
            }
            if numbers != "" {
                numbers.append("\n")
            }
            let components = restaurant.saturdayHours!.split(separator: " ")
            days.append(contentsOf: components[0])
            numbers.append(contentsOf: components[1])
            if components.count > 2 {
                let secondNumberComponent = components[2]
                numbers.append(" \(secondNumberComponent)")
            }
        }
        if restaurant.sundayHours != nil {
            if days != "" {
                days.append("\n")
            }
            if numbers != "" {
                numbers.append("\n")
            }
            let components = restaurant.sundayHours!.split(separator: " ")
            days.append(contentsOf: components[0])
            numbers.append(contentsOf: components[1])
            if components.count > 2 {
                let secondNumberComponent = components[2]
                numbers.append(" \(secondNumberComponent)")
            }
        }
        
        return [days, numbers]
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0  {
            return 1
        } else {
            if segmentedControl.selectedSegmentIndex == 0 {
                if restaurant.foodMenuItems.count == 0 {
                    return 1
                } else {
                    return restaurant.foodMenuItems.count
                }
            } else {
                if restaurant.drinkMenuItems.count == 0 {
                    return 1
                } else {
                    return restaurant.drinkMenuItems.count
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("reload data called")
        if indexPath.section == 0  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Info", for: indexPath) as! TableViewCell
            restaurantCell = cell
            cell.nameLabel.text = restaurant.title
            if cell.showAllHours == false {
                if restaurant.hours == "None today" {
                    cell.hoursLabel.text = restaurant.hours
                    cell.numbersLabel.text = ""
                } else {
                    let components = restaurant.hours!.split(separator: " ")
                    let dayComponent = components[0]
                    let dayString = String(dayComponent)
                    let numberComponent = components[1]
                    var numberString = String(numberComponent)
                    if components.count > 2 {
                        let secondNumberComponent = components[2]
                        numberString.append(" \(secondNumberComponent)")
                    }
                    cell.hoursLabel.text = dayString
                    cell.numbersLabel.text = numberString
                }
            } else {
                let strings = makeAllHoursString()
                cell.hoursLabel.text = strings[0]
                cell.numbersLabel.text = strings[1]
            }
            cell.infoLabel.text = restaurant.additionalInfo
            if restaurant.id != nil {
                if model.favorites.contains(restaurant.id!) {
                    cell.favoriteButton.tintColor = UIColor.systemRed
                } else {
                    cell.favoriteButton.tintColor = UIColor.systemBlue
                }
            }
            return cell
        } else if segmentedControl.selectedSegmentIndex == 0 {
            if restaurant.foodMenuItems.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.textLabel?.text = "No food specials"
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                let food = restaurant.foodMenuItems[indexPath.row]
                if food.title != nil && food.price != nil {
                    cell.textLabel?.attributedText = makeAttributedString(title: food.title!, subtitle: food.details, price: food.price!)
                    return cell
                } else {
                    return cell
                }
            }
        } else {
            if restaurant.drinkMenuItems.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.textLabel?.text = "No drink specials"
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                let drink = restaurant.drinkMenuItems[indexPath.row]
                if drink.title != nil && drink.price != nil {
                    cell.textLabel?.attributedText = makeAttributedString(title: drink.title!, subtitle: drink.details, price: drink.price!)
                    return cell
                } else {
                    return cell
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    private func showActivityViewController(button: UIView) {
        if restaurant.latitude != nil && restaurant.longitude != nil {
            guard let activityItemsToShare = activityItems(latitude: restaurant.latitude!, longitude: restaurant.longitude!) else { return }
            let vc = UIActivityViewController(activityItems: activityItemsToShare, applicationActivities: nil)
            vc.popoverPresentationController?.sourceView = button
            present(vc, animated: true, completion: nil)
        } else {
            showAllertController(missingInfo: "Coordinates")
        }
    }
    
    private func showReportViewController() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ReportViewController") as? ReportViewController {
            vc.restaurant = restaurant
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func showDirectionsInAppleMaps() {
        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        restaurant.mapItem().openInMaps(launchOptions: launchOptions)
    }
}
