//
//  APIConsumersClient.swift
//  CEVFoundation
//
//  Created by Ravi Desai on 6/11/15.
//  Copyright (c) 2015 CEV. All rights reserved.
//

import Foundation
import CEVMobile

public class APIConsumersClient : NSObject, CEVMobile.CEVAPISessionDelegate {
    private(set) public static var sharedClient = APIConsumersClient(client: CEVMobile.CEVAPIConsumersClient.sharedClient())
    
    private var client: CEVMobile.CEVAPIConsumersClient
    private init(client: CEVMobile.CEVAPIConsumersClient) {
        self.client = client
    }

    public var session: CEVMobile.CEVAPISession {
        get { return self.client.session }
    }
    
    public var authenticated: Bool {
        get { return self.client.authenticated }
    }
    
    public func authenticateWithSavedCredentialsFromStore(credentialsStore: CEVAPICredentialsStore, completion:((success: Bool, error: CEVMobile.CEVAPIError?)->())) {
        self.client.authenticateWithSavedCredentialsFromStore(credentialsStore, completion: completion)
    }
    
    public func authenticateWithPasswordCredentials(credentials: CEVMobile.CEVAPIPasswordCredentials, credentialStore: CEVAPICredentialsStore, completion: ((Bool, error: CEVAPIError?) -> ())) {
        self.client.authenticateWithPasswordCredentials(credentials, credentialStore: credentialStore, completion: completion)
    }

    public static func frontDoorResourceWithPath(path: String, completionHandler: ([APISite]?, CEVAPIError?) ->())  {
        
        CEVAPIConsumersClient.frontDoorResourceWithPath(path, responseParser: ParserForResponseParser.networkResponseParser()) { (box, error) -> Void in
            if let networkResponseBox = box as? BoxedNetworkResponse {
                let unboxed = networkResponseBox.object
                let parser = APIJSONSerializableResponseParser<APISite>()
                let result = parser.ParseToArray(unboxed)
                let apiError = (result.1 != nil) ? CEVAPIError(underlyingNetworkError: result.1) : nil
                completionHandler(result.0, apiError)
            }
        }
    }

    public func logout(completion: ()->()) {
        self.client.logout(completion)
    }
    
    public func setSessionForUnitTesting(session: CEVMobile.CEVAPISession) {
        self.client.setSessionForUnitTesting(session)
    }
    
    public func call<U: APIResponseParserProtocol>(endpoint: APIEndpoint, encoder: APIBodyEncoderProtocol?, parser: U) -> APICall<U> {
        let request = APIRequest(baseURL: self.session.baseURL, endpoint: endpoint, bodyEncoder: encoder, additionalHeaders: nil)
        return APICall(session: self.session, request: request, parser: parser)
    }


}