import UIKit

fileprivate enum UIConstants {
    enum strings {
        static let actionTitle = "OK"
    }
}

extension UIViewController {
    func presentConfirmAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: UIConstants.strings.actionTitle,
                                      style: .cancel))
        self.present(alert, animated: true)
    }
    
    func presentActionSheetAlert(title: String, message: String, actions: [UIAlertAction]) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .actionSheet)
        for action in actions {
            alert.addAction(action)
        }
        self.present(alert, animated: true)
    }
}
