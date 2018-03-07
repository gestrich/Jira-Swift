//
//  IssueFilter.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 11/1/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation

public struct IssueFilter {
    public var assignee: String?
    public var status: String?
    
    func getString() -> String {
        var paramDict = Dictionary<String, String>()
        if let assignee = self.assignee {
            paramDict["assignee"] = assignee
        }
        
        if let status = self.status {
            paramDict["status"] = status
        }
        
        let rawString = paramDict.simpleSQLRepresentation()
        
        let encodedString = rawString.addingPercentEncodingForURLQueryValue()
        
        return encodedString
    }
}

