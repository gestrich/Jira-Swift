//
//  Board.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 10/28/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation

public struct Board {
    public var id: Int = 0
    public var name: String = ""
    public var url: String = ""
    public var type: String = ""
}

extension Board {
    init?(json: NSDictionary) {
        guard let id = json["id"] as? Int else {
            Board.logMissingProperty(property: "id")
            return nil
        }
        
        guard let name = json["name"] as? String else {
            Board.logMissingProperty(property: "name")
            return nil
        }
        
        guard let url = json["self"] as? String else {
            Board.logMissingProperty(property: "self")
            return nil
        }
        
        guard let type = json["type"] as? String else {
            Board.logMissingProperty(property: "type")
            return nil
        }
        
        self.id = id
        self.name = name
        self.url = url
        self.type = type
    }
    
    static func boardsWith(agileResponse: AgileResponse) -> [Board] {
        var boards = [Board]()
        for json in agileResponse.values {
            guard let json = json as? NSDictionary else {
                continue
            }
            
            if let board = Board(json: json) {
                boards.append(board)
            }
        }
        
        return boards
    }
    
    static func logMissingProperty(property: String){
        print("Missing property \(property)")
    }
}

