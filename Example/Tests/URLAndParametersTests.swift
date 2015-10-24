//
//  URLAndParametersTests.swift
//  Chat
//
//  Created by Ravi Desai on 4/23/15.
//  Copyright (c) 2015 CEV. All rights reserved.
//

import UIKit
import XCTest
import RSDRESTServices

class URLAndParametersTests: XCTestCase {
    func testWithNoParameters() {
        let urlAndParams = URLAndParameters(
            url: "https://itunes.apple.com/")
        XCTAssertEqual(urlAndParams.description, "https://itunes.apple.com/")
    }
    
    func testWithOneParameter() {
        let urlAndParams = URLAndParameters(
            url: "https://itunes.apple.com/search",
            parameters: (name: "term", value: "Floyd"))
        XCTAssertEqual(urlAndParams.description, "https://itunes.apple.com/search?term=Floyd")
    }
    
    func testWithTwoParameters() {
        let urlAndParams = URLAndParameters(
            url: "https://itunes.apple.com/search",
            parameters: (name: "term", value: "Pink"), (name: "nextTerm", value: "Floyd"))
        XCTAssertEqual(urlAndParams.description, "https://itunes.apple.com/search?term=Pink&nextTerm=Floyd")
    }
    
    func testWithTwoParametersPlaysNiceWithInterpolation() {
        let urlAndParams = URLAndParameters(
            url: "https://itunes.apple.com/search",
            parameters: (name: "term", value: "Pink"), (name: "nextTerm", value: "Floyd"))
        
        XCTAssertEqual("\(urlAndParams)", "https://itunes.apple.com/search?term=Pink&nextTerm=Floyd")
    }
}
