//
//  TextViewCell.swift
//  SimbirSoftTestWithCalendarKit
//
//  Created by Андрей Соколов on 11.01.2024.
//

import Foundation
import UIKit

class TextViewCell: UITableViewCell {
    static let reuseIdentifier = "TextViewCell"
    
    let textView: TextViewWithPlaceholder = {
        let textView = TextViewWithPlaceholder()
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCell() {
        addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
        ])
    }
}
