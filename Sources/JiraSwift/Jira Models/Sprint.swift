//
//  Sprint.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 10/28/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation

public struct Sprint: Codable, Sendable {
    public var completeDate: String?
    public var endDate: String?
    public var goal: String?
    public var id: Int = 0
    public var name: String
    public var originalBoardId: Int?
    public var url: String
    public var startDate: String?
    public var state: String
    
    
    enum CodingKeys : String, CodingKey {
        case completeDate
        case endDate
        case goal
        case id
        case name
        case originalBoardId
        case url = "self"
        case startDate
        case state
    }
    

}



