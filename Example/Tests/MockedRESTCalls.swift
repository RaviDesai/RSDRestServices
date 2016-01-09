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
import RSDSerialization

class MockedRESTCalls {
    static var id0 = NSUUID()
    static var id1 = NSUUID()
    static var id2 = NSUUID()
    static var id3 = NSUUID()
    static var id4 = NSUUID()

    static func sampleITunesResultData() -> NSData {
        let bundle : NSBundle = NSBundle(forClass: self)
        let path = bundle.pathForResource("iTunesResults", ofType: "json")!
        let content = NSData(contentsOfFile: path)
        return content!;
    }
    
    static func sampleUsers() -> [User] {
        return [User(id: id0, prefix: "Sir", first: "David", middle: "Jon", last: "Gilmour", suffix: "CBE"),
                User(id: id1, prefix: nil, first: "Roger", middle: nil, last: "Waters", suffix: nil),
                User(id: id2, prefix: "Sir", first: "Bob", middle: nil, last: "Geldof", suffix: "KBE"),
                User(id: id3, prefix: "Mr", first: "Nick", middle: "Berkeley", last: "Mason", suffix: nil),
                User(id: id4, prefix: "", first: "Richard", middle: "William", last: "Wright", suffix: "")]
    }
    
    static func sampleUsersData() -> NSData {
        let jsonArray = MockedRESTCalls.sampleUsers().convertToJSONArray()
        return try! NSJSONSerialization.dataWithJSONObject(jsonArray, options: NSJSONWritingOptions.PrettyPrinted)
    }
    
    class func hijackITunesSearch() {
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            if (request.URL?.host != "itunes.apple.com") { return false; }
            if (request.URL?.path != "/search") { return false; }
            
            return true;
        }, withStubResponse: { (request) -> OHHTTPStubsResponse in
            let data = self.sampleITunesResultData()
            return OHHTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json"])
        })
    }

    class func hijackUserGetAll() {
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            if (request.URL?.host != .Some("com.desai")) { return false }
            if (request.URL?.path != .Some("/api/Users")) { return false }
            if (request.HTTPMethod != "GET") { return false }
            if (request.URL?.query != nil) { return false }
            return true
            }) { (request) -> OHHTTPStubsResponse in
                let data = sampleUsersData()
                return OHHTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
    }

    class func hijackUserGet() {
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            if (request.URL?.host != .Some("com.desai")) { return false }
            if (request.URL?.path != .Some("/api/Users")) { return false }
            if (request.HTTPMethod != "GET") { return false }
            if (request.URL?.query != nil) { return false }
            return true
        }) { (request) -> OHHTTPStubsResponse in
            let data = sampleUsersData()
            return OHHTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json"])
        }
    }
    
    class func hijackUserGetMatching() {

        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            if (request.URL?.host != .Some("com.desai")) { return false }
            if (request.URL?.path != .Some("/api/Users")) { return false }
            if (request.HTTPMethod != "GET") { return false }
            if (request.URL?.query == nil) { return false }
            return true
        }) { (request) -> OHHTTPStubsResponse in
            var query = request.URL!.absoluteString
            query = query.stringByRemovingPercentEncoding!

            let comp = NSURLComponents(string: query)
            let items = comp!.queryItems!
            var users = sampleUsers()
            for item in items {
                users = users.filter {
                    switch(item.name.lowercaseString) {
                    case "prefix": return $0.prefix == item.value
                    case "first": return $0.first == item.value
                    case "middle": return $0.middle == item.value
                    case "last": return $0.last == item.value
                    case "suffix": return $0.prefix == item.value
                    default: return false
                    }
                }
            }
            let jsonArray = users.convertToJSONArray()
            if let data = try? NSJSONSerialization.dataWithJSONObject(jsonArray, options: NSJSONWritingOptions.PrettyPrinted) {
                return OHHTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type": "application/json"])
            }
            return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 500, headers: nil)
        }
    }
    
    class func hijackUserPost() {
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            if (request.URL?.host != .Some("com.desai")) { return false }
            if (request.URL?.path != .Some("/api/Users")) { return false }
            if (request.HTTPMethod != "POST") { return false }
            if (request.URL?.query != nil) { return false }
            return true
        }) { (request) -> OHHTTPStubsResponse in
            if let data = NSURLProtocol.propertyForKey("PostedData", inRequest: request) as? NSData {
                if let json: JSON = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) {
                    if let newUser = User.createFromJSON(json) {
                        let found = sampleUsers().filter { $0 == newUser }.first
                        if found == nil {
                            var returnUser = newUser
                            returnUser.id = NSUUID()
                            if let resultData = try? NSJSONSerialization.dataWithJSONObject(returnUser.convertToJSON(), options: NSJSONWritingOptions.PrettyPrinted) {
                                return OHHTTPStubsResponse(data: resultData, statusCode: 200, headers: ["Content-Type": "application/json"])
                            } else {
                                return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 500, headers: nil)
                            }
                        } else {
                            return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 409, headers: nil)
                        }
                    }
                }
            }
            return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 422, headers: nil)
        }

    }

    class func hijackUserPut() {
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            if (request.URL?.host != .Some("com.desai")) { return false }
            if (request.URL?.path != .Some("/api/Users")) { return false }
            if (request.HTTPMethod != "PUT") { return false }
            if (request.URL?.query != nil) { return false }
            return true
        }) { (request) -> OHHTTPStubsResponse in
                if let data = NSURLProtocol.propertyForKey("PostedData", inRequest: request) as? NSData {
                    if let json: JSON = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) {
                        if let newUser = User.createFromJSON(json) {
                            if (newUser.id == nil) {
                                return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 404, headers: nil)
                            }
                            let found = sampleUsers().filter { $0 == newUser }.first
                            if found != nil {
                                if let resultData = try? NSJSONSerialization.dataWithJSONObject(newUser.convertToJSON(), options: NSJSONWritingOptions.PrettyPrinted) {
                                    return OHHTTPStubsResponse(data: resultData, statusCode: 200, headers: ["Content-Type": "application/json"])
                                } else {
                                    return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 500, headers: nil)
                                }
                            } else {
                                return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 404, headers: nil)
                            }
                        }
                    }
                }
                return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 422, headers: nil)
        }
        
    }

    class func hijackUserDelete() {
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            if (request.URL?.host != .Some("com.desai")) { return false }
            if (request.URL?.path != .Some("/api/Users")) { return false }
            if (request.HTTPMethod != "DELETE") { return false }
            if (request.URL?.query != nil) { return false }
            return true
            }) { (request) -> OHHTTPStubsResponse in
                if let data = NSURLProtocol.propertyForKey("PostedData", inRequest: request) as? NSData {
                    if let json: JSON = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) {
                        if let newUser = User.createFromJSON(json) {
                            if (newUser.id == nil) {
                                return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 404, headers: nil)
                            }
                            let found = sampleUsers().filter { $0 == newUser }.first
                            if found != nil {
                                if let resultData = try? NSJSONSerialization.dataWithJSONObject(newUser.convertToJSON(), options: NSJSONWritingOptions.PrettyPrinted) {
                                    return OHHTTPStubsResponse(data: resultData, statusCode: 200, headers: ["Content-Type": "application/json"])
                                } else {
                                    return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 500, headers: nil)
                                }
                            } else {
                                return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 404, headers: nil)
                            }
                        }
                    }
                }
                return OHHTTPStubsResponse(JSONObject: JSONDictionary(), statusCode: 422, headers: nil)
        }
        
    }

}