//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Maksim  on 24.05.2022.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    
    // MARK: - Private & Public property
    var place = Place()
    var delegate: MapViewControllerDelegate?
    var mapManager = MapManager()
    
    var incomeSegueIdentifier = ""
    private let annotationIdentifier = "annotationIdentifier"
    private var imageView = UIImageView()
    
    // Фокусируется на юзере при построенном маршруте - всегда возвращается в центр Юзера
    var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(
                for: mapView,
                   and: previousLocation) { (currentLocation) in
                       
                       self.previousLocation = currentLocation
                       
                       DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                           self.mapManager.showUserLocation(mapView: self.mapView)
                       }
                   }
        }
    }
    
    // MARK: - IBOutlet
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var mapPin: UIImageView!
    
    @IBOutlet var addressLabel: UILabel!
    
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var goButton: UIButton!
    
    // MARK: - Private method class
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = ""
        mapView.delegate = self
        goButton.isHidden = true
        setupMapView()
    }
    
    private func setupMapView() {
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIdentifier == "showPlace" {
            mapManager.setupPlaceMark(place: place, mapView: mapView)
            mapPin.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }

    // MARK: - IBAction
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    @IBAction func centerViewUserLocation() {
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func doneButtonPress() {
        delegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func goButtonPress() {
        mapManager.getDirections(for: mapView) { location in
            self.previousLocation = location
        }
    }
    
    deinit {
        print("deinit", MapViewController.self)
    }
    
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    // Кастомизация метки по определению ресторана
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            imageView.frame.size.width = 50
            imageView.frame.size.height = 50
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapManager.getCenterLocation(mapView)
        
        // Фокусировка метки юзера после построения маршрута
        if incomeSegueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: self.mapView)
            }
        }
                
        mapManager.geocode.reverseGeocodeLocation(center) { [self] (placeMarks, error) in
            if let error = error { print(error)
                return
            }
            
            guard let placeMarks = placeMarks else { return }
            let placeMark = placeMarks.first
            let streetName = placeMark?.thoroughfare
            let buildNumber = placeMark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildNumber != nil {
                    addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    addressLabel.text = "\(streetName!)"
                } else {
                    addressLabel.text = "Адрес не обнаружен"
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .black

        return renderer
    }
    
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapManager.checkLocationAuthorization(mapView: mapView, segueIdentifier: incomeSegueIdentifier)
    }
}
