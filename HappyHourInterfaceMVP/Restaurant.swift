//
//  Restaurant.swift
//  HappyHourInterfaceMVP
//
//  Created by Nicholas Raspino on 7/21/19.
//  Copyright © 2019 Nicholas Raspino. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Contacts

class Restaurant: NSObject, MKAnnotation, Codable {
    
    // MARK: - Properties

    var id: String?
    var title: String?
    var address: String?
    var website: String?
    var phoneNumber: String?
    var additionalInfo: String?
    var mondayHours: String?
    var tuesdayHours: String?
    var wednesdayHours: String?
    var thursdayHours: String?
    var fridayHours: String?
    var saturdayHours: String?
    var sundayHours: String?
    var happyHourHours: [Int] = []
    var foodMenuItems: [MenuItem] = []
    var drinkMenuItems: [MenuItem] = []
    var latitude: Double?
    var longitude: Double?
    
    var coordinate: CLLocationCoordinate2D {
        if latitude != nil && longitude != nil {
            return CLLocationCoordinate2DMake(latitude!, longitude!)
        } else {
            return CLLocationCoordinate2DMake(29.4241, 98.4936)
        }
    }
    
    var hours: String?
    
    // MARK: - Methods

    func setHours(day: Int) {
        let defualtHours = "None today"
        switch day {
        case 1:
            hours = sundayHours ?? defualtHours
        case 2:
            hours = mondayHours ?? defualtHours
        case 3:
            hours = tuesdayHours ?? defualtHours
        case 4:
            hours = wednesdayHours ?? defualtHours
        case 5:
            hours = thursdayHours ?? defualtHours
        case 6:
            hours = fridayHours ?? defualtHours
        case 7:
            hours = saturdayHours ?? defualtHours
        default:
            hours = defualtHours
        }
    }
    
    // MARK: - MKAnnotation
    
    var subtitle: String? {
        return hours
    }
    
    func mapItem() -> MKMapItem {
        let addressDict = [CNPostalAddressStreetKey: subtitle!]
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: addressDict)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        return mapItem
    }
}
