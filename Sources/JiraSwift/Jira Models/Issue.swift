//
//  Issue.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 10/28/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation

public struct Issue : Codable {
    public var id: String = ""
    public var key: String = ""
    public var urlString: String = ""
    public var fields : Fields
    
    enum CodingKeys : String, CodingKey {
        case id
        case key
        case urlString = "self"
        case fields
    }
    
    
    
    public struct Fields : Codable {
        
        let epic: String?
        public var summary: String
        var fixVersions: [FixVersion]?
        public let assignee: Assignee?
        public var description : String?
        public let status: IssueStatus
        public let created: Date
        
        enum CodingKeys : String, CodingKey {
            case epic = "customfield_10017"
            case summary
            case fixVersions
            case assignee
            case description
            case status
            case created //"created": "2019-08-28T09:42:49.091-0500",
        }
    }
    
    public struct FixVersion : Codable {
        public let description : String?
        public let name : String
        enum CodingKeys : String, CodingKey {
            case description
            case name
        }
    }
    
    public struct IssueStatus : Codable {
        public let description : String?
        public let name : String
    }
    
}



