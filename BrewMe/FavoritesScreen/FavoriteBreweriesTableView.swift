//
//  FavoriteBreweriesTableView.swift
//  BrewMe
//
//  Created by Joshua North on 11/8/22.
//

import Foundation
import UIKit
import CoreData

class FavoriteBreweriesTableView: UITableViewController, NSFetchedResultsControllerDelegate {
   
    var fetchedResultsController: NSFetchedResultsController<Favorite>!

    // MARK: - Life Cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupFetchedResultsController()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFetchedResultsController()
    }

    // MARK: - TableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let brewery = fetchedResultsController.object(at: indexPath)
        let app = UIApplication.shared
        if let toOpen = brewery.websiteURL {
            let url = URL(string: toOpen)
            if let url = url {
                app.open(url)
            }else{
                print("Error")
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteBreweries", for: indexPath)
        let breweryFavorite = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = breweryFavorite.name
        cell.detailTextLabel?.text = (breweryFavorite.street ?? "") + " " + (breweryFavorite.city ?? "") + " " + (breweryFavorite.state ?? "")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteBrewery(at: indexPath)
        default: () // Unsupported
        }
    }
    
    // MARK: - FetchRequest
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Favorite> = Favorite.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("\(error.localizedDescription)")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            break
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func deleteBrewery(at indexPath: IndexPath) {
        let breweryToDelete = fetchedResultsController.object(at: indexPath)
        DataController.shared.viewContext.delete(breweryToDelete)
        try? DataController.shared.viewContext.save()
    }
}
