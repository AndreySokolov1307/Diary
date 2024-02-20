import Foundation
import Swinject

class DIService {
    
    let container = Container()
    
    init() {
        setupContainer()
    }
    
    private func setupContainer() {
        container.register(IToDoService.self) { _ in
            return ToDoService()
        }
        container.register(CalendarViewController.self) { resolver in
            let vc = CalendarViewController(toDoService: resolver.resolve(IToDoService.self) as! ToDoService)
            return vc
        }
    }
}
