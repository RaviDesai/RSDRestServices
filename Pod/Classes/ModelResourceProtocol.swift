//
//  ModelResourceProtocol.swift
//  Pods
//
//  Created by Ravi Desai on 1/8/16.
//
//

import Foundation
import RSDSerialization

public protocol ModelResource : ModelItem {
    typealias T : ModelItem = Self
    static var resourceEndpoint: String { get }
    
    static func getAll(session: APISession, completionHandler: ([T]?, NSError?) -> ())
    static func get(session: APISession, resourceId: NSUUID, completionHandler: (T?, NSError?) -> ())
    func save(session: APISession, completionHandler: (T?, NSError?) -> ())
    func create(session: APISession, completionHandler: (T?, NSError?) -> ())
    func delete(session: APISession, completionHandler: (NSError?) -> ())
}

private let invalidId = NSError(domain: "com.github.RaviDesai", code: 48118002, userInfo: [NSLocalizedDescriptionKey: "Invalid ID", NSLocalizedFailureReasonErrorKey: "Invalid ID"])

public extension ModelResource {
    static func getAll(session: APISession, completionHandler: ([T]?, NSError?)->()) {
        let endpoint = APIEndpoint.GET(URLAndParameters(url: Self.resourceEndpoint))
        let parser = APIJSONSerializableResponseParser<T>()
        let request = APIRequest(baseURL: session.baseURL, endpoint: endpoint, bodyEncoder: nil, responseParser: parser, additionalHeaders: nil)
        let call = APICall(session: session, request: request)
        call.executeRespondWithArray(completionHandler)
    }
    
    static func get(session: APISession, resourceId: NSUUID, completionHandler: (T?, NSError?) -> ()) {
        let uuid = resourceId.UUIDString
        let endpoint = APIEndpoint.GET(URLAndParameters(url: "\(Self.resourceEndpoint)/\(uuid)"))
        let parser = APIJSONSerializableResponseParser<T>()
        let request = APIRequest(baseURL: session.baseURL, endpoint: endpoint, bodyEncoder: nil, responseParser: parser, additionalHeaders: nil)
        let call = APICall(session: session, request: request)
        call.executeRespondWithObject(completionHandler)
    }
    
    func save(session: APISession, completionHandler: (T?, NSError?) -> ()) {
        if let uuid = self.id?.UUIDString {
            let endpoint = APIEndpoint.PUT(URLAndParameters(url: "\(Self.resourceEndpoint)/\(uuid)"))
            let parser = APIJSONSerializableResponseParser<T>()
            let encoder = APIJSONBodyEncoder(model: self)
            let request = APIRequest(baseURL: session.baseURL, endpoint: endpoint, bodyEncoder: encoder, responseParser: parser, additionalHeaders: nil)
            let call = APICall(session: session, request: request)
            call.executeRespondWithObject(completionHandler)
        } else {
            completionHandler(nil, invalidId)
        }
    }
    
    func create(session: APISession, completionHandler: (T?, NSError?) -> ()) {
        if self.id?.UUIDString == nil {
            let endpoint = APIEndpoint.POST(URLAndParameters(url: Self.resourceEndpoint))
            let parser = APIJSONSerializableResponseParser<T>()
            let encoder = APIJSONBodyEncoder(model: self)
            let request = APIRequest(baseURL: session.baseURL, endpoint: endpoint, bodyEncoder: encoder, responseParser: parser, additionalHeaders: nil)
            let call = APICall(session: session, request: request)
            call.executeRespondWithObject(completionHandler)
        } else {
            completionHandler(nil, invalidId)
        }
    }
    
    func delete(session: APISession, completionHandler: (NSError?) -> ()) {
        if let uuid = self.id?.UUIDString {
            let endpoint = APIEndpoint.DELETE(URLAndParameters(url: "\(Self.resourceEndpoint)/\(uuid)"))
            let parser = APIJSONSerializableResponseParser<T>()
            let encoder = APIJSONBodyEncoder(model: self)
            let request = APIRequest(baseURL: session.baseURL, endpoint: endpoint, bodyEncoder: encoder, responseParser: parser, additionalHeaders: nil)
            let call = APICall(session: session, request: request)
            call.execute(completionHandler)
        } else {
            completionHandler(invalidId)
        }
    }

}