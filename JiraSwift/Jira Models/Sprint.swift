//
//  Sprint.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 10/28/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation

public struct Sprint {
    public var completeDate: String = ""
    public var endDate: String = ""
    public var goal: String = ""
    public var id: Int = 0
    public var name: String = ""
    public var originalBoardId: Int = 0
    public var url: String = ""
    public var startDate: String = ""
    public var state: String = ""
}

extension Sprint {
    init?(json: NSDictionary) {
        
        //Optional
        if let completeDate = json["completeDate"] as? String {
            self.completeDate = completeDate
        }
        
        //Optional
        if let endDate = json["endDate"] as? String {
            self.endDate = endDate
        }
        
        guard let goal = json["goal"] as? String else {
            Board.logMissingProperty(property: "goal")
            return nil
        }
        
        guard let id = json["id"] as? Int else {
            Board.logMissingProperty(property: "id")
            return nil
        }
        
        guard let name = json["name"] as? String else {
            Board.logMissingProperty(property: "name")
            return nil
        }
        
        //optional
        if let originalBoardId = json["originalBoardId"] as? Int {
            self.originalBoardId = originalBoardId
        }
        
        guard let url = json["self"] as? String else {
            Board.logMissingProperty(property: "url")
            return nil
        }
        
        //optional
        if let startDate = json["startDate"] as? String {
            self.startDate = startDate
        }
        
        guard let state = json["state"] as? String else {
            Board.logMissingProperty(property: "state")
            return nil
        }
        
        self.goal = goal
        self.id = id
        self.name = name

        self.url = url
        self.state = state
    }
    
    static func sprintsWith(agileResponse: AgileResponse) -> [Sprint] {
        var sprints = [Sprint]()
        for json in agileResponse.values {
            guard let json = json as? NSDictionary else {
                continue
            }
            
            if let sprint = Sprint(json: json) {
                sprints.append(sprint)
            }
        }
        
        return sprints
    }
    
    static func logMissingProperty(property: String){
        print("Missing property \(property)")
    }
}


