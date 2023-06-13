//
//  BreweryRepository.swift
//  BrewMe
//
//  Created by Joshua North on 1/4/23.
//

import Foundation
import CoreData

class BreweryRepository {

    private let context = DataController.shared.persistentContainer.viewContext
    
    func saveBreweryDTO(BreweryDTOs: [BreweryResponse]) throws {
        for dto in BreweryDTOs {
            let brewery = getBrewery(id: dto.id!) ?? Brewery(context: context)
            brewery.id = dto.id
            brewery.name = dto.name
            brewery.state = dto.state
            brewery.city = dto.city
            brewery.street = dto.street
            brewery.isFavorite = false
            brewery.latitude = dto.latitude
            brewery.longitude = dto.longitude
            brewery.websiteURL = dto.websiteURL
        }
        try context.save()
    }
    
    func saveSingleBreweryDTO(BreweryDTO: SingleBreweryResponse) throws {
        let dto = BreweryDTO
        let brewery = getSingleBrewery(id: dto.id) ?? SingleBrewery(context: context)
        brewery.id = dto.id
        brewery.name = dto.name
        brewery.state = dto.state
        brewery.city = dto.city
        brewery.street = dto.street
        brewery.isFavorite = false
        brewery.latitude = dto.latitude
        brewery.longitude = dto.longitude
        brewery.websiteURL = dto.websiteURL
        
        try context.save()
    }
    
    func getBrewery(id: String) -> Brewery? {
        let request: NSFetchRequest<Brewery> = Brewery.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        let results = try? context.fetch(request)
        return results?.first
    }
    
    func getSingleBrewery(id: String) -> SingleBrewery? {
        let request: NSFetchRequest<SingleBrewery> = SingleBrewery.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        let results = try? context.fetch(request)
        return results?.first
    }
}
