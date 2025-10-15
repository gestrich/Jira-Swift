//
//  JiraRestClient.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 10/28/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

// Jira Rest API Reference: https://developer.atlassian.com/jiradev/jira-apis/jira-rest-apis/jira-rest-api-tutorials

import Foundation
import SwiftRestTools

public class JiraRestClient: RestClient, @unchecked Sendable {
    
    
    public func getBoards() async throws -> [Board] {
        try await getBoards(startAt: 0)
    }

    public func getBoards(startAt: Int) async throws -> [Board] {
        let json = try await getData(relativeURL: "agile/latest/board?startAt=\(startAt)")
        let decoder = self.jsonDecoder()
        let boardResponse = try decoder.decode(BoardResponse.self, from: json)
        let boards = boardResponse.boards

        if boardResponse.isLast == false {
            let blockBoards = try await self.getBoards(startAt: startAt + boardResponse.maxResults)
            return boards + blockBoards
        } else {
            return boards
        }
    }
    
    public func getCurrentSprint(for board: Board) async throws -> Sprint? {
        let sprints = try await getSprints(for: board)
        for sprint in sprints {
            if sprint.state == "active" {
                return sprint
            }
        }
        return nil
    }

    public func getSprints(for board: Board) async throws -> [Sprint] {
        try await getSprints(for: board, startAt: 0)
    }

    public func getSprints(for board: Board, startAt: Int) async throws -> [Sprint] {
        let json = try await getData(relativeURL: "agile/latest/board/\(board.id)/sprint?startAt=\(startAt)")
        let decoder = self.jsonDecoder()
        let sprintResponse = try decoder.decode(SprintResponse.self, from: json)
        let sprints = sprintResponse.sprints

        if sprintResponse.isLast == false {
            let blockSprints = try await self.getSprints(for: board, startAt: startAt + sprintResponse.maxResults)
            return sprints + blockSprints
        } else {
            return sprints
        }
    }
    
    public func issue(identifier: String) async throws -> Issue {
        let json = try await getData(relativeURL: "api/2/issue/\(identifier)")
        let decoder = self.jsonDecoder()
        let issue = try decoder.decode(Issue.self, from: json)
        return issue
    }
    
    public func issues(for board: Board, sprint: Sprint) async throws -> [Issue] {
        let relativeURL = "agile/latest/board/\(board.id)/sprint/\(sprint.id)/issue?startAt="
        return try await issues(for: relativeURL, startAt: 0)
    }

    func issues(for relativeURL: String, startAt: Int) async throws -> [Issue] {
        let json = try await getData(relativeURL: relativeURL + "&startAt=\(startAt)")
        let decoder = self.jsonDecoder()
        let issueResponse = try decoder.decode(IssueResponse.self, from: json)
        let issues = issueResponse.issues
        let nextIndexToFetch = issueResponse.nextIndex()

        if nextIndexToFetch >= 0 {
            let nextIssues = try await self.issues(for: relativeURL, startAt: nextIndexToFetch)
            return issues + nextIssues
        } else {
            return issues
        }
    }

    public func issues(for filter: JQLFilter) async throws -> [Issue] {
        let relativeUrl = "api/3/search/jql?" + filter.getString()
        return try await issues(for: relativeUrl, startAt: 0)
    }
    
    public func uploadFile(filePath: String, issueIdentifier: String) async throws {
        _ = try await uploadFile(filePath: filePath, relativeDestinationPath: "api/2/issue/\(issueIdentifier)/attachments")
    }
    
    // MARK: - Create Issue
    
    public func createIssue(request: CreateIssueRequest) async throws -> CreateIssueResponse {
        let data = try await peformJSONPost(relativeURL: "api/2/issue", payload: request)
        let decoder = self.jsonDecoder()
        let response = try decoder.decode(CreateIssueResponse.self, from: data)
        return response
    }

    public func createIssue(projectKey: String,
                           issueType: String,
                           summary: String,
                           description: String? = nil,
                           priority: String? = nil,
                           labels: [String]? = nil) async throws -> CreateIssueResponse {

        let project = ProjectRef(key: projectKey)
        let issueTypeRef = IssueTypeRef(name: issueType)
        let priorityRef = priority.map { PriorityRef(name: $0) }

        let fields = CreateIssueFields(
            project: project,
            summary: summary,
            description: description,
            issuetype: issueTypeRef,
            priority: priorityRef,
            labels: labels
        )

        let request = CreateIssueRequest(fields: fields)

        return try await createIssue(request: request)
    }
    
    public func jsonDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZ'"
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }
    
    
    //All Sprints for board
    //        curl -u username:password -X GET -H "Content-Type: application/json" "<Base URL>/agile/latest/board/10/sprint" | python -m json.tool | less
    
    //curl -u username:password -X GET -H "Content-Type: application/json" "<Base URL>/api/2/search?jql=assignee=bill&maxResults=2" | python -m json.tool | less
    
    //All issues for sprint with 0 estimate
    //curl -u username:password -X GET -H "Content-Type: application/json" "<Base URL>/agile/latest/board/38/sprint/445/issue?maxResults=100&fields=id,summary,fixVersions&jql=timeestimate%20is%20empty" | python -m json.tool | less
    
    //curl -u username:password -X GET -H "Content-Type: application/json" "<Base URL>/agile/latest/board" | python -m json.tool | less
    
    //All issue for user
    //curl -u username:password -X GET -H "Content-Type: application/json" "<Base URL>/api/2/search?jql=assignee=bill" | python -m json.tool | less
    
}
