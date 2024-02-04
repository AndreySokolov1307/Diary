import UIKit
import SnapKit

fileprivate enum Constants {
    enum strings {
        static let textFieldPlaceholder = "New event"
        static let reuseIdentifier = "TextFieldCell"
    }
    
    enum layout {
        static let textFieldMinimumHeight: CGFloat = 44
    }
}

class TextFieldCell: UITableViewCell {
    static let reuseIdentifier = Constants.strings.reuseIdentifier
        
    
    let textField: UITextField = {
        let textField = UITextField()
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(forViewController vc: UIViewController, with item: ToDoItem?) {
        textField.placeholder = Constants.strings.textFieldPlaceholder
        textField.addTarget(vc.self,
                            action: #selector(textFieldDidChange(_:)),
                            for: .editingChanged)
        textField.delegate = (vc.self as! any UITextFieldDelegate)
        if let item = item {
            textField.text = item.name
            textField.clearButtonMode = .always
        }
        textField.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(Constants.layout.textFieldMinimumHeight)
        }
    }
    
    @objc private func textFieldDidChange(_ vc: UIViewController) {
        if let text = textField.text,
           !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            vc.navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            vc.navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }
    
    private func setupLayout() {
        addSubview(textField)

        textField.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.equalToSuperview().inset(20)
            make.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
        }
    }
}

