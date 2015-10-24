//
//  DictionaryExtensions.swift
//  Chat
//
//  Created by Ravi Desai on 4/23/15.
//  Copyright (c) 2015 CEV. All rights reserved.
//

import Foundation
public func addIf<Key, Value>(inout toDictionary: Dictionary<Key, Value>, key: Key, value: Value?) -> Void {
    if let myvalue = value {
        toDictionary[key] = myvalue
    }
}

public func addTuplesIf<Key, Value>(inout toDictionary: Dictionary<Key, Value>, tuples: (Key, Value?)...) -> Void {
    for tuple in tuples {
        addIf(&toDictionary, key: tuple.0, value: tuple.1)
    }
}

public func convertToFormUrl<Key, Value>(fromDictionary: Dictionary<Key, Value>) -> NSData {
    var urlParams = Array<String>();
    for (key, value) in fromDictionary {
        let encodedKey: CFString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, "\(key)", nil, ":/?#[]@!$'()*+,;",CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)) ?? ""
        let encodeValue: CFString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, "\(value)", nil, ":/?#[]@!$'()*+,;",CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)) ?? ""
        urlParams.append(("\(encodedKey)=\(encodeValue)"))
    }
    let strData = urlParams.joinWithSeparator("&");
    return strData.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) ?? NSData()
}

public func convertToFormUrl(obj: SerializableToJSON) -> NSData {
    return convertToFormUrl(obj.convertToJSON());
}

public func convertToJSONArray<T: SerializableToJSON>(fromArray: [T]?) -> [JSONDictionary]? {
    if let from = fromArray {
        return from.map { $0.convertToJSON() }
    }
    return nil
}


public class ModelFactory<T: SerializableFromJSON> {
    public static func createFromJSONArray(json: JSON) -> [T.ConcreteType]? {
        if let jsonArray = json as? JSONArray {
            return jsonArray
                .map { T.createFromJSON($0) }
                .filter { $0 != nil }
                .map { $0! }
        }
        return nil
    }
    
    public static func createFromJSON(json: JSON) -> T.ConcreteType? {
        return T.createFromJSON(json);
    }
}

