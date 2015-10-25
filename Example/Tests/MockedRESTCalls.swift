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
    
    
}