//
//  SearchResultsViewController.swift
//  BrewMe
//
//  Created by Joshua North on 6/7/23.
//

import Foundation
import UIKit

class SearchResultsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    // MARK: Variables
    private lazy var breweryService = BreweryService()
    private var breweries: [BreweryResponse] = []
    
    // MARK: TableView Init
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: TableView updating logic
    public func update(with breweries: [BreweryResponse]){
        self.breweries = breweries
        tableView.reloadData()
    }
    
    // MARK: TableView for AutoComplete
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return breweries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = breweries[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        breweryService.getSingleBrewery(breweryId: breweries[indexPath.row].id!) { response, error in
            if let response = response {
                print(response)
                let searchResultsMapView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchResultsMapView") as! SearchResultsMapView
                searchResultsMapView.latitude = response.latitude
                searchResultsMapView.longitude  = response.longitude
                searchResultsMapView.websiteURL = response.websiteURL ?? "No Website Found"
                searchResultsMapView.name = response.name!
                self.present(searchResultsMapView, animated: true, completion: nil)
                
                
            } else {
                print("failed")
                self.showAlert(title: "Error", message: "Unable to Find Location")
            }
        }
        
    }
}

// MARK: Alert Controller
extension UIViewController {
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
