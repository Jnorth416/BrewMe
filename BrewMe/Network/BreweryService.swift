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
        case breweryAutoComplete(String)
        case singleBreweryId(String)
        
        var stringValue: String{
            switch self{
            case let .breweryRequest(latitude, longitude):
                return Constants.baseURL + "?by_dist=\(latitude),\(longitude)&per_page=50"
            case let .breweryType(breweryType, latitude, longitude):
                return Constants.baseURL + "?by_dist=\(latitude),\(longitude)&by_type=\(breweryType)&per_page=50"
            case let .breweryAutoComplete(breweryAutoComplete):
                return Constants.baseURL + "/autocomplete?query=\(breweryAutoComplete)"
            case let .singleBreweryId(singleBreweryId):
                return Constants.baseURL + "/\(singleBreweryId)"
            }
        }
        
        var url: URL{
            return URL(string: stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
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
    
    func breweryAutoComplete(searchQuery: String, completion: @escaping([BreweryResponse],Error?) -> Void) {
        BreweryAPI.taskForGetRequest(url: Endpoints.breweryAutoComplete(searchQuery).url, responseType: BreweryResponse.self) { response, error in
            if let response = response {
                completion(response,nil)
            } else {
                completion([],error)
            }
        }
    }
    
    func getSingleBrewery(breweryId: String, completion: @escaping(SingleBreweryResponse?,Error?) -> Void) {
        BreweryAPI.taskForSingleBreweryGetRequest(url: Endpoints.singleBreweryId(breweryId).url, responseType: SingleBreweryResponse.self) { response, error in
            if let response = response {
                do {
                    try self.breweryRepo.saveSingleBreweryDTO(BreweryDTO: response)
                } catch{
                    print(error)
                }
                
                completion(response,nil)
            } else if let error = error {
                print(error)
                completion(nil,error)
            }
        }
    }
}
