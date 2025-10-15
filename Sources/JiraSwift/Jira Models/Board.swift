//
//  Board.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 10/28/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation

public struct Board: Codable, Sendable {
    public var id: Int = 0
    public var name: String = ""
    public var url: String = ""
    public var type: String = ""
    
    enum CodingKeys : String, CodingKey {
        case id
        case name
        case url = "self"
        case type
    }
    
}
