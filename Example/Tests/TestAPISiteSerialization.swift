//
//  TestAPISiteSerialization.swift
//  CEVFoundation
//
//  Created by Ravi Desai on 9/21/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
import RSDRESTServices
import RSDSerialization

class TestAPISiteSerialization: XCTestCase {
    
    func testSiteConvertToJSON() {
        let site = APISite(name: "Apple", uri: "http://www.apple.com")
        
        let dict = site.convertToJSON()
        XCTAssertTrue(dict["Name"] as? String == .Some("Apple"))
        XCTAssertTrue(dict["Uri"] as? String == .Some("http://www.apple.com"))
    }
    
    func testSiteCreate() {
        var jsonDictionary = JSONDictionary()
        jsonDictionary["Name"] = "Apple"
        jsonDictionary["Uri"] = "http://www.apple.com/"
        jsonDictionary["MinimumAppVersion"] = "0.1.1"
        jsonDictionary["TouchIdAllowed"] = NSNumber(bool: true)
        
        let site = APISite.createFromJSON(jsonDictionary)
        XCTAssertTrue(site != nil)
        XCTAssertTrue(site!.name == "Apple")
        XCTAssertTrue(site!.uri != nil)
        XCTAssertTrue(site!.uri?.absoluteString == .Some("http://www.apple.com/"))
    }
}