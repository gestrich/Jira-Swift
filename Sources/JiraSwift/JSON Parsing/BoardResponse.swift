//
//  BoardResponse.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 10/28/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation

struct BoardResponse : Codable {
    var isLast: Bool = false
    var maxResults: Int = 0
    var startAt: Int = 0
    var total: Int = 0
    var boards: [Board]
    
    enum CodingKeys : String, CodingKey {
        case isLast
        case maxResults
        case startAt
        case total
        case boards = "values"
    }
    
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

