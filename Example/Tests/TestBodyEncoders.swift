//
//  TestBodyEncoders.swift
//  RSDRESTServices
//
//  Created by Ravi Desai on 10/26/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
import RSDRESTServices
import RSDSerialization

class TestBodyEncoders: XCTestCase {

    func testMultipart() {
        let user = User(id: NSUUID(), prefix: nil, first: "Ravi", middle: "S", last: "Desai", suffix: nil)
        let data = try! NSJSONSerialization.dataWithJSONObject(user.convertToJSON(), options: NSJSONWritingOptions.PrettyPrinted)

        let postedData = APIPostData(filename: "users.json", mediaType: "application/json", body: data, parameters: nil)
        
        let bodyEncoder = APIMultipartBodyEncoder(postData: [postedData])
        
        XCTAssertTrue(bodyEncoder.contentType() == "multipart/form-data boundary=----------V2ymHFg03ehbqgZCaKO6jy")
        let encodedData = bodyEncoder.body()
        XCTAssertTrue(encodedData != nil)
        
        var multipartStuff = encodedData!.multipartArray()
        XCTAssertTrue(multipartStuff.count > 0)
        
        let multipartDict = multipartStuff[0] as? NSDictionary
        XCTAssertTrue(multipartDict != nil)

        let multipartData = multipartDict!["data"] as? NSData
        XCTAssertTrue(multipartData != nil)
        
        let attachmentName: String = (multipartDict!["filename"] as? String) ?? ""
        let mediaType: String = (multipartDict!["Content-Type"] as? String) ?? ""
        let size = multipartData!.length
        
        XCTAssertTrue(attachmentName == "users.json")
        XCTAssertTrue(mediaType == "application/json")
        XCTAssertTrue(size == 109)
        
        let json = try! NSJSONSerialization.JSONObjectWithData(multipartData!, options: NSJSONReadingOptions.AllowFragments)
        let deserializedUser = User.createFromJSON(json)!
        XCTAssertTrue(deserializedUser == user)
    }
    
    func testJSON() {
        let user = User(id: NSUUID(), prefix: nil, first: "Ravi", middle: "S", last: "Desai", suffix: nil)

        let bodyEncoder = APIJSONBodyEncoder(model: user)

        let encodedData = bodyEncoder.body()
        let contentType = bodyEncoder.contentType()
        
        XCTAssertTrue(contentType == "application/json")
        XCTAssertTrue(encodedData != nil)
        
        let json = try! NSJSONSerialization.JSONObjectWithData(encodedData!, options: NSJSONReadingOptions.AllowFragments)
        let deserializedUser = User.createFromJSON(json)!
        XCTAssertTrue(deserializedUser == user)
    }
    
    func testURLBodyEncoder() {
        let user = User(id: nil, prefix: nil, first: "Ravi", middle: "S", last: "Desai", suffix: nil)
        
        let bodyEncoder = APIURLBodyEncoder(model: user)
        
        let encodedData = bodyEncoder.body()
        let contentType = bodyEncoder.contentType()
        
        XCTAssertTrue(contentType == "application/x-www-form-urlencoded")
        XCTAssertTrue(encodedData != nil)
        
        let urlEncoded = String(data: encodedData!, encoding: NSUTF8StringEncoding)
        
        XCTAssertTrue(urlEncoded!.containsString("Middle=S"))
        XCTAssertTrue(urlEncoded!.containsString("First=Ravi"))
        XCTAssertTrue(urlEncoded!.containsString("Last=Desai"))
    }

}