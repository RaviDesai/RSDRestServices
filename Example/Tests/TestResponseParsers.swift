//
//  TestResponseParsers.swift
//  RSDRESTServices
//
//  Created by Ravi Desai on 10/26/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
import RSDRESTServices
import RSDSerialization

class TestResponseParsers: XCTestCase {
    
    func testAPIDataResponseParser() {
        let users = [User(id: NSUUID(), prefix: nil, first: "Ravi", middle: "S", last: "Desai", suffix: nil), User(id: NSUUID(), prefix: "Mrs", first: "Bonnie", middle: "J", last: "Desai", suffix: nil)]

        let singleUserData = try! NSJSONSerialization.dataWithJSONObject(users[0].convertToJSON(), options: NSJSONWritingOptions.PrettyPrinted)
        
        let parser = APIDataResponseParser()
        
        let response = NetworkResponse.Success(200, "ok", singleUserData)
        let (singleResult, singleError) = parser.Parse(response)
        let (arrayResult, arrayError) = parser.ParseToArray(response)
        
        XCTAssertTrue(singleResult != nil)
        XCTAssertTrue(singleError == nil)
        XCTAssertTrue(arrayResult != nil)
        XCTAssertTrue(arrayResult!.count == 1)
        XCTAssertTrue(arrayError == nil)
        
        XCTAssertTrue(singleUserData == singleResult!)
        XCTAssertTrue(singleResult! == arrayResult![0])
    }
    
    func testAPIJSONSerializationResponseParser() {
        let users = [User(id: NSUUID(), prefix: nil, first: "Ravi", middle: "S", last: "Desai", suffix: nil), User(id: NSUUID(), prefix: "Mrs", first: "Bonnie", middle: "J", last: "Desai", suffix: nil)]

        let singleUserData = try! NSJSONSerialization.dataWithJSONObject(users[0].convertToJSON(), options: NSJSONWritingOptions.PrettyPrinted)
        let multiUserData = try! NSJSONSerialization.dataWithJSONObject(users.convertToJSONArray(), options: NSJSONWritingOptions.PrettyPrinted)
        
        let parser = APIJSONSerializableResponseParser<User>()
        
        let singleResponse = NetworkResponse.Success(200, "ok", singleUserData)
        let multiResponse = NetworkResponse.Success(200, "ok", multiUserData)
        
        let (singleResult, singleError) = parser.Parse(singleResponse)
        let (multiResult, multiError) = parser.ParseToArray(multiResponse)
        
        XCTAssertTrue(singleResult != nil)
        XCTAssertTrue(singleError == nil)
        
        XCTAssertTrue(multiResult != nil)
        XCTAssertTrue(multiError == nil)
        
        XCTAssertTrue(singleResult! == users[0])
        XCTAssertTrue(multiResult! == users)
    }

    func testAPIJSONSerializationResponseParserFailsReversingArrayWithSingle() {
        let users = [User(id: NSUUID(), prefix: nil, first: "Ravi", middle: "S", last: "Desai", suffix: nil), User(id: NSUUID(), prefix: "Mrs", first: "Bonnie", middle: "J", last: "Desai", suffix: nil)]
        
        let singleUserData = try! NSJSONSerialization.dataWithJSONObject(users[0].convertToJSON(), options: NSJSONWritingOptions.PrettyPrinted)
        let multiUserData = try! NSJSONSerialization.dataWithJSONObject(users.convertToJSONArray(), options: NSJSONWritingOptions.PrettyPrinted)
        
        let parser = APIJSONSerializableResponseParser<User>()
        
        let singleResponse = NetworkResponse.Success(200, "ok", multiUserData)
        let multiResponse = NetworkResponse.Success(200, "ok", singleUserData)
        
        let (singleResult, singleError) = parser.Parse(singleResponse)
        let (multiResult, multiError) = parser.ParseToArray(multiResponse)
        
        XCTAssertTrue(singleResult == nil)
        XCTAssertTrue(singleError != nil)
        
        XCTAssertTrue(multiResult == nil)
        XCTAssertTrue(multiError != nil)
    }

