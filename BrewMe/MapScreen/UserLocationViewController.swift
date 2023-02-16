//
//  UserLocationViewController.swift
//  BrewMe
//
//  Created by Joshua North on 9/12/22.
//

import Foundation
import MapKit
import CoreLocation
import UIKit
import CoreData

class UserLocationViewController: UIViewController, CLLocationManagerDelegate, UIEditMenuInteractionDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Variables
    private var locationRequest = LocationManager.shared
    private var brewery: Brewery!
    private var fetchedResultsController: NSFetchedResultsController<Brewery>!
    private var annotations = [MKAnnotation]()
    private let breweryService = BreweryService()
    private let context = DataController.shared.viewContext
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationRequest.getUserLocation { location in
            self.render(location)
            print(location)
            self.mapView.showsUserLocation = true
        }
        if locationRequest.manager.authorizationStatus == .denied{
            render(Constants.defaultLocation)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mapView.showsUserLocation = true
        
    }
    
    // MARK: - User Location
    @IBAction func currentLocation(_ sender: Any) {
        locationRequest.getUserLocation { location in
            self.render(location)
            print(location)
            self.mapView.showsUserLocation = true
        }
        if locationRequest.manager.authorizationStatus == .denied{
            render(Constants.defaultLocation)
        }
    }
    
    func render(_ location: CLLocation) {
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        getBreweries(location: location)
    }
    
    // MARK: - Brewery get request
    func getBreweries(location: CLLocation) {
        breweryService.getBreweries(lat: location.coordinate.latitude, long:  location.coordinate.longitude) { [self] success, error in
            if error == nil {
                print("success")
                breweryFetchRequest()
                DispatchQueue.main.async {
                    self.placePins(location: location)
                }
            } else {
                userAlerts(message: "Unable to find Breweries ChecK Network Connection", title: "Error")
            }
        }
    }
    
    //MARK: - Brewery fetch request
    func breweryFetchRequest() {
        let fetchRequest:NSFetchRequest<Brewery> = Brewery.fetchRequest()
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
    
    //MARK: - Brewery pins
    func placePins(location: CLLocation) {
        self.mapView.removeAnnotations(annotations)
        resetPins()
        let breweries = fetchedResultsController.fetchedObjects
        for brewery in breweries! {
            let latitude = Double(brewery.latitude ?? "")
            let longitude = Double(brewery.longitude ?? "")
            let websiteURL = brewery.websiteURL
            let breweryName = brewery.name
            let annotation = AnnotationSubclass(coordinate: CLLocationCoordinate2D(latitude: latitude ?? 0.0 , longitude: longitude ?? 0.0), title: breweryName!, subtitle: websiteURL ?? "")
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude ?? 0.0 , longitude: longitude ?? 0.0)
            annotation.title = breweryName
            annotation.subtitle = websiteURL
            DispatchQueue.main.async {
                self.mapView.addAnnotation(annotation)
                self.annotations.append(annotation)
            }
        }
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func resetPins() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Brewery")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
        } catch {
            print(error)
        }
    }
}

// MARK: - MapView
extension UserLocationViewController: MKMapViewDelegate {
    
    override var canBecomeFirstResponder: Bool {
        return true
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
                button.setImage(UIImage(systemName: "star.fill"), for: .normal)
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
            print("tapped")
            favoriteBreweries(annotation: annotation)
        }
    }
    
    //MARK: - Favorite breweries
    func favoriteBreweries(annotation: MKAnnotation) {
        let breweries = fetchedResultsController.fetchedObjects
        for dto in breweries! {
            if annotation.title == dto.name && favoriteAlreadyExists(id: dto.id!) == false {
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

//MARK: - User alerts
extension UIViewController {
    func userAlerts(message: String, title: String) {
        let alertVc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVc.addAction(UIAlertAction(title: "Ok", style: .default,handler: nil))
        DispatchQueue.main.async{
            self.present(alertVc, animated: true, completion: nil)
        }
    }
}





