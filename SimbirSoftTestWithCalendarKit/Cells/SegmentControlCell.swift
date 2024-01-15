//
//  SegmentControlCell.swift
//  SimbirSoftTestWithCalendarKit
//
//  Created by Андрей Соколов on 11.01.2024.
//

import Foundation
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
        
        let sizeConfig = UIImage.SymbolConfiguration(pointSize: 16,
                                                     weight: UIImage.SymbolWeight.bold,
                                                     scale: UIImage.SymbolScale.medium)
        let arrowImage = UIImage(systemName: "arrow.down",
                                 withConfiguration: sizeConfig)?.withTintColor(.systemGray, renderingMode: .alwaysOriginal)

        let sizeConfig2 = UIImage.SymbolConfiguration(pointSize: 16,
                                                      weight: UIImage.SymbolWeight.bold,
                                                      scale: UIImage.SymbolScale.medium)
        let exclamationImage = UIImage(systemName: "exclamationmark.2",
                                       withConfiguration: sizeConfig2)?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        
        
        
        
        
        segmentConttol.insertSegment(with: arrowImage,
                                     at: 0,
                                     animated: true)
        segmentConttol.insertSegment(withTitle: "no",
                                     at: 1,
                                     animated: true)
        segmentConttol.insertSegment(with: exclamationImage,
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
