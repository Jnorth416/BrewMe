//
//  CollectionViewCell.swift
//  BrewMe
//
//  Created by Joshua North on 1/5/23.
//

import Foundation
import UIKit


class CollectionViewCell: UICollectionViewCell {
    
    static let indentifier = "CollectionViewCell"

    @IBOutlet weak var BreweryImageView: UIImageView!
    @IBOutlet weak var BreweryLabel: UILabel!
    
    override func awakeFromNib() {
           super.awakeFromNib()
           
           // Increase font size
           BreweryLabel.font = UIFont.boldSystemFont(ofSize: 30.0)
           
           // Choose appropriate font color
          BreweryLabel.textColor = UIColor.white
           
           // Apply text shadow
           BreweryLabel.shadowColor = UIColor.black
           BreweryLabel.shadowOffset = CGSize(width: 1.0, height: 1.0)
           
           // Apply a semi-transparent background
           let backgroundView = UIView()
           backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
           BreweryLabel.addSubview(backgroundView)
           BreweryLabel.sendSubviewToBack(backgroundView)
   }
}
    
    
