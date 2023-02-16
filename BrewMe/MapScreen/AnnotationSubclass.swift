//
//  AnnotationSubclass.swift
//  BrewMe
//
//  Created by Joshua North on 1/2/23.
//

import Foundation
import MapKit

class AnnotationSubclass: NSObject, MKAnnotation {
   
    @objc dynamic var coordinate: CLLocationCoordinate2D
    
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}
