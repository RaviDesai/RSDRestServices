//
//  File.swift
//  RSDRESTServices
//
//  Created by Ravi Desai on 1/8/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
import OHHTTPStubs
import RSDSerialization
@testable import RSDRESTServices

private var uid0 = NSUUID()
private var uid1 = NSUUID()
private var uid2 = NSUUID()
private var uid3 = NSUUID()
private var uid4 = NSUUID()

private var users = [
    User(id: uid0, prefix: "Sir", first: "David", middle: "Jon", last: "Gilmour", suffix: "CBE", friends: nil),
    User(id: uid1, prefix: nil, first: "Roger", middle: nil, last: "Waters", suffix: nil, friends: nil),
    User(id: uid2, prefix: "Sir", first: "Bob", middle: nil, last: "Geldof", suffix: "KBE", friends: nil),
    User(id: uid3, prefix: "Mr", first: "Nick", middle: "Berkeley", last: "Mason", suffix: nil, friends: nil),
    User(id: uid4, prefix: "", first: "Richard", middle: "William", last: "Wright", suffix: "", friends: nil)
]


class TestModelResourceCustomRequestHeader: XCTestCase {
    var called = false
    let runLoop = NSRunLoop.currentRunLoop();
    var loginSite = APISite(name: "Sample", uri: "https://com.desai")
    var session: APISession?
    var mockStore : MockedRESTStore<User>?
    var originalVersionRepresentedBy = User.resourceVersionRepresentedBy
    
    override func setUp() {
        super.setUp();
        User.resourceVersionRepresentedBy = ModelResourceVersionRepresentation.CustomRequestHeader
        mockStore = MockedRESTStore<User>(scheme: "https", host: "com.desai", initialValues: users)
        self.session = APISession(site: self.loginSite, configurationBlock: nil)
        mockStore?.hijackAll()
    }
    
    override func tearDown() {
        User.resourceVersionRepresentedBy = originalVersionRepresentedBy
        self.called = false
        self.session!.reset { () -> () in
            self.called = true
        }
        self.loopUntilCalled()
        mockStore?.unhijackAll()
        super.tearDown();
    }
    
