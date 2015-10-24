//
//  RESTResponseTests.swift
//  Chat
//
//  Created by Ravi Desai on 4/23/15.
//  Copyright (c) 2015 CEV. All rights reserved.
//

import UIKit
import XCTest
import CEVFoundation

class RestResponseTests: XCTestCase {
    
    func testSystemFailure() {
        let err = NSError(domain: "Domain", code: 99, userInfo: [NSLocalizedDescriptionKey: "My Error"])
        let response = NetworkResponse.SystemFailure(err)
        XCTAssertEqual("\(response)", "General system failure: My Error")
    }
    
    func testCouldNotConnectFailure() {
        let response = NetworkResponse.CouldNotConnectToURL("garbage~url")
        XCTAssertEqual("\(response)", "Could not connect to URL: garbage~url")
    }
    
    func testHTTPStatusCodeFailure() {
        let response = NetworkResponse.HTTPStatusCodeFailure(401, "Unauthorized")
        XCTAssertEqual("\(response)", "HTTP status code 401 indicated failure: Unauthorized")
    }
        
    func testSuccess() {
        let response = NetworkResponse.Success(200, "OK", nil)
        XCTAssertEqual("\(response)", "Success(200): OK")
    }
    
}
