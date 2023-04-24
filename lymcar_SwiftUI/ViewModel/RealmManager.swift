//
//  RealmManager.swift
//  lymcar_SwiftUI
//
//  Created by 이은재 on 2023/04/25.
//

import Foundation
import RealmSwift

class RealmManger: ObservableObject {
    private(set) var localRealm: Realm?
    @Published private(set) var favorites: [PlaceForRealm] = []
    
    init() {
        openRealm()
        getFavorites()
    }
    
    func openRealm() {
        do {
            let config = Realm.Configuration(schemaVersion: 1)
            
            Realm.Configuration.defaultConfiguration = config
            
            localRealm = try Realm()
        } catch {
            print("Error opening Realm : \(error)")
        }
    }
    
    func addFavorite(place: Place) {
        if let localRealm = localRealm {
            do {
                try localRealm.write {
                    let newFavorite = PlaceForRealm(value: [
                        "place_name" : place.place_name,
                        "address_name" : place.address_name,
                        "road_address_name" : place.road_address_name,
                        "x" : Double(place.x) ?? 0,
                        "y" : Double(place.y) ?? 0
                    ] as [String : Any])
                    localRealm.add(newFavorite)
                    print("Added new favorite to Realm : \(newFavorite)")
                }
            } catch {
                print("Error adding favorite to Realm : \(error)")
            }
        }
    }
    
    func getFavorites() {
        if let localRealm = localRealm {
            let allFavorites = localRealm.objects(PlaceForRealm.self).sorted(byKeyPath: "place_name")
            favorites = []
            allFavorites.forEach { favorite in
                favorites.append(favorite)
            }
        }
    }
    
    func deleteFavorite(id: ObjectId) {
        if let localRealm = localRealm {
            do {
                let favoriteToDelete = localRealm.objects(PlaceForRealm.self).filter(NSPredicate(format: "id == %@", id))
                guard !favoriteToDelete.isEmpty else { return }
                
                try localRealm.write {
                    localRealm.delete(favoriteToDelete)
                    getFavorites()
                    print("Deleted favorite with id : \(id)")
                }
            } catch {
                print("Error deleting favorite \(id) from Realm: \(error)")
            }
        }
    }
}
