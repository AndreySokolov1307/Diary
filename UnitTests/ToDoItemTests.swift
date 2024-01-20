//
//  ToDoItemTests.swift
//  UnitTests
//
//  Created by Андрей Соколов on 17.01.2024.
//

import XCTest
@testable import Diary

final class ToDoItemTests: XCTestCase {
    
    var sut: ToDoItem!

    override func setUpWithError() throws {
       let startTimeStamp = TimeInterval(floatLiteral: 1705494600) // 2024.01.17 14.30
       let endDateTimeStamp = TimeInterval(floatLiteral: 170550540) // 2024.01.17 17.30
        
        sut = ToDoItem(id: "itemID" ,
                       name: "Do swift learning",
                       startDate: startTimeStamp.date(),
                       endDate: endDateTimeStamp.date(),
                       isAllDay: false,
                       importance: .hight)
    }

    override func tearDownWithError() throws {
       sut = nil
    }

    func testJsonProperty() {
        // Given
        let dictionary: [String : Any] = ["id": "itemID",
                                          "name": "Do swift learning",
                                          "startDate": 1705494600,
                                          "endDate": 170550540,
                                          "isAllDay": false,
                                          "importance": "hight"]
        let expectedResult = true
        // When
        let json = sut.json as! [String: Any]
        let result = NSDictionary(dictionary: dictionary).isEqual(to: json)
        // Then
        XCTAssertEqual(result, expectedResult)
    }
    
    func testJsonParsing() {
        // Given
        
        // When
        let toDoItem = sut.parse(sut.json)!
        // Then
        XCTAssertEqual(toDoItem.id, sut.id)
        XCTAssertEqual(toDoItem.name, sut.name)
        XCTAssertEqual(toDoItem.startDate, sut.startDate)
        XCTAssertEqual(toDoItem.endDate, sut.endDate)
        XCTAssertEqual(toDoItem.isAllDay, sut.isAllDay)
        XCTAssertEqual(toDoItem.importance, sut.importance)
        XCTAssertEqual(toDoItem.note, sut.note)
        // Because of Realm we cant compare toDoItem and sut because they are two separate objects, so the result is always going to be false, instead we can compare properties
    }
}
