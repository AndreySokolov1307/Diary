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

enum JSONKeys {
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
        
        dictionary[JSONKeys.id] = id
        dictionary[JSONKeys.name] = name
        dictionary[JSONKeys.startDate] = startDate
        dictionary[JSONKeys.endDate] = endDate
        dictionary[JSONKeys.isAllDay] = isAllDay
        dictionary[JSONKeys.importance] = importance.rawValue
        
        if let note = note {
            dictionary[JSONKeys.note] = note
        }
        
        return dictionary
    }
    
    func parse(_ json: Any) -> ToDoItem? {
        guard let dictionary = json as? [String : Any] else { return nil }
        
        guard let id = dictionary[JSONKeys.id] as? String,
              let name = dictionary[JSONKeys.name] as? String,
              let startDate = dictionary[JSONKeys.startDate] as? TimeInterval,
              let endDate = dictionary[JSONKeys.endDate] as? TimeInterval,
              let isAllDay = dictionary[JSONKeys.isAllDay] as? Bool,
              let importance = (dictionary[JSONKeys.importance] as? String).flatMap(Importance.init(rawValue:))
        else { return nil }
        
        let note = dictionary[JSONKeys.note] as? String
        
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

