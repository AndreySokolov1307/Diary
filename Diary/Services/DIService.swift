import Foundation
import Swinject

class DIService {
    static let shared = DIService()
    
    let container = Container()
    
    init() {
        setupContainer()
    }
    
    private func setupContainer() {
        container.register(IToDoService.self) { _ in
            return ToDoService()
        }
        container.register(CalendarViewController.self) { resolver in
            return CalendarViewController()
        }
    }
}

@propertyWrapper
struct Dependency<T> {
    var value: T
    
    init() {
        self.value = DIService.shared.container.resolve(T.self)!
    }
    
    var wrappedValue: T {
        get {
            value
        }
        set {
            value = newValue
        }
    }
}
