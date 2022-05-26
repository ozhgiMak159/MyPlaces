//
//  Place.swift
//  MyPlaces
//
//  Created by Maksim  on 21.05.2022.
//

import RealmSwift

class Place: Object {
    @Persisted var name = ""
    @Persisted var location: String?
    @Persisted var type: String?
    @Persisted var imageData: Data?
    @Persisted var date = Date()
    @Persisted var rating = 0.0
       
    convenience init(name: String, location: String?, type: String?, imageData: Data?, rating: Double) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.rating = rating
    }
    
}



// MARK: -  Описание

/*
 Создали модель для описание приложения. Захардкорили названия ресторанов города Перми. Создали функцию возвращающую массив с названиями ресторанов для отображения на экране. В функции перебираем название ресторанов и добавляем в каждое свойство Модели и возвращаем массив.
 */


/*
 struct Place {
     
     let name: String
     let location: String
     let type: String
     let image: String
     var image: UIImage?
     var restaurantImage: String?
     
    static let restaurantNames = [
         "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
         "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
         "Speak Easy", "Morris Pub", "Вкусные истории",
         "Классик", "Love&Life", "Шок", "Бочка"
     ]
     
     static func getPlaces() -> [Place] {
         var places = [Place]()
         
         for place in restaurantNames {
             places.append(Place(name: place, location: "Пермь", type: "Ресторан", image: place))
         }
         
         return places
     }
     
 }
 
 class Place: Object {
     
     @Persisted var name = ""
     @Persisted var location: String?
     @Persisted var type: String?
     @Persisted var imageData: Data?
   
 let restaurantNames = [
     "Burger Heroes", "Kitchen", "Bonsai", "Дастархан",
     "Индокитай", "X.O", "Балкан Гриль", "Sherlock Holmes",
     "Speak Easy", "Morris Pub", "Вкусные истории",
     "Классик", "Love&Life", "Шок", "Бочка"
 ]
 
  func savePlaces() {
     
     for place in restaurantNames {
         let newPlace = Place()
         
         let image = UIImage(named: place)
         guard let imageData = image?.pngData() else { return }
         
         newPlace.name = place
         newPlace.location = "Perm"
         newPlace.type = "Restaurant"
         newPlace.imageData = imageData
         
         StorageManager.saveObject(newPlace)
     }
     
 }
 
 }
 
 */
