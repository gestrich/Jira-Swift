import XCTest
@testable import JiraSwift

class JiraSwiftTests: XCTestCase {
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
        
        jiraClient.getBoards(completionBlock: { (boards) in
            print(boards)
            expectation.fulfill()
        }, errorBlock: { (error) in
            print(error)
            expectation.fulfill()
        })
        
        wait(for: [expectation], timeout: 100.0)
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
