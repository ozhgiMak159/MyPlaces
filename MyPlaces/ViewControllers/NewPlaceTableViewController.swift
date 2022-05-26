//
//  NewPlaceTableViewController.swift
//  MyPlaces
//
//  Created by Maksim  on 21.05.2022.
//

import UIKit
import Cosmos

class NewPlaceTableViewController: UITableViewController {
    
    // MARK: - Public & Private property
    var currentPlace: Place!
    private var imageIsChanged = false
    private var currentRating = 0.0
   
    // MARK: - IBOutlet
    @IBOutlet var saveButton: UIBarButtonItem!
    
    @IBOutlet var placeImage: UIImageView!
    
    @IBOutlet var placeName: UITextField!
    @IBOutlet var placeLocation: UITextField!
    @IBOutlet var placeType: UITextField!
    
    @IBOutlet var cosmosView: CosmosView! {
        didSet {
            cosmosView.didTouchCosmos = { [unowned self] rating in
                currentRating = rating
            }
        }
    }

    // MARK: - Method class
    override func viewDidLoad() {
        super.viewDidLoad()
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
    }
    
    private func AlertControllerShow() {
        let cameraIcon = #imageLiteral(resourceName: "camera")
        let photoIcon = #imageLiteral(resourceName: "photo")
        
        let actionSheet = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet)
        
        let camera = UIAlertAction(title: "Camera", style: .default) { _ in
            self.chooseImagePicker(.camera)
        }
        
        let photo = UIAlertAction(title: "Photo", style: .default) { _ in
            self.chooseImagePicker(.photoLibrary)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        camera.setValue(cameraIcon, forKey: "image")
        camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
      
        photo.setValue(photoIcon, forKey: "image")
        photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
        
        actionSheet.view.tintColor = .black
        actionSheet.addAction(camera)
        actionSheet.addAction(photo)
        actionSheet.addAction(cancel)
        
        present(actionSheet, animated: true)
    }
    
    @objc private func textFieldChanged() {
        guard let firstTextField = placeName.text else { return }
        saveButton.isEnabled = !firstTextField.isEmpty
    }
    
    private func displaysMainScreen() {
        guard let data = currentPlace?.imageData else { return }
        guard let image = UIImage(data: data) else { return }
        
        placeImage.image = image
        placeName.text = currentPlace?.name
        placeLocation.text = currentPlace?.location
        placeType.text = currentPlace?.type
        cosmosView.rating = currentPlace.rating
    }
    
     func savePlace() {
         let image = imageIsChanged ? placeImage.image :  #imageLiteral(resourceName: "imagePlaceholder")
         let imageData = image?.pngData()
         
         let newPlace = Place(name: placeName.text!,
                              location: placeLocation.text,
                              type: placeType.text,
                              imageData: imageData,
                              rating: currentRating)
         
          currentPlace != nil
            ? StorageManager.shared.editObject(currentPlace, newPlace)
            : StorageManager.shared.saveObject(newPlace)
    }
    
    private func setupEditScreen() {
        if currentPlace != nil {
            setupNavigationBar()
            imageIsChanged = true
            displaysMainScreen()
        }
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = nil
        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.topItem?.backBarButtonItem?.tintColor = .black
        placeImage.contentMode = .scaleAspectFill
        
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            AlertControllerShow()
        } else {
            view.endEditing(true)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        guard let mapVC = segue.destination as? MapViewController else { return }
        
        if identifier == "showPlace" {
            mapVC.place.name = placeName.text!
            mapVC.place.location = placeLocation.text
            mapVC.place.type = placeType.text
            mapVC.place.imageData = placeImage.image?.pngData()
        }
        
        mapVC.incomeSegueIdentifier = identifier
        mapVC.delegate = self
        
    }
    
    // MARK: - IBAction
    @IBAction func cancelButtonAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: - deinit class
    deinit {
        print("deinit", NewPlaceTableViewController.self)
    }
    
}

// MARK: - UITextFieldDelegate
extension NewPlaceTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
}

// MARK: - UIImagePickerController(Работа с фотографиями)
extension NewPlaceTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func chooseImagePicker(_ source: UIImagePickerController.SourceType) {
        
        let imagePicker = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(source) {
            imagePicker.sourceType = source
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         
         placeImage.image = info[.editedImage] as? UIImage
         placeImage.contentMode = .scaleAspectFill
         placeImage.clipsToBounds = true
         imageIsChanged = true
         dismiss(animated: true)
    }
    
}

extension NewPlaceTableViewController: MapViewControllerDelegate {
    func getAddress(_ address: String?) {
        placeLocation.text = address
    }
}

