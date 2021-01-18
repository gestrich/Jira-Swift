//
//  Assignee.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 11/4/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation

public struct Assignee : Codable {
    public let key : Int?
    public let name : String?
    public let displayName : String
    public let emailAddress : String?
    public let avatarUrls : AvatarURLs
    enum CodingKeys : String, CodingKey {
        case key
        case name
        case displayName
        case emailAddress
        case avatarUrls
    }
    
    public struct AvatarURLs : Codable {

        public let size16SquareURL : String
        public let size24SquareURL : String
        public let size32SquareURL : String
        public let size48SquareURL : String
        enum CodingKeys : String, CodingKey {
            case size16SquareURL = "16x16"
            case size24SquareURL = "24x24"
            case size32SquareURL = "32x32"
            case size48SquareURL = "48x48"
        }
    }
}
