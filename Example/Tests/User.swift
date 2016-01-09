//
//  User.swift
//  RSDRESTServices
//
//  Created by Ravi Desai on 10/25/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation
import RSDSerialization
@testable import RSDRESTServices

struct User: ModelResource, CustomStringConvertible {
    var id: NSUUID?
    var prefix: String?
    var first: String
    var middle: String?
    var last: String
    var suffix: String?
    
    static var resourceEndpoint = "api/Users"
    
    init(id: NSUUID?, prefix: String?, first: String, middle: String?, last: String, suffix: String?) {
        self.id = id
        self.prefix = prefix
        self.first = first
        self.middle = middle
        self.last = last
        self.suffix = suffix
    }
    
    static func create(id: NSUUID?)(prefix: String?)(first: String)(middle: String?)(last: String)(suffix: String?) -> User {
        return User(id: id, prefix: prefix, first: first, middle: middle, last: last, suffix: suffix)
    }
    
    static func createFromJSON(json: JSON) -> User? {
        if let record = json as? JSONDictionary {
            return User.create
                <**> record["ID"] >>- asUUID
                <**> record["Prefix"] >>- asString
                <*> record["First"] >>- asString
                <**> record["Middle"] >>- asString
                <*> record["Last"] >>- asString
                <**> record["Suffix"] >>- asString
        }
        return nil
    }
    
    func convertToJSON() -> JSONDictionary {
        return JSONDictionary(tuples:
            ("ID", self.id?.UUIDString),
            ("Prefix", self.prefix),
            ("First", self.first),
            ("Middle", self.middle),
            ("Last", self.last),
            ("Suffix", self.suffix))
    }
    
    var description: String {
        var prefix = self.prefix ?? ""
        if (prefix != "") { prefix = "\(prefix) " }
        
        var first = self.first
        if (first != "") { first = "\(first) " }
        
        var middle = self.middle ?? ""
        if (middle != "") { middle = "\(middle) " }

        var last = self.last
        if (last != "") { last = "\(last) " }
        
        let suffix = self.suffix ?? ""
        return "\(prefix)\(first)\(middle)\(last)\(suffix)"
    }
}

func==(lhs: User, rhs: User) -> Bool {
    if (lhs.id != nil && rhs.id != nil) {
        return lhs.id == rhs.id
    }
    return lhs.prefix == rhs.prefix && lhs.first == rhs.first && lhs.middle == rhs.middle && lhs.last == rhs.last && lhs.suffix == rhs.suffix
}

func==%(lhs: User, rhs: User) -> Bool {
    return lhs.prefix == rhs.prefix && lhs.first == rhs.first && lhs.middle == rhs.middle && lhs.last == rhs.last && lhs.suffix == rhs.suffix
}

func<(lhs: User, rhs: User) -> Bool {
    if lhs.last != rhs.last {
        return lhs.last < rhs.last
    } else if lhs.first != rhs.first {
        return lhs.first < rhs.first
    } else if lhs.middle != rhs.middle {
        return (lhs.middle ?? "") < (rhs.middle ?? "")
    } else if lhs.suffix != rhs.suffix {
        return (lhs.suffix ?? "") < (rhs.suffix ?? "")
    }
    
    return (lhs.prefix ?? "") < (rhs.prefix ?? "")
}