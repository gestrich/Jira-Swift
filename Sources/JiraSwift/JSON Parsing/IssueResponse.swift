//
//  IssueResponse.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 10/28/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation

public struct IssueResponse: Codable, Sendable {
    var maxResults: Int = 0
    var startAt: Int = 0
    var total: Int = 0
    var issues: [Issue]
    
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

