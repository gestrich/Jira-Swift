//
//  SprintResponse.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 3/1/18.
//  Copyright © 2018 Bill Gestrich. All rights reserved.
//

import Foundation

struct SprintResponse : Codable {
    var isLast: Bool = false
    var maxResults: Int = 0
    var startAt: Int = 0
    var sprints: [Sprint]
    
    enum CodingKeys : String, CodingKey {
        case isLast
        case maxResults
        case startAt
        case sprints = "values"
    }
}


