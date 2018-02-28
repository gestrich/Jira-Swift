//
//  IssueResponse.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 10/28/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation

struct IssueResponse {
    var maxResults: Int = 0
    var startAt: Int = 0
    var total: Int = 0
    var issues: [Issue]
    
    func nextIndex() -> Int {
        let lastIndexFetched = startAt + (maxResults - 1)
        let lastIndexAvailable = total - 1
        if lastIndexFetched < lastIndexAvailable {
            return lastIndexFetched + 1
        } else {
            return -1
        }
    }
}

extension IssueResponse {
    static func logMissingProperty(property: String){
        print("Missing property \(property)")
    }
    
    init?(json: NSDictionary) {
        
        guard let maxResults = json["maxResults"] as? Int else {
            AgileResponse.logMissingProperty(property:"maxResults")
            return nil
        }
        
        guard let startAt = json["startAt"] as? Int else {
            AgileResponse.logMissingProperty(property:"startAt")
            return nil
        }
        
        guard let total = json["total"] as? Int else {
            AgileResponse.logMissingProperty(property:"total")
            return nil
        }
        
        guard let issuesJson = json["issues"] as? [NSDictionary] else {
            AgileResponse.logMissingProperty(property:"issues")
            return nil
        }
        var issues = [Issue]()
        for json in issuesJson {
            if let issue = Issue(json: json) {
                issues.append(issue)
            }
        }
        
        self.maxResults = maxResults
        self.startAt = startAt
        self.total = total
        self.issues = issues
    }
}
