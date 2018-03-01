//
//  Assignee.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 11/4/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation

public struct Assignee : Codable {
    let key : String
    let name : String
    let displayName : String
    let emailAddress : String
    enum CodingKeys : String, CodingKey {
        case key
        case name
        case displayName
        case emailAddress
    }
}
