//
//  Importance.swift
//  SimbirSoftTestWithCalendarKit
//
//  Created by Андрей Соколов on 17.01.2024.
//

import Foundation
import RealmSwift

enum Importance: String, PersistableEnum {
    case high
    case low
    case normal
    
    var emoji: String {
        switch self {
        case .low:
            return "⬇️"
        case .normal:
            return "no"
        case .high:
            return "‼️"
        }
    }
}
