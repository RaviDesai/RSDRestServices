//
//  TestMockRestStore.swift
//  RSDRESTServices
//
//  Created by Ravi Desai on 12/12/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
@testable import RSDRESTServices
import RSDSerialization

class TestMockRestStore: XCTestCase {

    var store = MockedRESTStore<User>(scheme: "http", host: "api.test.com", initialValues: [User(id: NSUUID(), prefix: nil, first: "Ravi", middle: "S", last: "Desai", suffix: nil, friends: nil), User(id: NSUUID(), prefix: "Dr", first: "Eugene", middle: nil, last: "Frankenstein", suffix: "PhD", friends: nil)])
    
    func testCreateSuccess() {
        let result = try? store.create(User(id: nil, prefix: nil, first: "Alexander", middle: nil, last: "Desai", suffix: nil, friends: nil))
        XCTAssertTrue(result != nil)
        XCTAssertEqual(store.store.count, 3)
    }

    func testCreateInvalidIdFailure() {
        let item = User(id: NSUUID(), prefix: nil, first: "Test", middle: nil, last: "User", suffix: nil, friends: nil)
        var result: User?
        var resultError: StoreError?
        do {
            result = try store.create(item)
        } catch let err as StoreError {
            resultError = err
        } catch {
            resultError = StoreError.UndefinedError
        }
        XCTAssertTrue(result == nil)
        XCTAssertEqual(store.store.count, 2)
        XCTAssertTrue(resultError == StoreError.InvalidId)
    }

    func testCreateNotUniqueFailure() {
        var item = store.store[0]
        item.id = nil
        var result: User?
        var resultError: StoreError?
        do {
            result = try store.create(item)
        } catch let err as StoreError {
            resultError = err
        } catch {
            resultError = StoreError.UndefinedError
        }
        XCTAssertTrue(result == nil)
        XCTAssertEqual(store.store.count, 2)
        XCTAssertTrue(resultError == StoreError.NotUnique)
    }

    func testUpdateSuccess() {
        var item = store.store[1]
        item.middle = "R"
        let result = try? store.update(item)
        XCTAssertTrue(result != nil)
        XCTAssertEqual(store.store.count, 2)
        XCTAssertTrue(result == store.store[1])
        XCTAssertTrue(store.store[1].middle == .Some("R"))
    }

    func testUpdateNotFoundFailure() {
        let item = User(id: NSUUID(), prefix: nil, first: "Alexander", middle: nil, last: "Desai", suffix: nil, friends: nil)
        var result: User?
        var resultError: StoreError?
        do {
            result = try store.update(item)
        } catch let err as StoreError {
            resultError = err
        } catch {
            resultError = StoreError.UndefinedError
        }

        XCTAssertTrue(result == nil)
        XCTAssertEqual(store.store.count, 2)
        XCTAssertTrue(resultError == StoreError.NotFound)
    }

    func testUpdateNotUniqueFailure() {
        var item = store.store[0]
        item.id = store.store[1].id
        var result: User?
        var resultError: StoreError?
        do {
            result = try store.update(item)
        } catch let err as StoreError {
            resultError = err
        } catch {
            resultError = StoreError.UndefinedError
        }
        
        XCTAssertTrue(result == nil)
        XCTAssertEqual(store.store.count, 2)
        XCTAssertTrue(resultError == StoreError.NotUnique)
    }

    
    func testDeleteSuccess() {
        let item = store.store[0]
        let result = try? store.delete(item.id!)
        XCTAssertTrue(result != nil)
        XCTAssertTrue(item == result!)
        XCTAssertEqual(store.store.count, 1)
    }

    func testDeleteFailure() {
        let item = User(id: NSUUID(), prefix: nil, first: "Alexander", middle: nil, last: "Desai", suffix: nil, friends: nil)
        let result = try? store.delete(item.id!)
        XCTAssertTrue(result == nil)
        XCTAssertEqual(store.store.count, 2)
    }
    
    func testFindIndexOfUUID() {
        let id0 = store.store[0].id!
        let index0 = store.findIndexOfUUID(id0)
        XCTAssertEqual(index0, 0)

        let id1 = store.store[1].id!
        let index1 = store.findIndexOfUUID(id1)
        XCTAssertEqual(index1, 1)
    }
    
