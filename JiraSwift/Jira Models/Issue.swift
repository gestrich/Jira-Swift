//
//  Issue.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 10/28/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation

public struct Issue {
    public var id: String = ""
    public var key: String = ""
    public var epic: String = ""
    public var summary: String = ""
    public var fixVersions: [String] = [String]()
    public var assignee: JiraAssignee
}

extension Issue {
    init?(json: NSDictionary) {
        guard let id = json["id"] as? String else {
            Issue.logMissingProperty(property: "id")
            return nil
        }
        
        guard let key = json["key"] as? String else {
            Issue.logMissingProperty(property: "key")
            return nil
        }
        
        guard let fields = json["fields"] as? NSDictionary else {
            Issue.logMissingProperty(property: "fields")
            return nil
        }
        
        if let epic = fields["customfield_10017"] as? String {
            self.epic = epic
        }
        
        if let fixVersionArray = fields["fixVersions"] as? Array<Dictionary<String,Any>> {
            var foundVersions = [String]()
            for versionDictionary in fixVersionArray {
                if let version = versionDictionary["name"] as? String {
                    foundVersions.append(version)
                }
            }
            
            self.fixVersions = foundVersions
        }
        
        guard let assigneeDictionary = fields["assignee"] as? Dictionary<String, Any> else {
            return nil
        }
        
        guard let assignee = JiraAssignee(json: assigneeDictionary) else {
            return nil
        }
        
        if let summary = fields["summary"] as? String {
            self.summary = summary
        }
        
        self.id = id
        self.key = key
        self.assignee = assignee
    }
    
    static func logMissingProperty(property: String){
        print("Missing property \(property)")
    }
    
}


