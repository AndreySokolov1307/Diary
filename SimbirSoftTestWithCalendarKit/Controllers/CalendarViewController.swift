//
//  ViewController.swift
//  SimbirSoftTestWithCalendarKit
//
//  Created by Андрей Соколов on 10.01.2024.
//

import UIKit
import CalendarKit
import RealmSwift
import EventKit
import EventKitUI

class CalendarViewController: DayViewController {
    private var notificationToken: NotificationToken?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavController()
        dayView.autoScrollToFirstEvent = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: true)
        subscribeToNotifications()
    }
  
    private func setupNavController() {
        title = "Calendar"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add event", style: .plain, target: self, action: #selector(didTapAddNewEventButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Today", style: .plain, target: self, action: #selector(didTapTodayButton))
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
        do {
            let realm = try Realm()
            notificationToken = realm.observe { [weak self] (_,_)  in
                self?.reloadData()
            }
        } catch {
            print(error)
        }
    }
  
    override func eventsForDate(_ date: Date) -> [EventDescriptor] {
        let realm = try! Realm()
        let items: [ToDoItem] =  realm.objects(ToDoItem.self).filter { $0.isInvalidated == false }.map { $0 }
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

