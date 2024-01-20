//
//  SwitchAllDayCell.swift
//  SimbirSoftTestWithCalendarKit
//
//  Created by Андрей Соколов on 13.01.2024.
//

import UIKit

class SwitchCell: UITableViewCell {
    static let reuseIdentifier = "SwitchCell"
    
    let label: UILabel = {
        let label = UILabel()
        label.text = "All-day"
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
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCell() {
        addSubview(label)
        addSubview(allDaySwitch)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            allDaySwitch.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            allDaySwitch.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
