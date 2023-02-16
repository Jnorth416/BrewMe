//
//  BreweryService.swift
//  BrewMe
//
//  Created by Joshua North on 1/4/23.
//

import Foundation

class BreweryService {
    
    private lazy var apiService = BreweryAPI()
    private let breweryRepo = BreweryRepository()
    
    // MARK: - Query Parameters
    enum Endpoints{
        case breweryRequest(Double, Double)
        case breweryType(String, Double, Double)
        
        var stringValue: String{
            switch self{
            case let .breweryRequest(latitude, longitude):
                return Constants.baseURL + "?by_dist=\(latitude),\(longitude)&per_page=50"
            case let .breweryType(breweryType, latitude, longitude):
                return Constants.baseURL + "?by_dist=\(latitude),\(longitude)&by_type=\(breweryType)&per_page=50"
            }
        }
        
        var url: URL{
            return URL(string: stringValue)!
        }
    }
    
    // MARK: - Get requests
    func getBreweries(lat: Double, long: Double, completion: @escaping(Bool,Error?) -> Void) {
        BreweryAPI.taskForGetRequest(url: Endpoints.breweryRequest(lat, long).url, responseType: BreweryResponse.self) { response, error in
            if let error = error {
                completion(false,error)
            } else {
                if let response = response {
                    do {
                        try self.breweryRepo.saveBreweryDTO(BreweryDTOs: response)
                    } catch{
                        print(error)
                    }
                    completion(true,nil)
                } else {
                    completion(false,error)
                }
            }
        }
    }
    
    func typesOfBreweries(breweryType: String, lat: Double, long: Double, completion: @escaping([BreweryResponse]?,Error?) -> Void) {
        BreweryAPI.taskForGetRequest(url: Endpoints.breweryType(breweryType, lat, long).url, responseType: BreweryResponse.self) { response, error in
            if let response = response {
                completion(response,nil)
            } else {
                completion([],error)
            }
        }
    }
}
