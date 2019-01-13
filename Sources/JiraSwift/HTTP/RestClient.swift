//
//  RestClient.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 10/29/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation

public enum RestClientError: Error {
    case serviceError(Error)
    case statusCode(Int)
    case noData
    case deserialization(Error)
}

public class RestClient: NSObject {
    
    let baseURL: String
    var headers: [String:String]?
    var auth : BasicAuth?
    
    public init(baseURL: String){
        self.baseURL = baseURL
        super.init()
    }
    
    public convenience init(baseURL: String, auth: BasicAuth){
        self.init(baseURL: baseURL)
        self.auth = auth
    }
    
    func jsonData(relativeURL: String, completionBlock:@escaping ((Data) -> Void), errorBlock:(@escaping (RestClientError) -> Void)){
        let urlString = baseURL.appending(relativeURL)
        jsonData(fullURL:urlString, completionBlock:completionBlock, errorBlock:errorBlock)
    }
    
    func jsonData(fullURL: String, completionBlock:@escaping ((Data) -> Void), errorBlock:(@escaping (RestClientError) -> Void)){
        var headersToSet = ["Content-Type":"application/json", "Accept":"application/json"]
        if let headers = self.headers {
            headersToSet += headers
        }
        let http = SimpleHttp(auth:self.auth, headers:headersToSet);
        let url = URL(string: fullURL)!
        http.getJSONData(url:url, completionBlock:completionBlock, errorBlock:errorBlock)
    }

    func uploadFile(filePath: String, relativeDestinationPath: String, completionBlock:@escaping ((Data) -> Void), errorBlock:(@escaping (RestClientError) -> Void)){
        let fullDestinationPath = baseURL.appending(relativeDestinationPath)
        uploadFile(filePath: filePath, fullDestinationPath: fullDestinationPath, completionBlock: completionBlock, errorBlock: errorBlock)
    }
    
    func uploadFile(filePath: String, fullDestinationPath: String, completionBlock:@escaping ((Data) -> Void), errorBlock:(@escaping (RestClientError) -> Void)){
        var headersToSet = ["Accept":"application/json", "X-Atlassian-Token":"nocheck"]
        if let headers = self.headers {
            headersToSet += headers
        }
        let http = SimpleHttp(auth:self.auth, headers:headersToSet)
        let destinationURL = URL(string: fullDestinationPath)!
        let fileURL = URL(string: filePath)!
        http.uploadFile(fileUrl: fileURL, destinationURL: destinationURL, completionBlock: completionBlock, errorBlock: errorBlock)
    }
    
}