    func loopUntilCalled() {
        while (!self.called) {
            self.runLoop.runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0.1));
        }
    }
    
    func testGetAllUsers() {
        var returnedResponse: [User]?
        var returnedError: NSError?
        User.getAll(self.session!) { (data: [User]?, error: NSError?) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        self.loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(returnedResponse != nil)
        XCTAssertTrue(returnedResponse!.count == 5)
    }

    
    func testGet() {
        var returnedResponse: User?
        var returnedError: NSError?
        User.get(self.session!, resourceId: uid0) { (data: User?, error: NSError?) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        self.loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(returnedResponse != nil)
        XCTAssertTrue(returnedResponse!.id == uid0)
    }

    func testGetErrorBecauseIDWrong() {
        var returnedResponse: User?
        var returnedError: NSError?
        User.get(self.session!, resourceId: NSUUID()) { (data: User?, error: NSError?) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(returnedResponse == nil)
    }

    func testSave() {
        var user = users[0]
        user.middle = "Changed"
        var returnedResponse: User?
        var returnedError: NSError?
        user.save(self.session!) { (data: User?, error: NSError?) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        self.loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(returnedResponse != nil)
        XCTAssertTrue(returnedResponse == user)
    }
    
    func testSaveErrorBecauseIDNull() {
        var user = users[0]
        user.id = nil
        user.middle = "Changed"
        var returnedResponse: User?
        var returnedError: NSError?
        user.save(self.session!) { (data: User?, error: NSError?) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(returnedResponse == nil)
    }
    
    func testSaveErrorBecauseIDWrong() {
        var user = users[0]
        user.id = NSUUID()
        user.middle = "Changed"
        var returnedResponse: User?
        var returnedError: NSError?
        user.save(self.session!) { (data: User?, error: NSError?) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(returnedResponse == nil)
    }
    
    func testCreate() {
        XCTAssertTrue(self.mockStore!.store.count == 5)
        let newUser = User(id: nil, prefix: "Alien", first: "Arthur", middle: nil, last: "Dent", suffix: nil, friends: nil)
        var returnedResponse: User?
        var returnedError: NSError?
        newUser.create(self.session!) { (user, error) -> () in
            returnedResponse = user
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(returnedResponse! ==% newUser)
        XCTAssertTrue(returnedResponse?.id != nil)
        XCTAssertTrue(self.mockStore!.store.count == 6)
    }

    func testCreateErrorBecauseDuplicate() {
        XCTAssertTrue(self.mockStore!.store.count == 5)
        let newUser = users[1]
        var returnedResponse: User?
        var returnedError: NSError?
        newUser.create(self.session!) { (user, error) -> () in
            returnedResponse = user
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(returnedResponse == nil)
        XCTAssertTrue(self.mockStore!.store.count == 5)
    }

    func testCreateErrorBecauseIDNotNull() {
        XCTAssertTrue(self.mockStore!.store.count == 5)
        let newUser = User(id: NSUUID(), prefix: "Alien", first: "Arthur", middle: nil, last: "Dent", suffix: nil, friends: nil)
        var returnedResponse: User?
        var returnedError: NSError?
        newUser.create(self.session!) { (user, error) -> () in
            returnedResponse = user
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(returnedResponse == nil)
        XCTAssertTrue(self.mockStore!.store.count == 5)
    }

    
    func testDeleteSuccess() {
        XCTAssertTrue(self.mockStore!.store.count == 5)
        let user = users[0]
        var returnedError: NSError?
        user.delete(self.session!) { (error) -> () in
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(self.mockStore!.store.count == 4)
    }

    func testDeleteErrorBecauseNilID() {
        XCTAssertTrue(self.mockStore!.store.count == 5)
        let userToDelete = User(id: nil, prefix: "Alien", first: "Arthur", middle: nil, last: "Dent", suffix: nil, friends: nil)
        var returnedError: NSError?
        userToDelete.delete(self.session!) { (error) -> () in
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(self.mockStore!.store.count == 5)
    }
    
    func testDeleteErrorBecauseWrongID() {
        XCTAssertTrue(self.mockStore!.store.count == 5)
        let userToDelete = User(id: NSUUID(), prefix: "Alien", first: "Arthur", middle: nil, last: "Dent", suffix: nil, friends: nil)
        var returnedError: NSError?
        userToDelete.delete(self.session!) { (error) -> () in
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(self.mockStore!.store.count == 5)
    }
}


class TestModelResourceURLVersioning: XCTestCase {
    var called = false
    let runLoop = NSRunLoop.currentRunLoop();
    var loginSite = APISite(name: "Sample", uri: "https://com.desai")
    var session: APISession?
    var mockStore : MockedRESTStore<User>?
    var originalVersionRepresentedBy = User.resourceVersionRepresentedBy
    
    override func setUp() {
        super.setUp();
        User.resourceVersionRepresentedBy = ModelResourceVersionRepresentation.URLVersioning
        mockStore = MockedRESTStore<User>(scheme: "https", host: "com.desai", initialValues: users)
        self.session = APISession(site: self.loginSite, configurationBlock: nil)
        mockStore?.hijackAll()
    }
    
    override func tearDown() {
        User.resourceVersionRepresentedBy = originalVersionRepresentedBy
        self.called = false
        self.session!.reset { () -> () in
            self.called = true
        }
        self.loopUntilCalled()
        mockStore?.unhijackAll()
        super.tearDown();
    }
    
    func loopUntilCalled() {
        while (!self.called) {
            self.runLoop.runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0.1));
        }
    }
    
    func testGetAllUsers() {
        var returnedResponse: [User]?
        var returnedError: NSError?
        User.getAll(self.session!) { (data: [User]?, error: NSError?) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        self.loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(returnedResponse != nil)
        XCTAssertTrue(returnedResponse!.count == 5)
    }
    
    
    func testGet() {
        var returnedResponse: User?
        var returnedError: NSError?
        User.get(self.session!, resourceId: uid0) { (data: User?, error: NSError?) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        self.loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(returnedResponse != nil)
        XCTAssertTrue(returnedResponse!.id == uid0)
    }
    
    func testGetErrorBecauseIDWrong() {
        var returnedResponse: User?
        var returnedError: NSError?
        User.get(self.session!, resourceId: NSUUID()) { (data: User?, error: NSError?) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(returnedResponse == nil)
    }
    
    func testSave() {
        var user = users[0]
        user.middle = "Changed"
        var returnedResponse: User?
        var returnedError: NSError?
        user.save(self.session!) { (data: User?, error: NSError?) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        self.loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(returnedResponse != nil)
        XCTAssertTrue(returnedResponse == user)
    }
    
    func testSaveErrorBecauseIDNull() {
        var user = users[0]
        user.id = nil
        user.middle = "Changed"
        var returnedResponse: User?
        var returnedError: NSError?
        user.save(self.session!) { (data: User?, error: NSError?) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(returnedResponse == nil)
    }
    
    func testSaveErrorBecauseIDWrong() {
        var user = users[0]
        user.id = NSUUID()
        user.middle = "Changed"
        var returnedResponse: User?
        var returnedError: NSError?
        user.save(self.session!) { (data: User?, error: NSError?) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(returnedResponse == nil)
    }
    
    func testCreate() {
        XCTAssertTrue(self.mockStore!.store.count == 5)
        let newUser = User(id: nil, prefix: "Alien", first: "Arthur", middle: nil, last: "Dent", suffix: nil, friends: nil)
        var returnedResponse: User?
        var returnedError: NSError?
        newUser.create(self.session!) { (user, error) -> () in
            returnedResponse = user
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(returnedResponse! ==% newUser)
        XCTAssertTrue(returnedResponse?.id != nil)
        XCTAssertTrue(self.mockStore!.store.count == 6)
    }
    
    func testCreateErrorBecauseDuplicate() {
        XCTAssertTrue(self.mockStore!.store.count == 5)
        let newUser = users[1]
        var returnedResponse: User?
        var returnedError: NSError?
        newUser.create(self.session!) { (user, error) -> () in
            returnedResponse = user
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(returnedResponse == nil)
        XCTAssertTrue(self.mockStore!.store.count == 5)
    }
    
    func testCreateErrorBecauseIDNotNull() {
        XCTAssertTrue(self.mockStore!.store.count == 5)
        let newUser = User(id: NSUUID(), prefix: "Alien", first: "Arthur", middle: nil, last: "Dent", suffix: nil, friends: nil)
        var returnedResponse: User?
        var returnedError: NSError?
        newUser.create(self.session!) { (user, error) -> () in
            returnedResponse = user
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(returnedResponse == nil)
        XCTAssertTrue(self.mockStore!.store.count == 5)
    }
    
    
    func testDeleteSuccess() {
        XCTAssertTrue(self.mockStore!.store.count == 5)
        let user = users[0]
        var returnedError: NSError?
        user.delete(self.session!) { (error) -> () in
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(self.mockStore!.store.count == 4)
    }
    
    func testDeleteErrorBecauseNilID() {
        XCTAssertTrue(self.mockStore!.store.count == 5)
        let userToDelete = User(id: nil, prefix: "Alien", first: "Arthur", middle: nil, last: "Dent", suffix: nil, friends: nil)
        var returnedError: NSError?
        userToDelete.delete(self.session!) { (error) -> () in
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(self.mockStore!.store.count == 5)
    }
    
    func testDeleteErrorBecauseWrongID() {
        XCTAssertTrue(self.mockStore!.store.count == 5)
        let userToDelete = User(id: NSUUID(), prefix: "Alien", first: "Arthur", middle: nil, last: "Dent", suffix: nil, friends: nil)
        var returnedError: NSError?
        userToDelete.delete(self.session!) { (error) -> () in
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(self.mockStore!.store.count == 5)
    }
}


class TestModelResourceCustomContentType: XCTestCase {
    var called = false
    let runLoop = NSRunLoop.currentRunLoop();
    var loginSite = APISite(name: "Sample", uri: "https://com.desai")
    var session: APISession?
    var mockStore : MockedRESTStore<User>?
    var originalVersionRepresentedBy = User.resourceVersionRepresentedBy
    
    override func setUp() {
        super.setUp();
        User.resourceVersionRepresentedBy = ModelResourceVersionRepresentation.CustomContentType
        mockStore = MockedRESTStore<User>(scheme: "https", host: "com.desai", initialValues: users)
        self.session = APISession(site: self.loginSite, configurationBlock: nil)
        mockStore?.hijackAll()
    }
    
    override func tearDown() {
        User.resourceVersionRepresentedBy = originalVersionRepresentedBy
        self.called = false
        self.session!.reset { () -> () in
            self.called = true
        }
        self.loopUntilCalled()
        mockStore?.unhijackAll()
        super.tearDown();
    }
    
    func loopUntilCalled() {
        while (!self.called) {
            self.runLoop.runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0.1));
        }
    }
    
    func testGetAllUsers() {
        var returnedResponse: [User]?
        var returnedError: NSError?
        User.getAll(self.session!) { (data: [User]?, error: NSError?) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        self.loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(returnedResponse != nil)
        XCTAssertTrue(returnedResponse!.count == 5)
    }
    
    
    func testGet() {
        var returnedResponse: User?
        var returnedError: NSError?
        User.get(self.session!, resourceId: uid0) { (data: User?, error: NSError?) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        self.loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(returnedResponse != nil)
        XCTAssertTrue(returnedResponse!.id == uid0)
    }
    
    func testGetErrorBecauseIDWrong() {
        var returnedResponse: User?
        var returnedError: NSError?
        User.get(self.session!, resourceId: NSUUID()) { (data: User?, error: NSError?) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(returnedResponse == nil)
    }
    
    func testSave() {
        var user = users[0]
        user.middle = "Changed"
        var returnedResponse: User?
        var returnedError: NSError?
        user.save(self.session!) { (data: User?, error: NSError?) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        self.loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(returnedResponse != nil)
        XCTAssertTrue(returnedResponse == user)
    }
    
    func testSaveErrorBecauseIDNull() {
        var user = users[0]
        user.id = nil
        user.middle = "Changed"
        var returnedResponse: User?
        var returnedError: NSError?
        user.save(self.session!) { (data: User?, error: NSError?) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(returnedResponse == nil)
    }
    
    func testSaveErrorBecauseIDWrong() {
        var user = users[0]
        user.id = NSUUID()
        user.middle = "Changed"
        var returnedResponse: User?
        var returnedError: NSError?
        user.save(self.session!) { (data: User?, error: NSError?) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(returnedResponse == nil)
    }
    
    func testCreate() {
        XCTAssertTrue(self.mockStore!.store.count == 5)
        let newUser = User(id: nil, prefix: "Alien", first: "Arthur", middle: nil, last: "Dent", suffix: nil, friends: nil)
        var returnedResponse: User?
        var returnedError: NSError?
        newUser.create(self.session!) { (user, error) -> () in
            returnedResponse = user
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(returnedResponse! ==% newUser)
        XCTAssertTrue(returnedResponse?.id != nil)
        XCTAssertTrue(self.mockStore!.store.count == 6)
    }
    
    func testCreateErrorBecauseDuplicate() {
        XCTAssertTrue(self.mockStore!.store.count == 5)
        let newUser = users[1]
        var returnedResponse: User?
        var returnedError: NSError?
        newUser.create(self.session!) { (user, error) -> () in
            returnedResponse = user
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(returnedResponse == nil)
        XCTAssertTrue(self.mockStore!.store.count == 5)
    }
    
    func testCreateErrorBecauseIDNotNull() {
        XCTAssertTrue(self.mockStore!.store.count == 5)
        let newUser = User(id: NSUUID(), prefix: "Alien", first: "Arthur", middle: nil, last: "Dent", suffix: nil, friends: nil)
        var returnedResponse: User?
        var returnedError: NSError?
        newUser.create(self.session!) { (user, error) -> () in
            returnedResponse = user
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(returnedResponse == nil)
        XCTAssertTrue(self.mockStore!.store.count == 5)
    }
    
    
    func testDeleteSuccess() {
        XCTAssertTrue(self.mockStore!.store.count == 5)
        let user = users[0]
        var returnedError: NSError?
        user.delete(self.session!) { (error) -> () in
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(self.mockStore!.store.count == 4)
    }
    
    func testDeleteErrorBecauseNilID() {
        XCTAssertTrue(self.mockStore!.store.count == 5)
        let userToDelete = User(id: nil, prefix: "Alien", first: "Arthur", middle: nil, last: "Dent", suffix: nil, friends: nil)
        var returnedError: NSError?
        userToDelete.delete(self.session!) { (error) -> () in
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(self.mockStore!.store.count == 5)
    }
    
    func testDeleteErrorBecauseWrongID() {
        XCTAssertTrue(self.mockStore!.store.count == 5)
        let userToDelete = User(id: NSUUID(), prefix: "Alien", first: "Arthur", middle: nil, last: "Dent", suffix: nil, friends: nil)
        var returnedError: NSError?
        userToDelete.delete(self.session!) { (error) -> () in
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(self.mockStore!.store.count == 5)
    }
}
