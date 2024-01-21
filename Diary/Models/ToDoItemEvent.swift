
import Foundation
import RealmSwift
import CalendarKit


class ToDoItemEvent: EventDescriptor {
    var dateInterval: DateInterval = DateInterval()
    var isAllDay: Bool = false
    var text: String = ""
    var attributedText: NSAttributedString?
    var lineBreakMode: NSLineBreakMode?
    var font: UIFont = UIFont.boldSystemFont(ofSize: 12)
    var color: UIColor = .systemGray
    var textColor: UIColor = UIColor.black
    var backgroundColor: UIColor = SystemColors.systemBlue.withAlphaComponent(0.3)
    var editedEvent: CalendarKit.EventDescriptor?
    var todoItem: ToDoItem
    
    func makeEditable() -> Self {
        fatalError("not implemented")
    }
    
    func commitEditing() {
        
    }
    
   init(todoItem: ToDoItem) {
        self.todoItem = todoItem
        self.text = todoItem.name
        self.dateInterval = DateInterval(start: todoItem.startDate.date(), end: todoItem.endDate.date())
        self.isAllDay = todoItem.isAllDay
       switch todoItem.importance {
       case .high:
           self.backgroundColor = SystemColors.systemRed.withAlphaComponent(0.3)
       case .low:
           self.backgroundColor = SystemColors.systemGray4.withAlphaComponent(0.3)
       case .normal:
           self.backgroundColor = SystemColors.systemBlue.withAlphaComponent(0.3)
       }
    }
}

