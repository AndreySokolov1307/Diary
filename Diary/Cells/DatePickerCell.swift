
import UIKit

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
        configureCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCell() {
        addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            datePicker.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])
    }
}
