//
//  MockedRESTCalls.swift
//  CEVFoundation
//
//  Created by Ravi Desai on 4/29/15.
//  Copyright (c) 2015 CEV. All rights reserved.
//

import Foundation
import OHHTTPStubs
import RSDRESTServices

public class MockedRESTCalls {
    public static func sampleITunesResultData() -> NSData {
        let bundle : NSBundle = NSBundle(forClass: self)
        let path = bundle.pathForResource("iTunesResults", ofType: "json")!
        let content = NSData(contentsOfFile: path)
        return content!;
    }
    
    public static func sampleFrontDoorData() -> NSData {
        let bundle : NSBundle = NSBundle(forClass: self)
        let path = bundle.pathForResource("FrontDoorSample", ofType: "json")!
        let content = NSData(contentsOfFile: path)
        return content!;
    }
    
    public static func sampleAuthenticateData() -> NSData {
        return "{\"Success\":true,\"Message\":null,\"Parameters\":{\"wa\":\"wsignin1.0\",\"wresult\":\"<crazyweirdxml></crazyweirdxml>\"}}".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    }
    
    public static func sampleAuthenticationTokenData() -> NSData {
        return "\"success\"".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    }

    public class func hijackITunesSearch() {
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            if (request.URL?.host != "itunes.apple.com") { return false; }
            if (request.URL?.path != "/search") { return false; }
            
            return true;
        }, withStubResponse: { (request) -> OHHTTPStubsResponse in
                let data = self.sampleITunesResultData()
                return OHHTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json"])
        })
    }
    
    
    public static func hijackLoginSequence(loginSite: APISite) {
        let host: String? = loginSite.uri?.host
        
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            if (request.URL?.host != host) {
                return false
            }
            if (request.URL?.path != .Some("/WebClient/api/authentication/authenticate")) {
                return false
            }
            if (request.HTTPMethod != "POST") {
                return false
            }
            let requestData = NSURLProtocol.propertyForKey("PostedData", inRequest: request) as? NSData
            if (requestData == nil) {
                return false
            }
            
            return true
        }, withStubResponse: { (request) -> OHHTTPStubsResponse in
            let response = self.sampleAuthenticateData()
            return OHHTTPStubsResponse(data: response, statusCode: 200, headers: ["Content-Type": "application/json"])
        })
        
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            if (request.URL?.host != host) {
                return false
            }
            if (request.URL?.path != .Some("/WebClient/api/authentication/authenticationtoken")) {
                return false
            }
            if (request.HTTPMethod != "POST") {
                return false
            }
            let contentType = request.allHTTPHeaderFields?["Content-Type"]
            if (contentType != .Some("application/x-www-form-urlencoded")) {
                return false
            }
            let requestData = NSURLProtocol.propertyForKey("PostedData", inRequest: request) as? NSData
            if (requestData == nil) {
                return false
            }
            return true;
        }, withStubResponse: { (request) -> OHHTTPStubsResponse in
            let response = self.sampleAuthenticationTokenData()
            return OHHTTPStubsResponse(data: response, statusCode: 200, headers: ["Content-Type": "text/plain"])
        })
        
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            if (request.URL?.host != host) {
                return false
            }
            if (request.URL?.path != .Some("/WebClient/PostLogin/PostLoginChecks")) {
                return false
            }
            if (request.HTTPMethod != "GET") {
                return false
            }
            
            return true
        }, withStubResponse: { (request) -> OHHTTPStubsResponse in
            let expiryDate = NSDate(timeIntervalSinceNow: 2629743)
            let myhost: String = host ?? ""
            let cookieProperties: [String: AnyObject] = [NSHTTPCookieValue: "true", NSHTTPCookieName: "PassedPostLoginChecks", NSHTTPCookiePath: "/", NSHTTPCookieDomain: myhost, NSHTTPCookieOriginURL: myhost, NSHTTPCookieExpires: expiryDate]
            let cookie = NSHTTPCookie(properties: cookieProperties)
            let mockedCookies = [cookie!]
            NSHTTPCookieStorage.sharedHTTPCookieStorage().setCookies(mockedCookies, forURL: loginSite.uri, mainDocumentURL: nil)
            
            let postedCheckData = "<!DOCTYPE html><html><body><p>weird html page</p></body></html>".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
            return OHHTTPStubsResponse(data: postedCheckData, statusCode: 200, headers: ["Content-Type": "text/html"])
        })
        
    }
}