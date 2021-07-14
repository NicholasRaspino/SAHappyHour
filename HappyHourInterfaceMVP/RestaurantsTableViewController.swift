//
//  RestaurantsTableViewController.swift
//  HappyHourInterfaceMVP
//
//  Created by Nicholas Raspino on 8/14/19.
//  Copyright © 2019 Nicholas Raspino. All rights reserved.
//

import UIKit
import CoreLocation

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

class RestaurantsTableViewController: UITableViewController, CLLocationManagerDelegate, UISearchResultsUpdating {
    
    // MARK: - Properties
    
    var model: Model!
    private var restaurantDistancesDictionary: [Restaurant: Double] = [:]
    private var sortedRestaurantsArray: [Restaurant] = []
    private var locationManager: CLLocationManager?
    private var search: UISearchController?
    private var timer: Timer?
    private var knowsUserLocation = false
    
    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        registerForUpdates()
        model = Model()
        setUpLocationManager()
        setUpNavigationBar()
        tableView.tableFooterView = UIView()
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        search!.searchBar.text = model.searchedText
        model.updateIfNecessary()
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        search!.dismiss(animated: true, completion: nil)
        timer!.invalidate()
    }
    
    // MARK: - Methods
    
    private func registerForUpdates() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(restaurantsUpdated), name: Notification.Name("RestaurantsUpdated"), object: nil)
        nc.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    private func setUpLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
    }
    
    private func setUpNavigationBar() {
        title = "List"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "FilterIcon"), style: .plain, target: self, action: #selector(showFilterScreen))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "InfoIcon"), style: .plain, target: self, action: #selector(showInfoViewController))
        search = UISearchController(searchResultsController: nil)
        search!.searchResultsUpdater = self
        search!.obscuresBackgroundDuringPresentation = false
        search!.searchBar.placeholder = "Type something here to search"
        search!.searchBar.sizeToFit()
        navigationItem.searchController = search
        navigationItem.hidesSearchBarWhenScrolling = false
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    @objc private func restaurantsUpdated() {
        updateTableView()
    }
    
    @objc private func willEnterForeground() {
        model.updateIfNecessary()
    }
    
    @objc private func fireTimer() {
        updateTableView()
    }
    
    private func updateTableView() {
        sortRestaurants()
        self.tableView.reloadData()
    }
    
    private func sortRestaurants() {
        restaurantDistancesDictionary = [:]
        sortedRestaurantsArray = []
        var location: CLLocation?
        if let myLocation = locationManager?.location{
            location = myLocation
            knowsUserLocation = true
        } else {
            let centralLocation = CLLocation(latitude: 29.423701, longitude: -98.491958)
            location = centralLocation
        }
        for restaurant in model.restaurantsToShow {
            var distance: CLLocationDistance
            if restaurant.latitude != nil && restaurant.longitude != nil {
                distance = location!.distance(from: CLLocation(latitude: restaurant.latitude!, longitude: restaurant.longitude!))
            } else {
                distance = 0
            }
            let mileDistance = distance/1609.344
            restaurantDistancesDictionary[restaurant] = mileDistance
        }
        var distances = Array(restaurantDistancesDictionary.values)
        distances.sort(by: {
            $0 < $1
        })
        for distance in distances {
            for (key, value) in restaurantDistancesDictionary {
                if value == distance {
                    if !sortedRestaurantsArray.contains(key) {
                        sortedRestaurantsArray.append(key)
                    }
                }
            }
        }
    }
    
    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sortedRestaurantsArray.count > 0 {
            return sortedRestaurantsArray.count
        } else {
            return 1
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if sortedRestaurantsArray.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoRestaurantsCell", for: indexPath) 
            cell.textLabel?.text = "No restaurants currently on happy hour"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath) as! RestaurantTableViewCell
            let currentRestaurant = sortedRestaurantsArray[indexPath.row]
            cell.nameLabel.text = currentRestaurant.title
            cell.hoursLabel.text = currentRestaurant.hours
            if knowsUserLocation {
                let distance = restaurantDistancesDictionary[currentRestaurant]
                let distanceWithTwoDecimals = Double(round(distance! * 100)/100)
                cell.distanceLabel.text = "\(distanceWithTwoDecimals) mi"
            } else {
                cell.distanceLabel.text = nil
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if sortedRestaurantsArray.count > 0 {
            let restaurant = sortedRestaurantsArray[indexPath.row]
            showMenuTableViewController(restaurant: restaurant)
        }
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        model.filterForText(text: text)
    }

    // MARK: - Navigation
    
    @objc private func showFilterScreen() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "FilterViewController") as? FilterViewController {
            vc.model = model
            navigationController?.pushViewController(vc, animated: true)
        }
    }

    private func showMenuTableViewController(restaurant: Restaurant) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "MenuTableViewController") as? MenuTableViewController {
            vc.model = model
            vc.restaurant = restaurant
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func showInfoViewController() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as? InfoViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
 
}
