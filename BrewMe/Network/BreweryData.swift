//
//  BreweryLocation.swift
//  BrewMe
//
//  Created by Joshua North on 9/14/22.
//

import Foundation

class BreweryData: NSObject {
    var breweries = [BreweryResponse]()
    class func sharedInstance()-> BreweryData{
        struct Singleton{
            static var sharedInstance = BreweryData()
        }
        return Singleton.sharedInstance
    }
}
