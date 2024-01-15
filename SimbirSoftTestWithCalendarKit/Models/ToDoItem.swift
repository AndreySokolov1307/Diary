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
    @Persisted var exactTime: TimeInterval
    @Persisted var note: String?
    @Persisted var isAllDay: Bool
    @Persisted var importance: Importance
    
    convenience init(id: String = UUID().uuidString, name: String, startDate: Date, endDate: Date, exactTime: Date, note: String? = nil, isAllDay: Bool, importance: Importance) {
        self.init()
        self.id = id
        self.name = name
        self.startDate = startDate.timeIntervalSince1970
        self.endDate = endDate.timeIntervalSince1970
        self.exactTime = exactTime.timeIntervalSince1970
        self.note = note
        self.isAllDay = isAllDay
        self.importance = importance
    }
}

enum Importance: String, PersistableEnum {
    case hight
    case low
    case normal
}
