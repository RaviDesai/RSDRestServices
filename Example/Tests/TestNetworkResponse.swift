//
//  TestNetworkResponse.swift
//  RSDRESTServices
//
//  Created by Ravi Desai on 10/26/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
import RSDRESTServices
import RSDSerialization

class TestNetworkResponse: XCTestCase {
    func testDescription() {
        var response = NetworkResponse.CouldNotConnectToURL("http://www.apple.com")
        XCTAssertTrue("\(response)" == "Could not connect to URL: http://www.apple.com")
        response = NetworkResponse.HTTPStatusCodeFailure(400, "unauthorized")
        XCTAssertTrue("\(response)" == "HTTP status code 400 indicated failure: unauthorized")
        response = NetworkResponse.NetworkFailure
        XCTAssertTrue("\(response)" == "Network failure")
        response = NetworkResponse.Success(200, "OK", nil)
        XCTAssertTrue("\(response)" == "Success(200): OK")
        
        let message = "squirrel"
        let userInfo = [NSLocalizedDescriptionKey:message, NSLocalizedFailureReasonErrorKey: message];
        let err = NSError(domain: "com.desai", code: 48118000, userInfo: userInfo)
        response = NetworkResponse.SystemFailure(err)
        XCTAssertTrue("\(response)" == "General system failure: squirrel")
        
        response = NetworkResponse.Undetermined
        XCTAssertTrue("\(response)" == "Undetermined response")
    }
    
    func testIsAndDidFunctions() {
        var response = NetworkResponse.CouldNotConnectToURL("http://www.apple.com")
        XCTAssertTrue(response.didFail())
        XCTAssertFalse(response.didSucceed())
        XCTAssertFalse(response.isBadRequest())
        XCTAssertFalse(response.isNetworkFailure())
        XCTAssertFalse(response.isUnauthorized())
        XCTAssertFalse(response.isUndetermined())
        
        response = NetworkResponse.HTTPStatusCodeFailure(400, "bad")
        XCTAssertTrue(response.didFail())
        XCTAssertFalse(response.didSucceed())
        XCTAssertTrue(response.isBadRequest())
        XCTAssertFalse(response.isNetworkFailure())
        XCTAssertFalse(response.isUnauthorized())
        XCTAssertFalse(response.isUndetermined())
        response = NetworkResponse.HTTPStatusCodeFailure(401, "unauthorized")
        XCTAssertTrue(response.didFail())
        XCTAssertFalse(response.didSucceed())
        XCTAssertFalse(response.isBadRequest())
        XCTAssertFalse(response.isNetworkFailure())
        XCTAssertTrue(response.isUnauthorized())
        XCTAssertFalse(response.isUndetermined())
        response = NetworkResponse.HTTPStatusCodeFailure(402, "whatever")
        XCTAssertTrue(response.didFail())
        XCTAssertFalse(response.didSucceed())
        XCTAssertFalse(response.isBadRequest())
        XCTAssertFalse(response.isNetworkFailure())
        XCTAssertFalse(response.isUnauthorized())
        XCTAssertFalse(response.isUndetermined())

        
        response = NetworkResponse.NetworkFailure
        XCTAssertTrue(response.didFail())
        XCTAssertFalse(response.didSucceed())
        XCTAssertFalse(response.isBadRequest())
        XCTAssertTrue(response.isNetworkFailure())
        XCTAssertFalse(response.isUnauthorized())
        XCTAssertFalse(response.isUndetermined())

        response = NetworkResponse.Success(200, "OK", nil)
        XCTAssertFalse(response.didFail())
        XCTAssertTrue(response.didSucceed())
        XCTAssertFalse(response.isBadRequest())
        XCTAssertFalse(response.isNetworkFailure())
        XCTAssertFalse(response.isUnauthorized())
        XCTAssertFalse(response.isUndetermined())
        
        let message = "squirrel"
        let userInfo = [NSLocalizedDescriptionKey:message, NSLocalizedFailureReasonErrorKey: message];
        let err = NSError(domain: "com.desai", code: 48118000, userInfo: userInfo)
        response = NetworkResponse.SystemFailure(err)
        XCTAssertTrue(response.didFail())
        XCTAssertFalse(response.didSucceed())
        XCTAssertFalse(response.isBadRequest())
        XCTAssertFalse(response.isNetworkFailure())
        XCTAssertFalse(response.isUnauthorized())
        XCTAssertFalse(response.isUndetermined())
        
        response = NetworkResponse.Undetermined
        XCTAssertTrue(response.didFail())
        XCTAssertFalse(response.didSucceed())
        XCTAssertFalse(response.isBadRequest())
        XCTAssertFalse(response.isNetworkFailure())
        XCTAssertFalse(response.isUnauthorized())
        XCTAssertTrue(response.isUndetermined())
    }
    
    func testGetData() {
        var response = NetworkResponse.CouldNotConnectToURL("http://www.apple.com")
        XCTAssertTrue(response.getData() == nil)
        
        response = NetworkResponse.HTTPStatusCodeFailure(400, "unauthorized")
        XCTAssertTrue(response.getData() == nil)
        
        response = NetworkResponse.NetworkFailure
        XCTAssertTrue(response.getData() == nil)
        
        let data = NSData()
        response = NetworkResponse.Success(200, "OK", data)
        XCTAssertTrue(response.getData() == data)
        
        let message = "squirrel"
        let userInfo = [NSLocalizedDescriptionKey:message, NSLocalizedFailureReasonErrorKey: message];
        let err = NSError(domain: "com.desai", code: 48118000, userInfo: userInfo)
        response = NetworkResponse.SystemFailure(err)
        XCTAssertTrue(response.getData() == nil)
        
        response = NetworkResponse.Undetermined
        XCTAssertTrue(response.getData() == nil)
    }
    
    func testGetJSON() {
        var response = NetworkResponse.CouldNotConnectToURL("http://www.apple.com")
        var (json, error) = response.getJSON()
        XCTAssertTrue(json == nil)
        XCTAssertTrue(error != nil)
        
        response = NetworkResponse.HTTPStatusCodeFailure(400, "unauthorized")
        (json, error) = response.getJSON()
        XCTAssertTrue(json == nil)
        XCTAssertTrue(error != nil)
        
        response = NetworkResponse.NetworkFailure
        (json, error) = response.getJSON()
        XCTAssertTrue(json == nil)
        XCTAssertTrue(error != nil)
        
        let dict = ["key": "value"]
        let jsonDict: JSONDictionary = dict
        let jsonValue: JSON = jsonDict
        let data = try! NSJSONSerialization.dataWithJSONObject(jsonValue, options: NSJSONWritingOptions.PrettyPrinted)
        response = NetworkResponse.Success(200, "OK", data)
        (json, error) = response.getJSON()
        XCTAssertTrue(json != nil)
        XCTAssertTrue(json!.count == 1)
        XCTAssertTrue(error == nil)
        
        let message = "squirrel"
        let userInfo = [NSLocalizedDescriptionKey:message, NSLocalizedFailureReasonErrorKey: message];
        let err = NSError(domain: "com.desai", code: 48118000, userInfo: userInfo)
        response = NetworkResponse.SystemFailure(err)
        (json, error) = response.getJSON()
        XCTAssertTrue(json == nil)
        XCTAssertTrue(error != nil)
        
        response = NetworkResponse.Undetermined
        (json, error) = response.getJSON()
        XCTAssertTrue(json == nil)
        XCTAssertTrue(error == nil)
        
    }
}