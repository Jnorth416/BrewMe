//
//  SearchLocationViewController.swift
//  BrewMe
//
//  Created by Joshua North on 10/3/22.
//

import Foundation
import UIKit

class SearchLocationViewController: UIViewController, UISearchResultsUpdating {
   
    
    
    private lazy var breweryService = BreweryService()
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text, !text.trimmingCharacters(in: .whitespaces).isEmpty, let searchResults = searchController.searchResultsController as? SearchResultsViewController else {
            return
        }
        breweryService.breweryAutoComplete(searchQuery: text) { response, error in
            print(text)
            DispatchQueue.main.async{
                searchResults.update(with: response)
            }
        }
    }
    
    let searchController = UISearchController(searchResultsController: SearchResultsViewController())
    
    
    // MARK: - IBOutlets
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchTextField: UITextField!
    
    // MARK: - Constants
    private let itemsPerRow: CGFloat = 2
    private let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    private let breweryLabels = ["micro","nano","regional","brewpub","large","contract"]
    private let breweryImages: [UIImage] = [
        UIImage(named: "image 2")!,
        UIImage(named: "image 3")!,
        UIImage(named: "image 4")!,
        UIImage(named: "image 5")!,
        UIImage(named: "image 6")!,
        UIImage(named: "image 7")!,
    ]
    
    public var breweryType: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.indentifier)
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        
    }
    
    //MARK: - Search field
    @IBAction func searchButton(_ sender: Any) {
        self.performSegue(withIdentifier: "BreweryTableView", sender: self)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - CollectionView
extension SearchLocationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        breweryType = breweryLabels[indexPath.item]
        self.performSegue(withIdentifier: "BreweryTableView", sender: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return breweryImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        cell.BreweryLabel.text = breweryLabels[indexPath.item]
        cell.BreweryImageView.image = breweryImages[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
    //MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "BreweryTableView" {
            let BreweryTypeTableVC = segue.destination as? BreweryTypeViewController
            BreweryTypeTableVC?.breweryType = breweryType
        }
    }
}
