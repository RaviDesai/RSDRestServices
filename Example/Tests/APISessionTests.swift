//
//  APISessionTests.swift
//  CEVFoundation
//
//  Created by Ravi Desai on 6/10/15.
//  Copyright (c) 2015 CEV. All rights reserved.
//

import UIKit
import XCTest
import OHHTTPStubs
import RSDSerialization
import RSDRESTServices

class APISessionTests: XCTestCase {
    var called = false
    let runLoop = NSRunLoop.currentRunLoop();
    var loginSite = APISite(name: "Sample", uri: "https://com.desai/")
    var session: APISession?
    
    override func setUp() {
        super.setUp();
        self.session = APISession(site: self.loginSite, configurationBlock: nil)
    }
    
    override func tearDown() {
        self.called = false
        self.session!.reset { () -> () in
            self.called = true
        }
        self.loopUntilCalled()
        OHHTTPStubs.removeAllStubs();
        super.tearDown();
    }
    
    func loopUntilCalled() {
        while (!self.called) {
            self.runLoop.runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0.1));
        }
    }
    
    
    func testRestCallToiTunes() {
        MockedRESTCalls.hijackITunesSearch()
        
        self.loginSite.uri = NSURL(string: "https://itunes.apple.com/");
        let newsession = APISession(site: self.loginSite, configurationBlock: nil)
        
        let endpointUrl = URLAndParameters(url: "search", parameters: ("term", "Pink+Floyd"))
        let endpoint = APIEndpoint.GET(endpointUrl)
        let parser = APIDataResponseParser()
        let request = APIRequest(baseURL: newsession.baseURL, endpoint: endpoint, bodyEncoder: nil, responseParser: parser, additionalHeaders: nil)
        let call = APICall(session: newsession, request: request)
        var returnedResponse: NSData?
        var returnedError: NSError?
    
        call.executeRespondWithObject { (data, error) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }

        loopUntilCalled()

        XCTAssertTrue(returnedResponse != nil)
        XCTAssertTrue(returnedError == nil)
        
        let data = returnedResponse!
        let str = NSString(data: data, encoding: NSUTF8StringEncoding)!
        NSLog("%@", str)
        
        let jsonOptional: AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        
        XCTAssertTrue(jsonOptional != nil)
        let json: JSON = jsonOptional!
        
        // Note that JSON converted types are NS* types from
        // the Foundation library
        let nsJsonDict = json as! NSDictionary
        let nsResultCount = nsJsonDict["resultCount"] as! NSNumber
        XCTAssertTrue(nsResultCount.integerValue == 50)
        
        let nsResults = nsJsonDict["results"]as! NSArray
        XCTAssertTrue(nsResults.count == 50)
        
        let nsTrack = nsResults[0] as! NSDictionary
        XCTAssertTrue(nsTrack.count == 32)
        
        let nsArtistName = nsTrack["artistName"] as! NSString
        XCTAssertTrue(nsArtistName == "Pink Floyd")
        
        // Note that JSON converted types can be converted to
        // Swift Value types anyway.
        var swJsonDict = json as! [String: JSON]
        let swResultCount = swJsonDict["resultCount"]as! Int
        XCTAssertTrue(swResultCount == 50)
        
        var swResults = swJsonDict["results"] as! [JSON]
        XCTAssertTrue(swResults.count == 50)
        
        var swTrack = swResults[0] as! [String: JSON]
        XCTAssertTrue(swTrack.count == 32)
        
        let swArtistName = swTrack["artistName"] as! String
        XCTAssertTrue(swArtistName == "Pink Floyd")
    }
    
    func testGetUsers() {
        MockedRESTCalls.hijackUserGetAll()
        
        let endpointUrl = URLAndParameters(url: "api/Users")
        let endpoint = APIEndpoint.GET(endpointUrl)
        let parser = APIJSONSerializableResponseParser<User>()
        let request = APIRequest(baseURL: session!.baseURL, endpoint: endpoint, bodyEncoder: nil, responseParser: parser, additionalHeaders: nil)
        let call = APICall(session: session!, request: request)
        var returnedResponse: [User]?
        var returnedError: NSError?
        
        call.executeRespondWithArray { (data, error) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(returnedResponse != nil)
        XCTAssertTrue(returnedResponse!.count == 5)

    }

    func testGetUsersDavidGilmour() {
        MockedRESTCalls.hijackUserGetMatching()
        
        let endpointUrl = URLAndParameters(url: "api/Users", parameters: ("prefix", "Sir"), ("last", "Gilmour"))
        let endpoint = APIEndpoint.GET(endpointUrl)
        let parser = APIJSONSerializableResponseParser<User>()
        let request = APIRequest(baseURL: session!.baseURL, endpoint: endpoint, bodyEncoder: nil, responseParser: parser, additionalHeaders: nil)
        let call = APICall(session: session!, request: request)
        var returnedResponse: [User]?
        var returnedError: NSError?
        
        call.executeRespondWithArray { (data, error) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(returnedResponse != nil)
        XCTAssertTrue(returnedResponse!.count == 1)
        let getDavid = MockedRESTCalls.sampleUsers().filter{ $0.first == "David" && $0.last == "Gilmour" }.first!
        XCTAssertTrue(returnedResponse![0] == getDavid)
    }
    
    func testGetAllKnighted() {
        MockedRESTCalls.hijackUserGetMatching()
        
        let endpointUrl = URLAndParameters(url: "api/Users", parameters: ("prefix", "Sir"))
        let endpoint = APIEndpoint.GET(endpointUrl)
        let parser = APIJSONSerializableResponseParser<User>()
        let request = APIRequest(baseURL: session!.baseURL, endpoint: endpoint, bodyEncoder: nil, responseParser: parser, additionalHeaders: nil)
        let call = APICall(session: session!, request: request)
        var returnedResponse: [User]?
        var returnedError: NSError?
        
        call.executeRespondWithArray { (data, error) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(returnedResponse != nil)
        XCTAssertTrue(returnedResponse!.count == 2)
        XCTAssertTrue(returnedResponse![0].prefix == "Sir")
        XCTAssertTrue(returnedResponse![1].prefix == "Sir")
    }
    
    func testPostNewUser() {
        MockedRESTCalls.hijackUserPost()
        
        let newUser = User(id: NSUUID(), prefix: nil, first: "Syd", middle: nil, last: "Barrett", suffix: nil)
        let endpointUrl = URLAndParameters(url: "api/Users")
        let endpoint = APIEndpoint.POST(endpointUrl)
        let parser = APIJSONSerializableResponseParser<User>()
        let encoder = APIJSONBodyEncoder(model: newUser)
        let request = APIRequest(baseURL: session!.baseURL, endpoint: endpoint, bodyEncoder: encoder, responseParser: parser, additionalHeaders: nil)
        let call = APICall(session: session!, request: request)
        var returnedResponse: User?
        var returnedError: NSError?
        
        call.executeRespondWithObject{ (data, error) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(returnedResponse != nil)
        XCTAssertTrue(returnedResponse!.id != nil)
        XCTAssertTrue(returnedResponse!.prefix == newUser.prefix)
        XCTAssertTrue(returnedResponse!.first == newUser.first)
        XCTAssertTrue(returnedResponse!.middle == newUser.middle)
        XCTAssertTrue(returnedResponse!.last == newUser.last)
        XCTAssertTrue(returnedResponse!.suffix == newUser.suffix)
    }

    func testPostExistingUser() {
        MockedRESTCalls.hijackUserPost()
        
        let existingUser = MockedRESTCalls.sampleUsers()[1]
        let endpointUrl = URLAndParameters(url: "api/Users")
        let endpoint = APIEndpoint.POST(endpointUrl)
        let parser = APIJSONSerializableResponseParser<User>()
        let encoder = APIJSONBodyEncoder(model: existingUser)
        let request = APIRequest(baseURL: session!.baseURL, endpoint: endpoint, bodyEncoder: encoder, responseParser: parser, additionalHeaders: nil)
        let call = APICall(session: session!, request: request)
        var returnedResponse: User?
        var returnedError: NSError?
        
        call.executeRespondWithObject{ (data, error) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(returnedResponse == nil)
    }

    func testPutNewUser() {
        MockedRESTCalls.hijackUserPut()
        
        let newUser = User(id: NSUUID(), prefix: nil, first: "Syd", middle: nil, last: "Barrett", suffix: nil)
        let endpointUrl = URLAndParameters(url: "api/Users")
        let endpoint = APIEndpoint.PUT(endpointUrl)
        let parser = APIJSONSerializableResponseParser<User>()
        let encoder = APIJSONBodyEncoder(model: newUser)
        let request = APIRequest(baseURL: session!.baseURL, endpoint: endpoint, bodyEncoder: encoder, responseParser: parser, additionalHeaders: nil)
        let call = APICall(session: session!, request: request)
        var returnedResponse: User?
        var returnedError: NSError?
        
        call.executeRespondWithObject{ (data, error) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(returnedResponse == nil)
    }
    
    func testPutExistingUser() {
        MockedRESTCalls.hijackUserPut()
        
        let existingUser = MockedRESTCalls.sampleUsers()[1]
        let endpointUrl = URLAndParameters(url: "api/Users")
        let endpoint = APIEndpoint.PUT(endpointUrl)
        let parser = APIJSONSerializableResponseParser<User>()
        let encoder = APIJSONBodyEncoder(model: existingUser)
        let request = APIRequest(baseURL: session!.baseURL, endpoint: endpoint, bodyEncoder: encoder, responseParser: parser, additionalHeaders: nil)
        let call = APICall(session: session!, request: request)
        var returnedResponse: User?
        var returnedError: NSError?
        
        call.executeRespondWithObject{ (data, error) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(returnedResponse != nil)
        XCTAssertTrue(returnedResponse! == existingUser)
    }
    
    func testDeleteExistingUser() {
        MockedRESTCalls.hijackUserDelete()

        let existingUser = MockedRESTCalls.sampleUsers()[1]
        let endpointUrl = URLAndParameters(url: "api/Users")
        let endpoint = APIEndpoint.DELETE(endpointUrl)
        let parser = APIJSONSerializableResponseParser<User>()
        let encoder = APIJSONBodyEncoder(model: existingUser)
        let request = APIRequest(baseURL: session!.baseURL, endpoint: endpoint, bodyEncoder: encoder, responseParser: parser, additionalHeaders: nil)
        let call = APICall(session: session!, request: request)
        var returnedResponse: User?
        var returnedError: NSError?
        
        call.executeRespondWithObject{ (data, error) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
        XCTAssertTrue(returnedResponse != nil)
        XCTAssertTrue(returnedResponse! == existingUser)
    }
    
    func testDeleteNewUser() {
        MockedRESTCalls.hijackUserDelete()
        
        let newUser = User(id: NSUUID(), prefix: nil, first: "Syd", middle: nil, last: "Barrett", suffix: nil)
        let endpointUrl = URLAndParameters(url: "api/Users")
        let endpoint = APIEndpoint.DELETE(endpointUrl)
        let parser = APIJSONSerializableResponseParser<User>()
        let encoder = APIJSONBodyEncoder(model: newUser)
        let request = APIRequest(baseURL: session!.baseURL, endpoint: endpoint, bodyEncoder: encoder, responseParser: parser, additionalHeaders: nil)
        let call = APICall(session: session!, request: request)
        var returnedResponse: User?
        var returnedError: NSError?
        
        call.executeRespondWithObject{ (data, error) -> () in
            returnedResponse = data
            returnedError = error
            self.called = true
        }
        
        self.loopUntilCalled()
        XCTAssertTrue(returnedError != nil)
        XCTAssertTrue(returnedResponse == nil)
    }


    func testSetCookies() {
        
        session!.setSessionCookieValue("test", value: "one")
        let find = session!.session.configuration.HTTPCookieStorage?.cookies?.filter { $0.name == "test"}.first
        XCTAssertTrue(find != nil)
        XCTAssertTrue(find!.name == "test")
        
        session!.setSessionCookieValue("test", value: nil)
        let notfind = session!.session.configuration.HTTPCookieStorage?.cookies?.filter { $0.name == "test"}.first
        XCTAssertTrue(notfind == nil)
    }
    
    func testResetSession() {
        MockedRESTCalls.hijackUserDelete()
        let existingUser = MockedRESTCalls.sampleUsers()[1]
        let endpointUrl = URLAndParameters(url: "api/Users")
        let endpoint = APIEndpoint.DELETE(endpointUrl)
        let parser = APIJSONSerializableResponseParser<User>()
        let encoder = APIJSONBodyEncoder(model: existingUser)
        let request = APIRequest(baseURL: session!.baseURL, endpoint: endpoint, bodyEncoder: encoder, responseParser: parser, additionalHeaders: nil)
        let call = APICall(session: session!, request: request)
        var returnedResponse: User?
        var returnedError: NSError?
        var executeReturned = false
        var resetReturned = false
        
        call.executeRespondWithObject{ (data, error) -> () in
            returnedResponse = data
            returnedError = error
            executeReturned = true
            self.called = executeReturned && resetReturned
        }
        
        self.session!.reset { () -> () in
            resetReturned = true
            self.called = executeReturned && resetReturned
        }
        
        self.loopUntilCalled()
        
        XCTAssertTrue(returnedResponse == nil)
        XCTAssertTrue(returnedError != nil)
    }
}