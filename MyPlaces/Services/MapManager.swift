//
//  MapManager.swift
//  MyPlaces
//
//  Created by Maksim  on 25.05.2022.
//

import UIKit
import MapKit

class MapManager {
    
    var geocode = CLGeocoder()
    var locationManager = CLLocationManager()
    
    private var annotation = MKPointAnnotation()
    private var placeCoordinate: CLLocationCoordinate2D?
    private var directionsArray: [MKDirections] = []
    
   // Создания маркера заведения
     func setupPlaceMark(place: Place, mapView: MKMapView) {
        guard let location = place.location else { return }
        
        geocode.geocodeAddressString(location) { [self] (placeMarks, error) in
            if let error = error { print(error)
                return }
    
            guard let placeMarks = placeMarks else { return }
            let placeMark = placeMarks.first
            
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placeMarkLocation = placeMark?.location else { return }
            annotation.coordinate = placeMarkLocation.coordinate
            placeCoordinate = placeMarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    // Проверка доступности сервисов геолокации
     func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> Void) {
        if CLLocationManager.locationServicesEnabled() {
            // Если геолокация на айфоне включена
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthorization(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIAlertController.alertControl.showAlert(title: "Location Services are Disabled",
                                                         message: "To enable it go: Settings -> Privacy -> Location Services and turn On")
            }
        }
    }
    
    // Проверка авторизации прилоежния для исопользования сервисов геолокации
     func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String) {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UIAlertController.alertControl.showAlert(title: "Your Location is not Available",
                                                         message: "To give permission Go to: Setting -> MyPlaces -> Location")
            }
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            segueIdentifier == "getAddress" ? showUserLocation(mapView: mapView) : nil
        @unknown default:
            print("New case is available")
        }
    }
    
    // Фокус карты на местоположении пользователя
     func showUserLocation(mapView: MKMapView) {
        guard let location = locationManager.location?.coordinate else { return }
        let region = MKCoordinateRegion(
            center: location,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000
        )
        
        mapView.setRegion(region, animated: true)
    }
    
    // Строим маршрут от местоположения пользователя до заведения
     func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> Void) {
        guard let location = locationManager.location?.coordinate else {
            UIAlertController.alertControl.showAlert(title: "Error", message: "Current location is not found")
            return }
         
         locationManager.startUpdatingLocation()
         previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
                
        guard let request = createDirectionRequest(from: location) else {
            UIAlertController.alertControl.showAlert(title: "Error", message: "Destination is not found")
            return
        }
        
        let directions = MKDirections(request: request)
         
         resetMapView(withNew: directions, mapView: mapView)
         
        directions.calculate { response, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                UIAlertController.alertControl.showAlert(title: "Error", message: "Directions is not available")
                return
            }
            
            for route in response.routes {
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = route.expectedTravelTime
                let name = route.name
                
                print("Расстояния до места: \(distance) км")
                print("Время в пути составит: \(timeInterval) сек")
                print("\(name)")
                // 36 урок - с 15;00
            }
        }
    }
    
    // Меняем отображаемую зону области карты в соответствии с перемещением пользователя
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        guard let location = location else { return }
        let center = getCenterLocation(mapView)
        guard center.distance(from: location) > 100 else { return }
        closure(center)
    }
    
    // Сброс всех ранее построенных маршрутов перед построением нового
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    
    // Настройка запроса для расчета маршрута
     func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil } // Коррдинаты кафе
        let startingLocation = MKPlacemark(coordinate: coordinate) // Точка начало маршрута
        let destination = MKPlacemark(coordinate: destinationCoordinate) // Коррдината точки пункта назначения
        
        // Построения маршрута
        let request = MKDirections.Request()
        // Отправная точка
        request.source = MKMapItem(placemark: startingLocation)
        // Пункт назначения
        request.destination = MKMapItem(placemark: destination)
        // Вид транспорта
        request.transportType = .walking
        // Позволяет строить несколько маршрутов
        request.requestsAlternateRoutes = false
        
        return request
    }
    
    // Определение центра отображаемой области карты
     func getCenterLocation(_ mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    deinit {
        print("deinit", MapManager.self)
    }
    
}
