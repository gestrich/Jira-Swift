//
//  AgileResponse.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 10/28/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation

struct AgileResponse {
    var isLast: Bool = false
    var maxResults: Int = 0
    var startAt: Int = 0
    var values: [Any]
}

extension AgileResponse {
    static func logMissingProperty(property: String){
        print("Missing property \(property)")
    }
    
    init?(json: NSDictionary) {

        guard let isLast = json["isLast"] as? Bool else {
            AgileResponse.logMissingProperty(property:"isLast")
            return nil
        }
        
        guard let maxResults = json["maxResults"] as? Int else {
            AgileResponse.logMissingProperty(property:"maxResults")
            return nil
        }
        
        guard let startAt = json["startAt"] as? Int else {
            AgileResponse.logMissingProperty(property:"startAt")
            return nil
        }
        
        guard let values = json["values"] as? [Any] else {
            AgileResponse.logMissingProperty(property:"values")
            return nil
        }
        
        self.isLast = isLast
        self.maxResults = maxResults
        self.startAt = startAt
        self.values = values
    }
}
