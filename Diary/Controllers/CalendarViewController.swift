//
//  ViewController.swift
//  SimbirSoftTestWithCalendarKit
//
//  Created by Андрей Соколов on 10.01.2024.
//

import UIKit
import CalendarKit
import RealmSwift

fileprivate enum UIConstants {
    enum strings {
        static let title = "Calendar"
        static let rightBarButtonItem = "Add event"
        static let leftBarButtunItem = "Today"
    }
}

class CalendarViewController: DayViewController {
    
    private var notificationToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavController()
        setupDayView()
        subscribeToNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    private func setupDayView() {
        dayView.autoScrollToFirstEvent = true
    }
  
    private func setupNavController() {
        title = UIConstants.strings.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: UIConstants.strings.rightBarButtonItem,
            style: .plain,
            target: self,
            action: #selector(didTapAddNewEventButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: UIConstants.strings.leftBarButtunItem,
            style: .plain,
            target: self,
            action: #selector(didTapTodayButton))
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    @objc func didTapAddNewEventButton() {
        let controller = NewItemViewController(toDoItem: nil)
        let nav = UINavigationController(rootViewController: controller)
        present(nav, animated: true)
    }
    
    @objc func didTapTodayButton() {
        move(to: Date())
    }
    
    private func subscribeToNotifications() {
        notificationToken = RealmManager.shared.realm.observe { [weak self] (_,_)  in
            self?.reloadData()
        }
    }
  
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        let items = RealmManager.shared.getAllItems()
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
        let controller = DetailItemViewController(toDoItem: ckEvent.todoItem)
        navigationController?.pushViewController(controller, animated: true)
    }
}

