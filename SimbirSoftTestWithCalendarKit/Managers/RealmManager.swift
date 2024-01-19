//
//  RealmManager.swift
//  SimbirSoftTestWithCalendarKit
//
//  Created by Андрей Соколов on 19.01.2024.
//

import Foundation
import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    
    lazy var realm = try! Realm()
    
    func save(item: ToDoItem) {
        do {
            try realm.write {
                realm.add(item, update: .modified)
            }
        } catch {
            print("Could not save the item")
        }
    }
    
    func getAllItems() -> [ToDoItem] {
        let items: [ToDoItem] = realm.objects(ToDoItem.self).map { $0 }
        return items
    }
    
    func delete(item: ToDoItem) {
        do {
            try realm.write {
                realm.delete(item)
            }
        } catch {
            print("Could not delete an item")
        }
    }
}
