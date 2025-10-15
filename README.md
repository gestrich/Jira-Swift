# JiraSwift

JiraSwift is a client library for interfacing with the [Jira Cloud Rest API](https://developer.atlassian.com/cloud/jira/platform/rest/#authentication)

This is still under construction but feedback is welcome

## How to get

* Swift Package Manager (Mac, Server)
* iOS Framework


## How to use

```swift
let jiraClient = JiraRestClient(baseURL:"https://<Your Jira URL>.atlassian.net/rest/", auth:BasicAuth(username: "SomeUsername", password: "SomePa$$word))

let jqlFilter = JQLFilter(jql: "assignee=george AND status=Open")

do {
    let issues = try await jiraClient.issues(for: jqlFilter)
    for issue in issues {
        print(issue.key)
        print(issue.urlString)
        print(issue.fields)
    }
} catch {
    print(error)
}
```
