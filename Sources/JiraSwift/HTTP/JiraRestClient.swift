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

public class JiraRestClient: RestClient {
    
    
    public func getBoards(completionBlock:(@escaping ([Board]) -> Void), errorBlock:(@escaping (SwiftRestTools.RestClientError) -> Void)) {
        getBoards(startAt: 0, completionBlock: completionBlock, errorBlock:errorBlock)
    }
    
    public func getBoards(startAt: Int, completionBlock:(@escaping ([Board]) -> Void), errorBlock:(@escaping (SwiftRestTools.RestClientError) -> Void)) {
        
        getData(relativeURL: "agile/latest/board?startAt=\(startAt)", completionBlock: { (json) in
            
            let decoder = self.jsonDecoder()
            
            do {
                let boardResponse = try decoder.decode(BoardResponse.self, from: json)
                let boards = boardResponse.boards
                
                if boardResponse.isLast == false {
                    self.getBoards(startAt: startAt + boardResponse.maxResults, completionBlock: { (blockBoards)  in
                        completionBlock(boards + blockBoards)
                    }, errorBlock:errorBlock)
                } else {
                    completionBlock(boards)                    
                }
            } catch {
                errorBlock(.deserialization(error))
            }
            
        }, errorBlock:errorBlock)
    }
    
    public func getCurrentSprint(for board: Board, completionBlock:(@escaping (Sprint?) -> Void), errorBlock:(@escaping (SwiftRestTools.RestClientError) -> Void))  {
        getSprints(for:board, completionBlock:{ (sprints) in
            for sprint in sprints {
                if sprint.state == "active" {
                    completionBlock(sprint)
                }
            }            
            
            completionBlock(nil)
            
        }, errorBlock:errorBlock)
        
    }
    
    public func getSprints(for board:Board, completionBlock:(@escaping ([Sprint]) -> Void), errorBlock:(@escaping (SwiftRestTools.RestClientError) -> Void)) {
        getSprints(for: board, startAt: 0, completionBlock: completionBlock, errorBlock:errorBlock)
    }
    
    public func getSprints(for board:Board, startAt: Int, completionBlock:(@escaping ([Sprint]) -> Void), errorBlock:(@escaping (SwiftRestTools.RestClientError) -> Void))  {
        
        getData(relativeURL: "agile/latest/board/\(board.id)/sprint?startAt=\(startAt)", completionBlock: { (json) in
            
            let decoder = self.jsonDecoder()
            
            do {
                let sprintResponse = try decoder.decode(SprintResponse.self, from: json)
                let sprints = sprintResponse.sprints
                
                if sprintResponse.isLast == false {
                    self.getSprints(for: board, startAt: startAt + sprintResponse.maxResults, completionBlock: { (blockSprints)  in
                        completionBlock(sprints + blockSprints)
                    }, errorBlock:errorBlock)
                } else {
                    completionBlock(sprints)                    
                }
            } catch {
                errorBlock(.deserialization(error))
            }
            
        }, errorBlock:errorBlock)
    }
    
    public func issue(identifier: String, completionBlock:(@escaping (Issue) -> Void), errorBlock:(@escaping (SwiftRestTools.RestClientError) -> Void))  {
        
        getData(relativeURL: "api/2/issue/\(identifier)", completionBlock: { (json) in
            let decoder = self.jsonDecoder()
            
            do {
                let issue = try decoder.decode(Issue.self, from: json)
                completionBlock(issue)
            } catch {
                errorBlock(.deserialization(error))
            }
        }, errorBlock:errorBlock)
    }
    
    public func issues(for board: Board, sprint: Sprint, completionBlock:(@escaping ([Issue]) -> Void), errorBlock:(@escaping (SwiftRestTools.RestClientError) -> Void)) {
        //FIXME - The start thing should work properly with bleow method
        let relativeURL = "agile/latest/board/\(board.id)/sprint/\(sprint.id)/issue?startAt="
        issues(for: relativeURL, startAt: 0, completionBlock: completionBlock, errorBlock:errorBlock)
    }
    
    func issues(for relativeURL: String, startAt: Int, completionBlock:(@escaping ([Issue]) -> Void), errorBlock:(@escaping (SwiftRestTools.RestClientError) -> Void)){
        getData(relativeURL: relativeURL + "&startAt=\(startAt)", completionBlock: { (json) in
            
            let decoder = self.jsonDecoder()
            
            do {
                let issueResponse = try decoder.decode(IssueResponse.self, from: json)
                let issues = issueResponse.issues
                let nextIndexToFetch = issueResponse.nextIndex()
                if nextIndexToFetch >= 0 {
                    //Recursive call to fetch next and add these results
                    self.issues(for: relativeURL, startAt: nextIndexToFetch, completionBlock: { (nextIssues) in
                        completionBlock(issues + nextIssues)
                    }, errorBlock:errorBlock)
                } else {
                    //Done, no more to fetch
                    completionBlock(issues)
                }
                
            } catch {
                errorBlock(.deserialization(error))
            }
            
        }, errorBlock:errorBlock)
    }
    
    
    public func issues(for filter: JQLFilter, completionBlock:(@escaping ([Issue]) -> Void), errorBlock:(@escaping (SwiftRestTools.RestClientError) -> Void)) {
        let relativeUrl = "api/2/search?" + filter.getString()
        
        issues(for: relativeUrl, startAt: 0, completionBlock:completionBlock, errorBlock:errorBlock)
    }
    
    public func uploadFile(filePath: String, issueIdentifier: String, completionBlock:(@escaping () -> Void), errorBlock:(@escaping (SwiftRestTools.RestClientError) -> Void))  {
        
        uploadFile(filePath: filePath, relativeDestinationPath: "api/2/issue/\(issueIdentifier)/attachments", completionBlock: { (data) in
            //TODO: Validate the JSON data here.
            completionBlock()
        }, errorBlock:errorBlock)
        
    }
    
    // MARK: - Create Issue
    
    public func createIssue(request: CreateIssueRequest,
                           completionBlock: @escaping (CreateIssueResponse) -> Void,
                           errorBlock: @escaping (SwiftRestTools.RestClientError) -> Void) {
        
        // Use peformJSONPost from the parent RestClient class
        peformJSONPost(relativeURL: "api/2/issue", payload: request, completionBlock: { (data) in
            let decoder = self.jsonDecoder()
            
            do {
                let response = try decoder.decode(CreateIssueResponse.self, from: data)
                completionBlock(response)
            } catch {
                errorBlock(.deserialization(error))
            }
        }, errorBlock: errorBlock)
    }
    
    // Convenience method for simple issue creation
    public func createIssue(projectKey: String,
                           issueType: String,
                           summary: String,
                           description: String? = nil,
                           priority: String? = nil,
                           labels: [String]? = nil,
                           completionBlock: @escaping (CreateIssueResponse) -> Void,
                           errorBlock: @escaping (SwiftRestTools.RestClientError) -> Void) {
        
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
        
        createIssue(request: request, completionBlock: completionBlock, errorBlock: errorBlock)
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
