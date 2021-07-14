//
//  Model.swift
//  HappyHourInterfaceMVP
//
//  Created by Nicholas Raspino on 7/21/19.
//  Copyright © 2019 Nicholas Raspino. All rights reserved.
//

import UIKit
import CloudKit

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

enum Filter {
    case all
    case allFavorites
    case current
    case currentFavorites
    case future
    case futureFavorites
}

enum FoodOrDrink {
    case food
    case drink
}

class Model: NSObject, HappyHourDataSource {
    
    // MARK: - Properties

    var restaurantsToShow: [Restaurant] = []
    var restaurantFilter = Filter.all
    var date: Date?
    var searchedText: String?
    var favorites: [String] = [] {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(self.favorites, forKey: "favorites")
            updateRestaurantsToShow(post: true)
        }
    }
    var foodOrDrinkFilter = FoodOrDrink.food
    
    private var restaurants: [Restaurant] = []
    private var currentlyCheckingCloud = false
    private var dateOfMostRecentCloudUpdate: Date? {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(self.dateOfMostRecentCloudUpdate!, forKey: "dateOfUpdate")
        }
    }
    private var newDataCreationDate: Date?
    private var dataCreationDate: Date? {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(self.dataCreationDate!, forKey: "dataCreationDate")
        }
    }
    private var searchedRestaurants: [Restaurant]?
    
    // MARK: - Public Methods
    
    func updateIfNecessary() {
        if restaurantFilter == .current || restaurantFilter == .currentFavorites {
            let calendar = Calendar.current
            let oldHourComponent = calendar.component(.hour, from: date!)
            let oldMinuteComponent = calendar.component(.minute, from: date!)
            var oldDouble = Double(oldHourComponent)
            if oldMinuteComponent >= 30 {
                oldDouble += 0.5
            }
            let newDate = Date()
            let newHourComponent = calendar.component(.hour, from: newDate)
            let newMinuteComponent = calendar.component(.minute, from: newDate)
            var newDouble = Double(newHourComponent)
            if newMinuteComponent >= 30 {
                newDouble += 0.5
            }
            if newDouble != oldDouble {
                updateRestaurantsToShow(post: true)
            }
        }
        if currentlyCheckingCloud == false {
            if dateOfMostRecentCloudUpdate != nil {
                let currentDate = Date()
                let secondsSinceLastUpdate = currentDate.timeIntervalSince(dateOfMostRecentCloudUpdate!)
                if secondsSinceLastUpdate > 3600 {
                    getDataFromCloud()
                }
            } else {
                getDataFromCloud()
            }
        }
    }
    
    func showAllRestaurants(favoritesOnly: Bool) {
        restaurantsToShow = restaurants
        date = Date()
        updateRestaurantDayOfWeek(date: date!)
        if favoritesOnly == true {
            restaurantFilter = .allFavorites
            filterNonFavorites()
        } else {
            restaurantFilter = .all
        }
    }
    
    func showCurrentRestaurants(favoritesOnly: Bool) {
        date = Date()
        filterForDate(date: date!)
        updateRestaurantDayOfWeek(date: date!)
        if favoritesOnly == true {
            restaurantFilter = .currentFavorites
            filterNonFavorites()
        } else {
            restaurantFilter = .current
        }
    }
    
    func showFutureRestaurants(futureDate: Date, favoritesOnly: Bool) {
        date = futureDate
        filterForDate(date: date!)
        updateRestaurantDayOfWeek(date: date!)
        if favoritesOnly == true {
            restaurantFilter = .futureFavorites
            filterNonFavorites()
        } else {
            restaurantFilter = .future
        }
    }
    
    func filterForText(text: String) {
        updateRestaurantsToShow(post: false)
        searchedText = text
        searchedRestaurants = []
        let components = text.split(separator: " ")
        if components.count > 0 {
            let string = components[0]
            for restaurant in restaurantsToShow {
                if let _ = restaurant.title?.range(of: string, options: .caseInsensitive) {
                    searchedRestaurants!.append(restaurant)
                }
                for item in restaurant.foodMenuItems {
                    if let _ = item.title?.range(of: string, options: .caseInsensitive) {
                        searchedRestaurants!.append(restaurant)
                    }
                }
                for item in restaurant.drinkMenuItems {
                    if let _ = item.title?.range(of: string, options: .caseInsensitive) {
                        searchedRestaurants!.append(restaurant)
                    }
                }
            }
        }
        if components.count > 1 {
            for i in 1..<components.count {
                let string = components[i]
                var moreRestaurants: [Restaurant] = []
                for restaurant in searchedRestaurants! {
                    if let _ = restaurant.title?.range(of: string, options: .caseInsensitive) {
                        moreRestaurants.append(restaurant)
                    }
                    for item in restaurant.foodMenuItems {
                        if let _ = item.title?.range(of: string, options: .caseInsensitive) {
                            moreRestaurants.append(restaurant)
                        }
                    }
                    for item in restaurant.drinkMenuItems {
                        if let _ = item.title?.range(of: string, options: .caseInsensitive) {
                            moreRestaurants.append(restaurant)
                        }
                    }
                    if moreRestaurants.contains(restaurant) == false {
                        if let index = searchedRestaurants!.firstIndex(of: restaurant) {
                            searchedRestaurants!.remove(at: index)
                        }
                    }
                }
            }
        }
        if text != "" {
            restaurantsToShow = searchedRestaurants!
            postNotification()
        } else {
            searchedText = nil
            updateRestaurantsToShow(post: true)
        }
    }
    
    // MARK: - Private Methods
    
    private func getDataFromCloud() {
        currentlyCheckingCloud = true
        let pred = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        let query = CKQuery(recordType: "Json", predicate: pred)
        query.sortDescriptors = [sort]
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 1
        var recordData: Data?
        operation.recordFetchedBlock = { [unowned self] record in
            recordData = record["data"]
            self.newDataCreationDate = record.creationDate
        }
        operation.queryCompletionBlock = { [unowned self] (cursor, error) in
            DispatchQueue.main.async {
                if error == nil {
                    self.currentlyCheckingCloud = false
                    self.dateOfMostRecentCloudUpdate = Date()
                    if self.newDataCreationDate == self.dataCreationDate {
                        // do nothing
                    } else {
                        self.dataCreationDate = self.newDataCreationDate
                        self.updateJsonWithDataFromCloud(newData: recordData)
                    }
                } else {
                    self.currentlyCheckingCloud = false
                }
            }
        }
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    private func updateJsonWithDataFromCloud(newData: Data?) {
        if let data = newData {
            do {
                let decoder = JSONDecoder()
                restaurants = try decoder.decode([Restaurant].self, from: data)
                let defaults = UserDefaults.standard
                defaults.set(data, forKey: "savedData")
                updateRestaurantsToShow(post: true)
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateRestaurantsToShow(post: Bool) {
        switch restaurantFilter {
        case .all:
            showAllRestaurants(favoritesOnly: false)
        case .allFavorites:
            showAllRestaurants(favoritesOnly: true)
        case .current:
            showCurrentRestaurants(favoritesOnly: false)
        case .currentFavorites:
            showCurrentRestaurants(favoritesOnly: true)
        case .future:
            if date != nil {
                showFutureRestaurants(futureDate: date!, favoritesOnly: false)
            }
        case .futureFavorites:
            if date != nil {
                showFutureRestaurants(futureDate: date!, favoritesOnly: true)
            }
        }
        if post == true {
            postNotification()
        }
    }
    
    private func filterForDate(date: Date) {
        restaurantsToShow = []
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: date)
        var hour = calendar.component(.hour, from: date) * 2
        let min = calendar.component(.minute, from: date)
        if min >= 30 {
            hour += 1
        }
        let hourFilter = dayOfWeek * 100 + hour
        for restaurant in restaurants {
            if restaurant.happyHourHours.contains(hourFilter) {
                restaurantsToShow.append(restaurant)
            }
        }
    }
    
    private func filterNonFavorites() {
        for restaurant in restaurantsToShow {
            if !favorites.contains(restaurant.id!) {
                if let index = restaurantsToShow.firstIndex(of: restaurant) {
                    restaurantsToShow.remove(at: index)
                }
            }
        }
    }
    
    private func updateRestaurantDayOfWeek(date: Date) {
        let calendar = Calendar.current
        var dayOfWeek = calendar.component(.weekday, from: date)
        let hour = calendar.component(.hour, from: date)
        if hour <= 2 {
            if dayOfWeek == 1 {
                dayOfWeek = 7
            } else {
                dayOfWeek -= 1
            }
        }
        for restaurant in restaurants {
            restaurant.setHours(day: dayOfWeek)
        }
    }
    
    private func postNotification() {
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("RestaurantsUpdated"), object: nil)
    }
    
    private func postCloudNotification() {
        let nc = NotificationCenter.default
        nc.post(name: Notification.Name("CloudUnavailable"), object: nil)
    }
    
    // MARK: - Init
    
    override init() {
        super.init()
        let defaults = UserDefaults.standard
        if let data = defaults.object(forKey: "savedData") as? Data {
            let decoder = JSONDecoder()
            do {
                restaurants = try decoder.decode([Restaurant].self, from: data)
                if let savedFavorites = defaults.object(forKey: "favorites") as? [String] {
                    favorites = savedFavorites
                }
                if let dateOfUpdate = defaults.object(forKey: "dateOfUpdate") as? Date {
                    dateOfMostRecentCloudUpdate = dateOfUpdate
                }
                if let dateOfDataCreation = defaults.object(forKey: "dataCreationDate") as? Date {
                    dataCreationDate = dateOfDataCreation
                }
            } catch {
            
            }
        }
    }
}
