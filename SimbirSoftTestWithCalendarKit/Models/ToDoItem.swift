//
//  ToDoItem.swift
//  SimbirSoftTestWithCalendarKit
//
//  Created by Андрей Соколов on 11.01.2024.
//

import Foundation
import RealmSwift

class ToDoItem: Object {
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var name: String
    @Persisted var startDate: TimeInterval
    @Persisted var endDate: TimeInterval
    @Persisted var note: String?
    @Persisted var isAllDay: Bool
    @Persisted var importance: Importance
    
    convenience init(id: String = UUID().uuidString, name: String, startDate: Date, endDate: Date, note: String? = nil, isAllDay: Bool, importance: Importance) {
        self.init()
        self.id = id
        self.name = name
        self.startDate = startDate.timeIntervalSince1970
        self.endDate = endDate.timeIntervalSince1970
        self.note = note
        self.isAllDay = isAllDay
        self.importance = importance
    }
}

//MARK: - JSON keys

fileprivate enum JsonKeys {
    static let id = "id"
    static let name = "name"
    static let startDate = "startDate"
    static let endDate = "endDate"
    static let note = "note"
    static let isAllDay = "isAllDay"
    static let importance = "importance"
}

//MARK: - JSON property and JSON parsing

extension ToDoItem {
    var json: Any {
        var dictionary: [String : Any] = [:]
        
        dictionary[JsonKeys.id] = id
        dictionary[JsonKeys.name] = name
        dictionary[JsonKeys.startDate] = startDate
        dictionary[JsonKeys.endDate] = endDate
        dictionary[JsonKeys.isAllDay] = isAllDay
        dictionary[JsonKeys.importance] = importance.rawValue
        
        if let note = note {
            dictionary[JsonKeys.note] = note
        }
        
        return dictionary
    }
    
    func parse(_ json: Any) -> ToDoItem? {
        guard let dictionary = json as? [String : Any] else { return nil }
        
        guard let id = dictionary[JsonKeys.id] as? String,
              let name = dictionary[JsonKeys.name] as? String,
              let startDate = dictionary[JsonKeys.startDate] as? TimeInterval,
              let endDate = dictionary[JsonKeys.endDate] as? TimeInterval,
              let isAllDay = dictionary[JsonKeys.isAllDay] as? Bool,
              let importance = (dictionary[JsonKeys.importance] as? String).flatMap(Importance.init(rawValue:))
        else { return nil }
        
        let note = dictionary[JsonKeys.note] as? String
        
        let toDoItem = ToDoItem(id: id,
                                name: name,
                                startDate: startDate.date(),
                                endDate: endDate.date(),
                                note: note,
                                isAllDay: isAllDay,
                                importance: importance)
        return toDoItem
    }
}

