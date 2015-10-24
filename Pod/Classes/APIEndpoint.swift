//
//  Endpoint.swift
//  CEVFoundation
//
//  Created by Ravi Desai on 6/10/15.
//  Copyright (c) 2015 CEV. All rights reserved.
//

import Foundation

public class APIEndpoint {
    private var _URLAndParams: URLAndParameters
    private var _acceptTypes: String?
    private var _method: String
    
    public init(method: String, url: URLAndParameters, acceptTypes: String?) {
        self._URLAndParams = url;
        self._method = method;
        self._acceptTypes = acceptTypes;
    }
    
    public func URL(baseURL: NSURL?) -> NSURL? {
        return self._URLAndParams.URL(baseURL)
    }
    
    public func acceptTypes() -> String? {
        return self._acceptTypes
    }
    
    public func method() -> String {
        return self._method
    }
    
    public class func GET(url: URLAndParameters, acceptTypes:String?) -> APIEndpoint {
        return APIEndpoint(method: "GET", url: url, acceptTypes: acceptTypes)
    }
    
    public class func POST(url: URLAndParameters, acceptTypes: String?) -> APIEndpoint {
        return APIEndpoint(method: "POST", url: url, acceptTypes: acceptTypes)
    }
    
    public class func PUT(url: URLAndParameters, acceptTypes: String?) -> APIEndpoint {
        return APIEndpoint(method: "PUT", url: url, acceptTypes: acceptTypes)
    }
    
    public class func DELETE(url: URLAndParameters, acceptTypes: String?) -> APIEndpoint {
        return APIEndpoint(method: "DELETE", url: url, acceptTypes: acceptTypes)
    }
}