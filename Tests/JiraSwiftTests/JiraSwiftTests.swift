import XCTest
import SwiftRestTools

@testable import JiraSwift

//There are no real unit tests in here - This is just a playground for trying the API.

//I use a private file with configuration option to aid in testing endpoints on the simulator.
//Create a plist with the below strings and put somewhere in your
//local file system.

class JiraSwiftTests: XCTestCase {
    func testImageUpload() async throws {
        let jiraClient = getJiraClient()!
        let filePath = "/Users/bill/Dropbox/screenshots/testImage.jpg"
        try await jiraClient.uploadFile(filePath: filePath, issueIdentifier: "CA-1")
        print("done")
    }
    
    func testGetIssue() async throws {
        let jiraClient = getJiraClient()!
        let issue = try await jiraClient.issue(identifier: "FFM-12345")
        print(issue)
    }
    
    func testIssueQuery() async throws {
        let jiraClient = getJiraClient()!
        let jqlFilter = JQLFilter(jql: "status=Backlog")
        let issues = try await jiraClient.issues(for: jqlFilter)
        for issue : Issue in issues {
            print(issue.key)
            print(issue.urlString)
            print(issue.fields)
        }
        print(issues)
    }
    
    func getJiraClient() -> JiraRestClient? {
        let url = URL(fileURLWithPath: "/Users/bill/.JiraSwiftConfiguration.plist")
        let configurationDictionary = NSDictionary(contentsOf: url) ?? NSDictionary()
        
        guard  let username = configurationDictionary["JIRA_USERNAME"] as? String else {
            print("Need a jira username to continue with test")
            return nil
        }
        
        guard  let password = configurationDictionary["JIRA_PASSWORD"] as? String else {
            print("Need a jira password to continue with test")
            return nil
        }
        
        guard  let baseURL = configurationDictionary["JIRA_URL"] as? String else {
            print("Need a jira url to continue with test")
            return nil
        }
        
        let jiraClient = JiraRestClient(baseURL:baseURL, auth:BasicAuth(username: username, password: password))
        
        return jiraClient
    }


    static var allTests = [
        ("testExample", testImageUpload),
    ]
}