    func testAPIJSONSerializationResponseParserFailsWrongType() {
        let users = [User(id: NSUUID(), prefix: nil, first: "Ravi", middle: "S", last: "Desai", suffix: nil), User(id: NSUUID(), prefix: "Mrs", first: "Bonnie", middle: "J", last: "Desai", suffix: nil)]
        
        let singleUserData = try! NSJSONSerialization.dataWithJSONObject(users[0].convertToJSON(), options: NSJSONWritingOptions.PrettyPrinted)
        let multiUserData = try! NSJSONSerialization.dataWithJSONObject(users.convertToJSONArray(), options: NSJSONWritingOptions.PrettyPrinted)
        
        let parserForSite = APIJSONSerializableResponseParser<APISite>()
        
        let singleResponse = NetworkResponse.Success(200, "ok", singleUserData)
        let multiResponse = NetworkResponse.Success(200, "ok", multiUserData)
        
        let (singleResult, singleError) = parserForSite.Parse(singleResponse)
        let (multiResult, multiError) = parserForSite.ParseToArray(multiResponse)
        
        XCTAssertTrue(singleResult == nil)
        XCTAssertTrue(singleError != nil)
        
        XCTAssertTrue(multiResult != nil)
        XCTAssertTrue(multiResult!.count == 0)
        XCTAssertTrue(multiError == nil)
    }

    
    func testAPIObjectResponseParser() {
        let arrayOfInts = "[ 12, 13, 14 ]"
        let singleInt = "12"
        
        let singleIntData = singleInt.dataUsingEncoding(NSUTF8StringEncoding)!
        let multiIntData = arrayOfInts.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let parser = APIObjectResponseParser<Int>()
        
        let singleResponse = NetworkResponse.Success(200, "ok", singleIntData)
        let multiResponse = NetworkResponse.Success(200, "ok", multiIntData)
        
        let (singleResult, singleError) = parser.Parse(singleResponse)
        let (multiResult, multiError) = parser.ParseToArray(multiResponse)
        
        XCTAssertTrue(singleResult != nil)
        XCTAssertTrue(singleError == nil)
        
        XCTAssertTrue(multiResult != nil)
        XCTAssertTrue(multiResult!.count == 3)
        XCTAssertTrue(multiError == nil)
        
        XCTAssertTrue(singleResult! == 12)
        XCTAssertTrue(multiResult! == [12, 13, 14])
    }
    
    func testAPIObjectResponseParserFailsReversingArrayWithSingle() {
        let arrayOfInts = "[ 12, 13, 14 ]"
        let singleInt = "12"
        
        let singleIntData = singleInt.dataUsingEncoding(NSUTF8StringEncoding)!
        let multiIntData = arrayOfInts.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let parser = APIObjectResponseParser<Int>()
        
        let singleResponse = NetworkResponse.Success(200, "ok", multiIntData)
        let multiResponse = NetworkResponse.Success(200, "ok", singleIntData)
        
        let (singleResult, singleError) = parser.Parse(singleResponse)
        let (multiResult, multiError) = parser.ParseToArray(multiResponse)
        
        XCTAssertTrue(singleResult == nil)
        XCTAssertTrue(singleError != nil)
        
        XCTAssertTrue(multiResult == nil)
        XCTAssertTrue(multiError != nil)
    }

    func testAPIObjectResponseParserFailsWrongType() {
        let arrayOfNotInts = "[ \"hello\", \"there\", \"you\" ]"
        let singleNotInt = "\"hello\""
        
        let singleNotIntData = singleNotInt.dataUsingEncoding(NSUTF8StringEncoding)!
        let multiNotIntData = arrayOfNotInts.dataUsingEncoding(NSUTF8StringEncoding)!
        
        let parser = APIObjectResponseParser<Int>()
        
        let singleResponse = NetworkResponse.Success(200, "ok", singleNotIntData)
        let multiResponse = NetworkResponse.Success(200, "ok", multiNotIntData)
        
        let (singleResult, singleError) = parser.Parse(singleResponse)
        let (multiResult, multiError) = parser.ParseToArray(multiResponse)
        
        XCTAssertTrue(singleResult == nil)
        XCTAssertTrue(singleError != nil)
        
        XCTAssertTrue(multiResult != nil)
        XCTAssertTrue(multiResult!.count == 0)
        XCTAssertTrue(multiError == nil)
    }

}
