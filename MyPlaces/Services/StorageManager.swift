//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Maksim  on 22.05.2022.
//

import RealmSwift

class StorageManager {
    
    static let shared = StorageManager()
    private init() {}
    
    let realm = try! Realm()
    
     func saveObject(_ place: Place) {
         write {
             realm.add(place)
         }
    }
    
     func deleteObject(_ place: Place) {
         write {
             realm.delete(place)
         }
    }
    
    func editObject(_ currentPlace: Place?,_ newName: Place) {
        write {
            currentPlace?.name = newName.name
            currentPlace?.location = newName.location
            currentPlace?.type = newName.type
            currentPlace?.imageData = newName.imageData
            currentPlace?.rating = newName.rating
        }
    }
    
 private func write(completion: () -> Void) {
        do {
            try realm.write {
                completion()
            }
        } catch {
            print(error)
        }
    }
    
}