    func testFindIndexWhereIdIsSet() {
        var item0 = store.store[0]
        // since id is set, name components not used
        item0.first = ""
        item0.middle = nil
        item0.last = ""
        let index0 = store.findIndex(item0)
        XCTAssertEqual(index0, 0)

        var item1 = store.store[1]
        // since id is set, name components not used
        item1.first = ""
        item1.middle = nil
        item1.last = ""
        let index1 = store.findIndex(item1)
        XCTAssertEqual(index1, 1)
    }
    
    func testFindIndexWhereIdCleared() {
        var item0 = store.store[0]
        item0.id = nil
        let index0 = store.findIndex(item0)
        XCTAssertEqual(index0, 0)
        
        var item1 = store.store[1]
        item1.id = nil
        let index1 = store.findIndex(item1)
        XCTAssertEqual(index1, 1)
    }

}

class TestMockRestStoreWithAuthFilter: XCTestCase {
    
    var store = MockedRESTStore<User>(scheme: "http", host: "api.test.com", initialValues: [User(id: NSUUID(), prefix: nil, first: "Ravi", middle: "S", last: "Desai", suffix: nil, friends: nil), User(id: NSUUID(), prefix: "Dr", first: "Eugene", middle: nil, last: "Frankenstein", suffix: "PhD", friends: nil)])
    
    override func setUp() {
        super.setUp()
        store.authFilterForReading = { (user) -> Bool in user.suffix == "PhD" }
        store.authFilterForUpdating = { (user) -> Bool in user.suffix == "PhD" }
    }
    
    func testCreateSuccess() {
        let result = try? store.create(User(id: nil, prefix: nil, first: "Alexander", middle: nil, last: "Desai", suffix: "PhD", friends: nil ))
        XCTAssertTrue(result != nil)
        XCTAssertEqual(store.store.count, 3)
    }
    
    func testCreateFailure() {
        var result: User?
        var resultError: StoreError?
        do {
            result = try store.create(User(id: nil, prefix: nil, first: "Alexander", middle: nil, last: "Desai", suffix: nil, friends: nil))
        } catch let err as StoreError {
            resultError = err
        } catch {
            resultError = StoreError.UndefinedError
        }
        
        XCTAssertTrue(result == nil)
        XCTAssertEqual(store.store.count, 2)
        XCTAssertTrue(resultError == StoreError.NotAuthorized)
    }
    
    func testDeleteSuccess() {
        let result = try? store.delete(self.store.store[1].id!)
        XCTAssertTrue(result != nil)
        XCTAssertEqual(store.store.count, 1)
    }
    
    func testDeleteFailure() {
        var result: User?
        var resultError: StoreError?
        do {
            result = try store.delete(self.store.store[0].id!)
        } catch let err as StoreError {
            resultError = err
        } catch {
            resultError = StoreError.UndefinedError
        }
        
        XCTAssertTrue(result == nil)
        XCTAssertEqual(store.store.count, 2)
        XCTAssertTrue(resultError == StoreError.NotAuthorized)
    }
    
    func testGetOneSuccess() {
        let result = try? store.get(store.store[1].id!)
        XCTAssertTrue(result != nil)
        XCTAssertEqual(store.store.count, 2)
    }
    
    func testGetOneFailure() {
        var result: User?
        var resultError: StoreError?
        do {
            result = try store.get(self.store.store[0].id!)
        } catch let err as StoreError {
            resultError = err
        } catch {
            resultError = StoreError.UndefinedError
        }
        
        XCTAssertTrue(result == nil)
        XCTAssertEqual(store.store.count, 2)
        XCTAssertTrue(resultError == StoreError.NotAuthorized)
    }

    func testGetAll() {
        let result = store.getAll()
        XCTAssertEqual(result.count, 1)
    }
    
    func testUpdateSuccess() {
        var record = store.store[1]
        record.prefix = "Mx"
        
        let result = try? store.update(record)
        XCTAssertTrue(result != nil)
        XCTAssertEqual(store.store.count, 2)
    }
    
    func testUpdateFailure() {
        var record = store.store[0]
        record.prefix = "Mx"
        
        var result: User?
        var resultError: StoreError?
        do {
            result = try store.update(record)
        } catch let err as StoreError {
            resultError = err
        } catch {
            resultError = StoreError.UndefinedError
        }
        
        XCTAssertTrue(result == nil)
        XCTAssertEqual(store.store.count, 2)
        XCTAssertTrue(resultError == StoreError.NotAuthorized)

    }
}
