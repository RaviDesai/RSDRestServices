//
//  TestAPISite.swift
//  RSDRESTServices
//
//  Created by Ravi Desai on 10/26/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
import RSDRESTServices
import RSDSerialization

class TestAPISite: XCTestCase {
    func testInit() {
        let site = APISite(name: "Apple", uri: "http://www.apple.com")
        XCTAssertTrue(site.name == "Apple")
        XCTAssertTrue(site.uri == NSURL(string: "http://www.apple.com"))

        let site2 = APISite(name: "Apple", uri: nil)
        XCTAssertTrue(site2.name == "Apple")
        XCTAssertTrue(site2.uri == .None)
    }
    
    func testConvertToJSON() {
        let site = APISite(name: "Apple", uri: "http://www.apple.com")
        XCTAssertTrue(site.name == "Apple")
        XCTAssertTrue(site.uri == NSURL(string: "http://www.apple.com"))

        let json = site.convertToJSON()
        XCTAssertTrue(json.count == 2)
        XCTAssertTrue(json["Name"] as! String == "Apple")
        XCTAssertTrue(json["Uri"] as! String == "http://www.apple.com")
    }
    
    func testCreateFromJSON() {
        let dict = ["Name": "Apple", "Uri": "http://www.apple.com"]
        let jsonDict : JSONDictionary = dict
        let json : JSON = jsonDict
        let site = APISite.createFromJSON(json)
        XCTAssertTrue(site != nil)
        XCTAssertTrue(site!.name == "Apple")
        XCTAssertTrue(site!.uri == NSURL(string: "http://www.apple.com"))
        
        let dict2 = ["Name": "Apple"]
        let jsonDict2 : JSONDictionary = dict2
        let json2 : JSON = jsonDict2
        let site2 = APISite.createFromJSON(json2)
        XCTAssertTrue(site2!.name == "Apple")
        XCTAssertTrue(site2!.uri == nil)
        
        let dict3 = [String: String]()
        let jsonDict3 : JSONDictionary = dict3
        let json3 : JSON = jsonDict3
        let site3 = APISite.createFromJSON(json3)
        XCTAssertTrue(site3 == nil)
        
        let dict4 = ["Name": "Apple", "Uri": NSNumber(double: 3.14)]
        let jsonDict4 : JSONDictionary = dict4
        let json4 : JSON = jsonDict4
        let site4 = APISite.createFromJSON(json4)
        XCTAssertTrue(site4 != nil)
        XCTAssertTrue(site4!.name == "Apple")
        XCTAssertTrue(site4!.uri == nil)
    }
    
    func testLessThan() {
        let sites = [APISite(name: "Beta", uri: "http://www.beta.com"), APISite(name: "Alpha", uri: "http://www.alpha.com"), APISite(name: "Gamma", uri: "http://www.gamma.com")]
        let sortedSites = sites.sort()
        XCTAssertTrue(sortedSites[0].name == "Alpha")
        XCTAssertTrue(sortedSites[1].name == "Beta")
        XCTAssertTrue(sortedSites[2].name == "Gamma")
    }
    
    func testEquality() {
        var site0 = APISite(name: "Alpha", uri: nil)
        var site1 = APISite(name: "Alpha", uri: "http://www.alpha.com")
        
        XCTAssertFalse(site0 == site1)
        
        site1.uri = nil
        XCTAssertTrue(site0 == site1)
        
        site0.uri = NSURL(string: "http://alpha.com")
        site1.uri = NSURL(string: "http://alpha.com")
        XCTAssertTrue(site0 == site1)
        
        site0.name = "Beta"
        XCTAssertFalse(site0 == site1)
    }
}