import Foundation
import RealmSwift


class ToDoService {
    static var shared: ToDoService!
    
    lazy var realm = try! Realm()
    
    var calendarView: CalendarView?
    
    private var calendarNotificationToken: NotificationToken?
    
    func subscribeToCalendarNotifications() {
        calendarNotificationToken = ToDoService.shared?.realm.observe { [weak self] (notification: Realm.Notification, realm: Realm) in
            self?.calendarView?.reloadData()
        }
    }
    
    init(save: @escaping (ToDoItem) -> Void, delete: @escaping (ToDoItem) -> Void, getAllItems: @escaping () -> [ToDoItem]) {
        self.save = save
        self.delete = delete
        self.getAllItems = getAllItems
    }
  
    var save: (ToDoItem) -> Void
    var delete: (ToDoItem) -> Void
    var getAllItems: () -> [ToDoItem]
}

extension ToDoService {
    static var live: ToDoService {
        let realm = try! Realm()
        return ToDoService(save: { item in
            do {
                try realm.write {
                    realm.add(item, update: .modified)
                }
            } catch {
                print("Could not save item")
            }
        }, delete: { item in
            do {
                try realm.write {
                    realm.delete(item)
                }
            } catch {
                print("Could not delete item")
            }
        }, getAllItems: {
            let items: [ToDoItem] = realm.objects(ToDoItem.self).map { $0 }
            return items
        })
    }
    
    static var failValue: ToDoService {
        let service = ToDoService.live
        service.save = { _ in
           fatalError("Cannot read from realm")
        }
        return service
    }
}
