//
//  TimeInterval + extension.swift
//  SimbirSoftTestWithCalendarKit
//
//  Created by Андрей Соколов on 11.01.2024.
//

import Foundation

extension TimeInterval {
    func date() -> Date {
        return Date(timeIntervalSince1970: self)
    }
}
