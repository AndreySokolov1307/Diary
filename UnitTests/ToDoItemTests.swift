
import XCTest
@testable import Diary

fileprivate enum Constants {
        static let id = "itemID"
        static let name = "Do swift learning"
        static let startDateTimestamp = TimeInterval(floatLiteral: 1705494600) // 2024.01.17 14.30
        static let endDateTimestamp = TimeInterval(floatLiteral: 170550540)    // 2024.01.17 17.30
        static let isAllDay = false
        static let importance: Importance = .high
}

final class ToDoItemTests: XCTestCase {
    
    var sut: ToDoItem!

    override func setUpWithError() throws {
        sut = ToDoItem(id: Constants.id ,
                       name: Constants.name,
                       startDate: Constants.startDateTimestamp.date(),
                       endDate: Constants.endDateTimestamp.date(),
                       isAllDay: Constants.isAllDay,
                       importance: Constants.importance)
    }

    override func tearDownWithError() throws {
       sut = nil
    }

    func testJsonProperty() {
        // Given
        let dictionary: [String : Any] = [JSONKeys.id : Constants.id,
                                          JSONKeys.name : Constants.name,
                                          JSONKeys.startDate : Constants.startDateTimestamp,
                                          JSONKeys.endDate : Constants.endDateTimestamp,
                                          JSONKeys.isAllDay : Constants.isAllDay,
                                          JSONKeys.importance : Constants.importance.rawValue]
        // When
        let json = sut.json as! [String: Any]
        // Then
        XCTAssert(NSDictionary(dictionary: dictionary).isEqual(to: json))
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
