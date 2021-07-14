//
//  ViewController.swift
//  HappyHourInterfaceMVP
//
//  Created by Nicholas Raspino on 7/21/19.
//  Copyright © 2019 Nicholas Raspino. All rights reserved.
//

import UIKit
import CoreLocation
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

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchResultsUpdating {
    
    // MARK: - Properties
    
    private var model: Model!
    private var locationManager: CLLocationManager!
    private let centerOfDowntown = CLLocation(latitude: 29.4251, longitude: -98.4905)
    private var regionRadius: CLLocationDistance = 2800
    private let smallestRadius: CLLocationDistance = 1000
    private var lastTimeMapViewWasOnScreen: Date?
    private var search: UISearchController?
    private weak var locationButton: UIButton!
    
    // MARK: - Interface Builder
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: - View Controller Lifecycle
    
    override func loadView() {
        super.loadView()
        createLocationButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpModel()
        registerForUpdates()
        setUpNavigationBar()
        setUpMapView()
        customizeLocationButton()
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        search!.searchBar.text = model.searchedText
        updateZoomIfNecessary()
        model.updateIfNecessary()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        search!.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Methods
    
    private func createLocationButton() {
        let locationButton = UIButton(type: .roundedRect)
        locationButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(locationButton)
        NSLayoutConstraint.activate([
            locationButton.widthAnchor.constraint(equalToConstant: 50),
            locationButton.heightAnchor.constraint(equalToConstant: 50),
            locationButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
            locationButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
        self.locationButton = locationButton
    }
    
    private func setUpModel() {
        let navigationController = self.tabBarController?.viewControllers?[0] as? UINavigationController
        let firstViewController = navigationController?.viewControllers[0] as? RestaurantsTableViewController
        model = firstViewController?.model
    }
    
    private func registerForUpdates() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(restaurantsUpdated), name: Notification.Name("RestaurantsUpdated"), object: nil)
    }
    
    private func setUpNavigationBar() {
        title = "Map"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "FilterIcon"), style: .plain, target: self, action: #selector(showFilterScreen))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "InfoIcon"), style: .plain, target: self, action: #selector(showInfoViewController))
        search = UISearchController(searchResultsController: nil)
        search!.searchResultsUpdater = self
        search!.obscuresBackgroundDuringPresentation = false
        search!.searchBar.placeholder = "Type something here to search"
        navigationItem.searchController = search
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    @objc private func restaurantsUpdated() {
        updateMapView()
    }
    
    private func setUpMapView() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
    }
    
    private func customizeLocationButton() {
        locationButton.setImage(UIImage(named: "LocationIcon"), for: .normal)
        locationButton.backgroundColor = UIColor(white: 1, alpha: 1)
        locationButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        locationButton.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        locationButton.layer.shadowOpacity = 1.0
        locationButton.layer.shadowRadius = 0.0
        locationButton.layer.masksToBounds = false
        locationButton.layer.cornerRadius = 5
        locationButton.addTarget(self, action: #selector(zoomLocation), for: .touchUpInside)
    }
    
    @objc private func zoomLocation() {
        if let myLocation = locationManager?.location {
            let closestRestaurantRadius = calculateClosestRestaurant(myLocation: myLocation)
            if closestRestaurantRadius < smallestRadius {
                centerMapOnLocation(location: myLocation, radius: smallestRadius)
            } else {
                centerMapOnLocation(location: centerOfDowntown, radius: regionRadius)
            }
        } else {
            centerMapOnLocation(location: centerOfDowntown, radius: regionRadius)
        }
    }
    
    private func calculateClosestRestaurant(myLocation: CLLocation) -> CLLocationDistance {
        var shortestDistance: CLLocationDistance = smallestRadius
        for restaurant in model.restaurantsToShow {
            if restaurant.latitude != nil && restaurant.longitude != nil {
                let restaurantDistanceFromMe = myLocation.distance(from: CLLocation(latitude: restaurant.latitude!, longitude: restaurant.longitude!))
                if restaurantDistanceFromMe < shortestDistance {
                    shortestDistance = restaurantDistanceFromMe
                }
            }
        }
        return shortestDistance
    }
    
    private func centerMapOnLocation(location: CLLocation, radius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: radius, longitudinalMeters: radius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func updateMapView() {
        mapView.removeAnnotations(mapView.annotations)
        getDataForAnnotations()
        mapView.showsUserLocation = true
    }
    
    private func updateZoomIfNecessary() {
        let currentDate = Date()
        if lastTimeMapViewWasOnScreen == nil {
            lastTimeMapViewWasOnScreen = currentDate
            zoomLocation()
        } else {
            let timeSinceMapViewWasOnScreen = currentDate.timeIntervalSince(lastTimeMapViewWasOnScreen!)
            if timeSinceMapViewWasOnScreen > 120 {
                lastTimeMapViewWasOnScreen = currentDate
                zoomLocation()
            } else {
                lastTimeMapViewWasOnScreen = currentDate
            }
        }
    }
    
    private func getDataForAnnotations() {
        if model.restaurantsToShow.count > 0 {
            for i in 0...model.restaurantsToShow.count - 1 {
                let annotation = model.restaurantsToShow[i]
                mapView.addAnnotation(annotation)
            }
        }
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is Restaurant else { return nil }
        let identifier = "Restaurant"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as! MKMarkerAnnotationView?
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        annotationView?.annotation = annotation
        annotationView?.markerTintColor = .orange
        annotationView?.glyphImage = UIImage(named: "RestaurantIcon")
        annotationView?.canShowCallout = false
        annotationView?.displayPriority = .required
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let restaurant = view.annotation as? Restaurant else { return }
        showMenuTableViewController(restaurant: restaurant)
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

