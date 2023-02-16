//
//  BreweryTypeTableViewController.swift
//  BrewMe
//
//  Created by Joshua North on 10/12/22.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

class BreweryTypeViewController: UITableViewController {
    
    //MARK: - Variables
    var breweryType: String = ""
    private var locationManager = LocationManager.shared
    private var brewery: Brewery!
    private var context = DataController.shared.viewContext
    private lazy var breweryService = BreweryService()
    
    //MARK: - IBOutlet
    @IBOutlet var breweryTableView: UITableView!
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if  locationManager.manager.authorizationStatus == .denied {
            breweryService.typesOfBreweries(breweryType: breweryType, lat: Constants.defaultLocation.coordinate.latitude, long: Constants.defaultLocation.coordinate.longitude) { [self] response, error in
                if error == nil {
                    BreweryData.sharedInstance().breweries = response!
                    DispatchQueue.main.async{
                        self.breweryTableView.reloadData()
                    }
                } else {
                    userAlerts(message: "\(error!.localizedDescription)", title: "Error")
                }
                
            }
        } else {
            locationManager.getUserLocation { location in
                self.breweryService.typesOfBreweries(breweryType: self.breweryType, lat: location.coordinate.latitude, long: location.coordinate.longitude) { [self] response, error in
                    if error == nil{
                        BreweryData.sharedInstance().breweries = response!
                        DispatchQueue.main.async {
                            self.breweryTableView.reloadData()
                        }
                    } else {
                        
                        userAlerts(message: "\(error!.localizedDescription)", title: "Error")
                    }
                }
            }
        }
    }
    
    //MARK: - TableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BreweryTypeTableView", for: indexPath)
        let breweries = BreweryData.sharedInstance().breweries[indexPath.row]
        cell.textLabel?.text = breweries.name
        cell.detailTextLabel?.text = (breweries.street ?? "") + " " + (breweries.city ?? "") + " " + (breweries.state ?? "")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let breweries = BreweryData.sharedInstance().breweries[indexPath.row]
        let app = UIApplication.shared
        if let toOpen = breweries.websiteURL {
            let url = URL(string: toOpen)
            if let url = url {
                app.open(url)
            } else {
                print("Error")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BreweryData.sharedInstance().breweries.count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //MARK: - Favorites
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favoriteAction = UIContextualAction(style: .normal, title: "Favorite") { _,_,_  in
            print("Favorite")
            let brewery = Favorite(context: DataController.shared.viewContext)
            let breweries = BreweryData.sharedInstance().breweries[indexPath.row]
            if self.favoriteAlreadyExists(id: breweries.id!) == false {
                brewery.id = breweries.id
                brewery.state = breweries.state
                brewery.city = breweries.city
                brewery.street = breweries.street
                brewery.name = breweries.name
                brewery.websiteURL = breweries.websiteURL
            }
        }
        favoriteAction.backgroundColor = .systemGreen
        let swipe = UISwipeActionsConfiguration(actions: [favoriteAction])
        return swipe
    }
    
    func favoriteAlreadyExists(id: String) -> Bool {
        let request: NSFetchRequest<Favorite> = Favorite.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        let results = try? context.fetch(request)
        var alreadyExists = false
        for favorite in results! {
            if favorite.id == id {
                alreadyExists = true
            } else {
                alreadyExists = false
            }
        }
        return alreadyExists
    }
    
    //MARK: - Brewery get request
    func breweryTypeLocation(location: CLLocation) {
        breweryService.typesOfBreweries(breweryType: breweryType, lat: location.coordinate.latitude, long: location.coordinate.longitude) { response, error in
            if error == nil {
                print("success")
            }
        }
    }
}
