import UIKit

fileprivate enum Constants {
    enum strings {
        static let startsLabel = "Starts"
        static let endsLabel = "Ends"
    }
    
    enum dates {
        static let oneHour: TimeInterval = 3600
    }
}

class DatePickerCell: UITableViewCell {
    static let reuseIdentifier = "DatePickerCell"
    
    let datePicker: UIDatePicker = {
       let datePicker = UIDatePicker()
        datePicker.datePickerMode = .dateAndTime
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with item: ToDoItem?, isStartCell: Bool) {
        if isStartCell {
            textLabel?.text = Constants.strings.startsLabel
            if let item = item {
                datePicker.date = item.startDate.date()
                if item.isAllDay {
                    datePicker.datePickerMode = .date
                }
            } else {
                datePicker.date = Date()
            }
        } else {
            textLabel?.text = Constants.strings.endsLabel
            if let item = item {
                datePicker.date = item.endDate.date()
                if item.isAllDay {
                    datePicker.datePickerMode = .date
                }
            } else {
                datePicker.date = Date().addingTimeInterval(Constants.dates.oneHour)
            }
        }
    }
    
    private func setupLayout() {
        addSubview(datePicker)
        
        datePicker.snp.makeConstraints { make in
            make.right.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(4)
            make.bottom.equalToSuperview().inset(4)
        }
    }
}
