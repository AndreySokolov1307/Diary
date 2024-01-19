//
//  SegmentControlCell.swift
//  SimbirSoftTestWithCalendarKit
//
//  Created by Андрей Соколов on 11.01.2024.
//

import UIKit

class SegmentContolCell: UITableViewCell {
    static let reuseIdentifier = "SegmentControlCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = "Importance"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let segmentControl: UISegmentedControl = {
        let segmentConttol = UISegmentedControl()
    
        segmentConttol.insertSegment(withTitle: Importance.low.rawValue ,
                                     at: 0,
                                     animated: true)
        segmentConttol.insertSegment(withTitle: Importance.normal.rawValue,
                                     at: 1,
                                     animated: true)
        segmentConttol.insertSegment(withTitle: Importance.hight.rawValue,
                                     at: 2,
                                     animated: true)
        segmentConttol.translatesAutoresizingMaskIntoConstraints = false
        return segmentConttol
    }()

    private func setupView() {
        addSubview(label)
        addSubview(segmentControl)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            segmentControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            segmentControl.centerYAnchor.constraint(equalTo: centerYAnchor),
            segmentControl.leadingAnchor.constraint(equalTo: centerXAnchor, constant: 30)
        ])
    }
}
