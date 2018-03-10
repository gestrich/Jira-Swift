//
//  FileUtils.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 2/27/18.
//  Copyright © 2018 Bill Gestrich. All rights reserved.
//

import Foundation

public func getConfigurationFileVariable(key: String) -> String? {
    let keySeparator = "="
    
    let configurationPath = "/Users/bill/.jira_config"
    guard let fileString = try? String(contentsOfFile: configurationPath) else {
        return nil
    }
    
    let allLines = fileString.components(separatedBy: .newlines)
    for line in allLines {
        let split = line.components(separatedBy: keySeparator)
        if split.count < 2 {
            continue
        }
        
        let thisKey = split[0]
        if key == thisKey {
            return line.getPartAfter(toSearch: keySeparator)
        }
    }
    
    return nil
}
