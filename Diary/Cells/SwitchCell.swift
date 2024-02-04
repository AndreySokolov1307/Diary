import UIKit

fileprivate enum Constants {
    enum strings {
        static let allDayLabel = "All-day"
    }
}

class SwitchCell: UITableViewCell {
    static let reuseIdentifier = "SwitchCell"
    
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()
    
    let allDaySwitch: UISwitch = {
        let mySwitch = UISwitch()
        mySwitch.translatesAutoresizingMaskIntoConstraints = false
        return mySwitch
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(forViewController vc: UIViewController, with item: ToDoItem?) {
        guard let newItemVC = vc as? NewItemViewController else { return }
        if let item = item {
            allDaySwitch.isOn = item.isAllDay
        }
        allDaySwitch.addTarget(newItemVC,
                               action: #selector(newItemVC.switchValueChanged(_:)),
                               for: .valueChanged)
        label.text = Constants.strings.allDayLabel
    }
    
    private func setupLayout() {
        addSubview(label)
        addSubview(allDaySwitch)
 
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
        
        allDaySwitch.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }
}
