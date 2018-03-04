//
//  JiraSwiftTests.swift
//  JiraSwiftTests
//
//  Created by Bill Gestrich on 2/25/18.
//  Copyright © 2018 Bill Gestrich. All rights reserved.
//

import XCTest
import JiraSwift

class JiraSwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        
        let username = getConfigurationFileVariable(key: "JIRA_USERNAME") ?? ""
        let password = getConfigurationFileVariable(key: "JIRA_PASSWORD") ?? ""
        let baseURL = getConfigurationFileVariable(key: "JIRA_URL") ?? ""

        let jiraClient = JiraRestClient(baseURL:baseURL, auth:BasicAuth(username: username, password: password))
        
        
        //        let filter = IssueFilter(assignee: "bill", status:"open")
//        let jqlFilter = JQLFilter(jql: "assignee=bill AND status=Open")
//                
//        let expectation = XCTestExpectation(description: "issuesForAsnc test")
//
//        jiraClient.issuesFor(filter: jqlFilter) { (issues) in
//            print(issues)
//            expectation.fulfill()
//
//        }
//        
//        wait(for: [expectation], timeout: 100.0)
        

        
//        let expectation = XCTestExpectation(description: "issuesForAsnc test")
//        
//        jiraClient.getBoards { (boards) in
//            expectation.fulfill()
//            print(boards)
//        }
//        
//        wait(for: [expectation], timeout: 100.0)
        
        let expectation = XCTestExpectation(description: "issuesForAsnc test")
        
        jiraClient.getBoards { (boards) in
//            print(boards)
            
            for board in boards {
                if board.name == "" {
//                    jiraClient.getSprintsFor(board: board, completionBlock { (sprints) in
//                        print(sprints)
//                        expectation.fulfill()
//                    })
                    
                    jiraClient.getCurrentSprintFor(board: board) { 
                        print($0 ?? "")
                        expectation.fulfill()
                    }
                }
            }
            
            
            
            
            
        }
        
        wait(for: [expectation], timeout: 100.0)

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
