//
//  TestAPISiteSerialization.swift
//  CEVFoundation
//
//  Created by Ravi Desai on 9/21/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
import CEVFoundation
import CEVMobile

class TestAPISiteSerialization: XCTestCase {
    
    func testSiteConvertToJSON() {
        let site = APISite();
        site.name = "Apple"
        site.uri = NSURL(string: "http://www.apple.com")
        site.minimumAppVersion = "0.1.1"
        site.touchIdAllowed = true
        
        let dict = site.convertToJSON()
        XCTAssertTrue(dict["Name"] as? String == .Some("Apple"))
        XCTAssertTrue(dict["Uri"] as? String == .Some("http://www.apple.com"))
        XCTAssertTrue(dict["MinimumAppVersion"] as? String == .Some("0.1.1"))
        XCTAssertTrue(dict["TouchIdAllowed"] as? NSNumber == .Some(NSNumber(bool: true)))
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
        XCTAssertTrue(site!.uri.absoluteString == "http://www.apple.com/")
        XCTAssertTrue(site!.minimumAppVersion == "0.1.1")
        XCTAssertTrue(site!.touchIdAllowed == true)
    }
}