//
//  TwoLabelsCell.swift
//  SimbirSoftTestWithCalendarKit
//
//  Created by Андрей Соколов on 13.01.2024.
//

import Foundation
import UIKit

class TwoLabelsCell: UITableViewCell {
    static let reuseIdentifier = "TwoLabelsCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let toplabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let bottomlabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private func setupView() {
        contentView.addSubview(toplabel)
        contentView.addSubview(bottomlabel)
        
        NSLayoutConstraint.activate([
            toplabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            toplabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            toplabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            bottomlabel.topAnchor.constraint(equalTo: toplabel.bottomAnchor, constant: 4),
            bottomlabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            bottomlabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            bottomlabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }
}
