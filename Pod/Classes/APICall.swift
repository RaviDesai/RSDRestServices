//
//  Call.swift
//  CEVFoundation
//
//  Created by Ravi Desai on 6/10/15.
//  Copyright (c) 2015 CEV. All rights reserved.
//

import Foundation

public class APICall<U: APIResponseParser> {
    public private(set) var session: APISession
    private var request: APIRequest
    private var parser: U
    
    public init(session: APISession, request: APIRequest, parser: U) {
        self.session = session
        self.request = request
        self.parser = parser
    }
    
    private func reportIfNetworkFailure(response: NetworkResponse) {
        if (response.isNetworkFailure() && self.session.delegate != nil) {
            self.session.delegate!.sessionExperiencedNetworkFailure(self.session, error: response.getError())
        }
    }
    
    private func performTask(callback: (NetworkResponse) -> ()) {
        var message = "Could not construct a valid HTTP request."
        var userInfo = [NSLocalizedDescriptionKey:message, NSLocalizedFailureReasonErrorKey: message];
        var error = NSError(domain: "com.github.RaviDesai", code: 48118001, userInfo: userInfo)
        
        if let request = self.request.makeRequest() {
            var task = self.session.session.dataTaskWithRequest(request, completionHandler: { (data, response, error) -> Void in
                var result = NetworkResponse.create(data, response: response, error: error)
                if (result.isUnauthorized() && self.session.delegate != nil) {
                    self.session.delegate!.sessionRequiresAuthentication(self.session, completion: { (retry) -> () in
                        var task2 = self.session.session.dataTaskWithRequest(request, completionHandler: { (data2, response2, error2) -> Void in
                            var result2 = APIParser.ParseResponse(data2, response: response2, error: error2)
                            self.reportIfNetworkFailure(result2)
                            callback(result2)
                        })
                        task2.resume()
                    })
                } else {
                    self.reportIfNetworkFailure(result)
                    callback(result);
                }
            })
            task.resume()
        } else {
            callback(NetworkResponse.SystemFailure(error))
        }
    }
    
    public func execute(callback: (NSError?) -> ()) {
        self.performTask { (networkResponse) -> () in
            callback(networkResponse.getError())
        }
    }
    
    public func executeRespondWithObject(callback: (U.T?, NSError?) ->()) {
        self.performTask { (response) -> () in
            var (result, error) = self.parser.Parse(response)
            callback(result, error)
        }
    }
    
    public func executeRespondWithArray(callback: ([U.T]?, NSError?) ->()) {
        self.performTask { (response) -> () in
            var (result, error) = self.parser.ParseToArray(response)
            callback(result, error)
        }
    }
    
}