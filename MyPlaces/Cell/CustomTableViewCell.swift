//
//  CustomTableViewCell.swift
//  MyPlaces
//
//  Created by Maksim  on 21.05.2022.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    
    @IBOutlet var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2
            imageOfPlace.clipsToBounds = true
        }
    }
    
    @IBOutlet var cosmosView: CosmosView! {
        didSet {
            cosmosView.settings.updateOnTouch = false
        }
    }
    
    
    func configure(with content: Place) {
        nameLabel.text = content.name
        locationLabel.text = content.location
        typeLabel.text = content.type
        
        imageOfPlace.image = UIImage(data: content.imageData!)
        
        // Отображения звезд на гланвом экране - данные берем с базы данных
        cosmosView.rating = content.rating
    }
    
    deinit {
        print("deinit", CustomTableViewCell.self)
    }

}
