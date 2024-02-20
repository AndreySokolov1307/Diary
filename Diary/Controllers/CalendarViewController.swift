import UIKit
import CalendarKit

fileprivate enum Constants {
    enum strings {
        static let title = "Calendar"
        static let rightBarButtonItem = "Add event"
        static let leftBarButtunItem = "Today"
    }
}

protocol CalendarView {
    func reloadData()
}

class CalendarViewController: DayViewController {

    private var toDoService: IToDoService
    
    init(toDoService: ToDoService) {
        self.toDoService = toDoService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavController()
        setupDayView()
        toDoService.calendarView = self
        toDoService.subscribeToCalendarNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    private func setupDayView() {
        dayView.autoScrollToFirstEvent = true
    }
  
    private func setupNavController() {
        title = Constants.strings.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: Constants.strings.rightBarButtonItem,
            style: .plain,
            target: self,
            action: #selector(didTapAddNewEventButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: Constants.strings.leftBarButtunItem,
            style: .plain,
            target: self,
            action: #selector(didTapTodayButton))
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    @objc func didTapAddNewEventButton() {
        let controller = NewItemViewController(toDoItem: nil, toDoService: toDoService)
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true)
    }
    
    @objc func didTapTodayButton() {
        move(to: Date())
    }

    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        let items = toDoService.getAllItems()
        let events: [ToDoItemEvent] = items.map { ToDoItemEvent(todoItem: $0)}
        
        let startDate = date
        var oneDayComponents = DateComponents()
        oneDayComponents.day = 1
        let endDate = calendar.date(byAdding: oneDayComponents, to: startDate)!
        let dateInterval = DateInterval(start: startDate, end: endDate)
        let filtredEvents = events.filter { event in
            event.dateInterval.intersects(dateInterval)
        }
        
        return filtredEvents
    }
    
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let ckEvent = eventView.descriptor as? ToDoItemEvent else {
            return
        }
        let controller = NewItemViewController(toDoItem: ckEvent.todoItem, toDoService: toDoService)
        let nav = UINavigationController(rootViewController: controller)
        navigationController?.present(nav, animated: true)
    }
}

// MARK: - CalendarView

extension CalendarViewController: CalendarView {}

