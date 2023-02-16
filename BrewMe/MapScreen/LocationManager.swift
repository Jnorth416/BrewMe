//
//  LocationManager.swift
//  BrewMe
//
//  Created by Joshua North on 9/12/22.
//

import Foundation
import CoreLocation
import UIKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    
    let manager = CLLocationManager()
    var completion: ((CLLocation) -> Void)?
  
    public func getUserLocation(completion: @escaping((CLLocation) -> Void) ){
        self.completion = completion
        manager.requestWhenInUseAuthorization()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.delegate = self
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if CLLocationManager.locationServicesEnabled() {
            switch manager.authorizationStatus {
            case .notDetermined, .restricted, .denied:
                print("no bueno")
            case .authorizedAlways, .authorizedWhenInUse:
                print("access")
                if let location = locations.first {
                    manager.stopUpdatingLocation()
                   completion?(location)
                }
            default:
                break
            }
        }
    }
}
