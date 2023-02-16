//
//  BreweryResponse.swift
//  BrewMe
//
//  Created by Joshua North on 9/14/22.
//

import Foundation
    
struct BreweryResponse: Codable {
    let id: String?
    let name: String?
    let breweryType: String?
    let street: String?
    let addressTwo: String?
    let addressThree: String?
    let city: String?
    let state: String?
    let countyProvince: String?
    let postalCode: String?
    let country: String?
    let latitude: String?
    let longitude: String?
    let phone: String?
    let websiteURL: String?
    let updatedAt: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case breweryType = "brewery_type"
        case street
        case addressTwo = "address_2"
        case addressThree = "address_3"
        case city
        case state
        case countyProvince = "county_province"
        case postalCode = "postal_code"
        case country
        case latitude
        case longitude
        case phone
        case websiteURL = "website_url"
        case updatedAt = "updated_at"
        case createdAt = "created_at"
    }
}

