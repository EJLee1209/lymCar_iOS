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
    @Published private(set) var messages: [Chat] = []
    
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
    
    func getChats(roomId: String) {
        if let localRealm = localRealm {
            let allChats = localRealm.objects(Chat.self).filter(NSPredicate(format: "roomId == %@", roomId)).sorted(byKeyPath: "dateTime")
            messages = []
            allChats.forEach { chat in
                messages.append(chat)
            }
        }
    }
    
    func saveChat(chat: Chat) {
        if let localRealm = localRealm {
            do {
                try localRealm.write {
                    var newChat = chat
                    chat.sendSuccess = SEND_STATE_SUCCESS
                    
                    localRealm.add(newChat)
                    print("Added new favorite to Realm : \(newChat)")
                }
                getChats(roomId: chat.roomId)
            } catch {
                print("Error adding favorite to Realm : \(error)")
            }
        }
    }
    
    func deleteChat(id: String) {
        if let localRealm = localRealm {
            do {
                let chatToDelete = localRealm.objects(Chat.self).filter(NSPredicate(format: "id == %@", id))
                guard !chatToDelete.isEmpty else { return }
                
                try localRealm.write {
                    localRealm.delete(chatToDelete)
                    print("Deleted favorite with id : \(id)")
                }
            } catch {
                print("Error deleting favorite \(id) from Realm: \(error)")
            }
        }
    }
}
