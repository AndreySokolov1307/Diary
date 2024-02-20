import UIKit
import Swinject

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let container = DIService().container
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        window?.backgroundColor = .white
        let navigationController: UINavigationController
        if let rootViewController = container.resolve(CalendarViewController.self) {
             navigationController = UINavigationController(rootViewController: rootViewController)
            window?.rootViewController = navigationController
            window?.makeKeyAndVisible()
        }
        
        return true
    }
}

