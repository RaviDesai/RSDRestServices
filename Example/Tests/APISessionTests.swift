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
    var session: APISession?
    var loginSite = APISite(name: "Sample", uri: "https://org.rsd.sample/WebClient/")
    
    override func setUp() {
        super.setUp();
    }
    
    override func tearDown() {
        OHHTTPStubs.removeAllStubs();
        super.tearDown();
    }
    
    func loopUntilCalled() {
        while (!self.called) {
            self.runLoop.runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0.1));
        }
    }
    
    func testLogin() {
        MockedRESTCalls.hijackLoginSequence(loginSite)

        var returnedError: NSError?
        
        APIConsumersClient.sharedClient.authenticate(self.loginSite, username: "Admin", password:"Admin", completion: { (error) -> () in
            self.called = true
            returnedError = error
        })
            
        
        loopUntilCalled()
        XCTAssertTrue(returnedError == nil)
    }
    
    func testRestCallToiTunes() {
        self.loginSite.uri = NSURL(string: "https://itunes.apple.com/");
        self.session = APISession(site: self.loginSite, configurationBlock: nil)
        
        let endpointUrl = URLAndParameters(url: "search", parameters: ("term", "Pink+Floyd"))
        let endpoint = APIEndpoint(method: "GET", url: endpointUrl)
        let parser = APIDataResponseParser()
        let request = APIRequest(baseURL: self.session?.baseURL, endpoint: endpoint, bodyEncoder: nil, responseParser: parser, additionalHeaders: nil)
        let call = APICall(session: self.session!, request: request)
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

}