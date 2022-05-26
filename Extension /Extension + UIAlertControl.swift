//
//  Extension + UIAlertControl.swift
//  MyPlaces
//
//  Created by Maksim  on 25.05.2022.
//


import UIKit

extension UIAlertController {
    
    static var alertControl = UIAlertController()
    
    func showAlert(title: String, message: String) {
       let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
       let okAction = UIAlertAction(title: "OK", style: .default)
       alert.addAction(okAction)
       present(alert, animated: true)
   }
    
}
