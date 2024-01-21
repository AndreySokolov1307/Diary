import Foundation
import RealmSwift

class ToDoService {
    static let shared = ToDoService()
    
    lazy var realm = try! Realm()
    
    var calendarView: CalendarView?
    var itemView: ItemView?
    
    private var calendarNotificationToken: NotificationToken?
    private var itemNotificationToken: NotificationToken?
    
    func subscribeToCalendarNotifications() {
        calendarNotificationToken = ToDoService.shared.realm.observe { [weak self] (_,_) in
            self?.calendarView?.reloadData()
        }
    }
    
    func subscribeToItemNotifications() {
        itemNotificationToken = ToDoService.shared.realm.observe { [weak self] (_,_) in
            self?.itemView?.reloadData()
        }
    }
    
    func invalidateItemToken() {
        itemNotificationToken?.invalidate()
    }
    
    func save(item: ToDoItem) {
        do {
            try realm.write {
                realm.add(item, update: .modified)
            }
        } catch {
            print("Could not save item")
        }
    }
    
    func getAllItems() -> [ToDoItem] {
        let items: [ToDoItem] = realm.objects(ToDoItem.self).map { $0 }
        return items
    }
    
    func delete(item: ToDoItem) {
        invalidateItemToken()
        do {
            try realm.write {
                realm.delete(item)
            }
        } catch {
            print("Could not delete item")
        }
    }
}
