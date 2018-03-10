import XCTest
@testable import JiraSwift

class JiraSwiftTests: XCTestCase {
    func testExample() {
        
        //There are no real tests in here - This is just a playground for trying the API.
        
        //I use a private file with configuration option to aid in testing endpoints on the simulator.
        //Create a plist with the below strings and put somewhere in your
        //local file system.
        let url = URL(fileURLWithPath: "/Users/bill/.JiraSwiftConfiguration.plist")
        let configurationDictionary = NSDictionary(contentsOf: url) ?? NSDictionary()
        
        guard  let username = configurationDictionary["JIRA_USERNAME"] as? String else {
            print("Need a jira username to continue with test")
            return
        }
        
        guard  let password = configurationDictionary["JIRA_PASSWORD"] as? String else {
            print("Need a jira password to continue with test")
            return
        }
        
        guard  let baseURL = configurationDictionary["JIRA_URL"] as? String else {
            print("Need a jira url to continue with test")
            return
        }
        
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
