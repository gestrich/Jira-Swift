//
//  JQLFilter.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 11/1/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation

public struct JQLFilter {
    let jql: String
    
    public init(jql: String){
        self.jql = jql
    }
    
    func getString() -> String {
        return "jql=" + self.jql.addingPercentEncodingForURLQueryValue()
    }
}
