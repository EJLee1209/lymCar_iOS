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
    
    // 기본 즐겨찾기 세팅
    func settingInit() {
        if let localRealm = localRealm {
            do {
                try localRealm.write {
                    PlaceForRealm.mock.forEach { place in
                        localRealm.add(place)
                    }
                    print("즐겨찾기 기본 세팅 완료")
                }
            } catch {
                print("Error settingInit : \(error)")
            }
        }
    }
    
    // 즐겨찾기 추가
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
    
    // 즐겨찾기 가져오기
    func getFavorites() {
        if let localRealm = localRealm {
            let allFavorites = localRealm.objects(PlaceForRealm.self).sorted(byKeyPath: "place_name")
            favorites = []
            allFavorites.forEach { favorite in
                favorites.append(favorite)
            }
            print("즐겨찾기 리스트 : \(favorites)")
        }
    }
    
    // 즐겨찾기 삭제
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
    
    // 채팅 내역 가져오기
    func getChats(roomId: String) {
        if let localRealm = localRealm {
            let allChats = localRealm.objects(Chat.self).filter(NSPredicate(format: "roomId == %@", roomId)).sorted(byKeyPath: "dateTime")
            messages = []
            allChats.forEach { chat in
                messages.append(chat)
            }
        }
    }
    
    // 채팅 저장
    func saveChat(chat: Chat) {
        if let localRealm = localRealm {
            do {
                try localRealm.write {
                    localRealm.add(chat)
                    print("Added new chat to Realm : \(chat)")
                }
                getChats(roomId: chat.roomId)
            } catch {
                print("Error adding chat to Realm : \(error)")
            }
        }
    }
    
    // 채팅 업데이트(전송 State)
    func updateChat(chat: Chat, newState: String) {
        if let localRealm = localRealm {
            do {
                try localRealm.write {
                    chat.sendSuccess = newState
                }
                getChats(roomId: chat.roomId)
            } catch {
                print("Error updating chat to Realm")
            }
        }
    }
    
    // 채팅 삭제
    func deleteChat(chat: Chat) {
        if let localRealm = localRealm {
            do {
                let chatToDelete = localRealm.objects(Chat.self).filter(NSPredicate(format: "id == %@", chat.id))
                guard !chatToDelete.isEmpty else { return }
                
                try localRealm.write {
                    localRealm.delete(chatToDelete)
                    print("Deleted favorite with id : \(chat.id)")
                }
                getChats(roomId: chat.roomId)
                
            } catch {
                print("Error deleting favorite \(chat.id) from Realm: \(error)")
            }
        }
    }
    
    // 모든 데이터 삭제
    func clearRealm() {
        if let localRealm = localRealm {
            do {
                try localRealm.write {
                    localRealm.deleteAll()
                }
            } catch {
                print("Error clearRealm : \(error)")
            }
        }
    }
}
