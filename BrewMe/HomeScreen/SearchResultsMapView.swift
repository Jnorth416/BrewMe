//
//  SearchResultsMapView.swift
//  BrewMe
//
//  Created by Joshua North on 6/7/23.
//

import Foundation
import UIKit
import MapKit
import CoreData


class SearchResultsMapView: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate{
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Variables
    public var name: String = ""
    public var latitude: String = ""
    public var longitude: String = ""
    public var websiteURL: String = ""
    
    private var singleBrewery: SingleBrewery!
    private var fetchedResultsController: NSFetchedResultsController<SingleBrewery>!
    
    private let context = DataController.shared.viewContext
    let regionRadius: CLLocationDistance = 1000 // Adjust the desired radius in meters
    
    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        singleBreweryFetchRequest()
        mapView.delegate = self
        let initialLocation = CLLocation(latitude: Double(latitude)!, longitude: Double(longitude)!)
        centerMapOnLocation(location: initialLocation)
        placePin()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resetPin()
    }
    
    // MARK: IBAction
    @IBAction func favorite(_ sender: Any) {
        favoriteBreweries()
    }
    
    // MARK: MapView
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func placePin(){
        let annotation = AnnotationSubclass(coordinate: CLLocationCoordinate2D(latitude: Double(latitude) ?? 0.0, longitude: Double(longitude) ?? 0.0), title: name, subtitle: websiteURL)
        mapView.addAnnotation(annotation)
        annotation.title = name
        annotation.subtitle = websiteURL
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is MKUserLocation:
            return nil
        default:
            let reuseId = "pin"
            var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
            if pinView == nil {
                pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
                pinView!.canShowCallout = true
                pinView!.pinTintColor = .red
                let button = UIButton(type: .detailDisclosure)
                button.setImage(UIImage(systemName: "map.fill"), for: .normal)
                pinView!.rightCalloutAccessoryView = button
                pinView!.leftCalloutAccessoryView = UIButton(type: .detailDisclosure)
            } else {
                pinView!.annotation = annotation
            }
            return pinView
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.leftCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                let url = URL(string: toOpen)
                if let url = url {
                    app.open(url)
                } else {
                    print("Error")
                }
            }
        }
        if control == view.rightCalloutAccessoryView {
            let annotation = view.annotation as! AnnotationSubclass
            let destinationLocation = annotation.coordinate
            let placemark = MKPlacemark(coordinate: destinationLocation)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = annotation.title
            let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: options)
            print("tapped")
        }
    }
    
   
    // MARK: Fetch and Delete Request
    func singleBreweryFetchRequest() {
        let fetchRequest:NSFetchRequest<SingleBrewery> = SingleBrewery.fetchRequest()
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
    
    func resetPin() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "SingleBrewery")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
        } catch {
            print(error)
        }
    }
    
    // MARK: Favorites logic
    func favoriteBreweries() {
        let breweries = fetchedResultsController.fetchedObjects
        for dto in breweries! {
            if favoriteAlreadyExists(id: dto.id!) == false {
                let brewery = Favorite(context: context)
                brewery.id = dto.id
                brewery.name = dto.name
                brewery.street = dto.street
                brewery.city = dto.city
                brewery.state = dto.state
            }
        }
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
}




