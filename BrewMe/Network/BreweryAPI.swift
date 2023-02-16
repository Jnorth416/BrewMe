//
//  BreweryAPI.swift
//  BrewMe
//
//  Created by Joshua North on 9/14/22.
//

import Foundation

class BreweryAPI {
    
    class func taskForGetRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping ([ResponseType]?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            print(String(data: data, encoding: .utf8)!)
            do {
                let responseObject = try decoder.decode([ResponseType].self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject,nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil,error)
                }
                return
            }
        }
        task.resume()
    }
}
