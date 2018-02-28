//
//  JiraAssignee.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 11/4/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation

public struct JiraAssignee {
    public var key: String = ""
    public var name: String = ""
    public var displayName: String = ""
    public var email: String = "" 
}

extension JiraAssignee {
    init?(json: Dictionary<String, Any>) {

        guard let key = json["key"] as? String else {
            return nil
        }   
        
        guard let name = json["name"] as? String else {
            return nil
        }   
        
        guard let displayName = json["displayName"] as? String else {
            return nil
        }
        
        guard let email = json["emailAddress"] as? String else {
            return nil
        }
        
        self.key = key
        self.name = name
        self.displayName = displayName
        self.email = email
    }
}
        
