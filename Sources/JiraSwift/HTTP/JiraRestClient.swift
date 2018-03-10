//
//  JiraRestClient.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 10/28/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

// Jira Rest API Reference: https://developer.atlassian.com/jiradev/jira-apis/jira-rest-apis/jira-rest-api-tutorials

import Foundation 

public class JiraRestClient: RestClient {
    
    
    public func getBoards(completionBlock:(@escaping ([Board]) -> Void), errorBlock:(@escaping (RestClientError) -> Void)) {
        getBoards(startAt: 0, completionBlock: completionBlock, errorBlock:errorBlock)
    }
    
    public func getBoards(startAt: Int, completionBlock:(@escaping ([Board]) -> Void), errorBlock:(@escaping (RestClientError) -> Void)) {
        
        jsonData(relativeURL: "agile/latest/board?startAt=\(startAt)", completionBlock: { (json) in
            
            let decoder = JSONDecoder()
            
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
    
    public func getCurrentSprint(for board: Board, completionBlock:(@escaping (Sprint?) -> Void), errorBlock:(@escaping (RestClientError) -> Void))  {
        getSprints(for:board, completionBlock:{ (sprints) in
            for sprint in sprints {
                if sprint.state == "active" {
                    completionBlock(sprint)
                }
            }            
            
            completionBlock(nil)
            
        }, errorBlock:errorBlock)
        
    }
    
    public func getSprints(for board:Board, completionBlock:(@escaping ([Sprint]) -> Void), errorBlock:(@escaping (RestClientError) -> Void)) {
        getSprints(for: board, startAt: 0, completionBlock: completionBlock, errorBlock:errorBlock)
    }
    
    public func getSprints(for board:Board, startAt: Int, completionBlock:(@escaping ([Sprint]) -> Void), errorBlock:(@escaping (RestClientError) -> Void))  {
        
        jsonData(relativeURL: "agile/latest/board/\(board.id)/sprint?startAt=\(startAt)", completionBlock: { (json) in
            
            let decoder = JSONDecoder()
            
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
    
    public func issue(identifier: String, completionBlock:(@escaping (Issue) -> Void), errorBlock:(@escaping (RestClientError) -> Void))  {
        
        jsonData(relativeURL: "api/2/issue/\(identifier)", completionBlock: { (json) in
            let decoder = JSONDecoder()
            
            do {
                let issue = try decoder.decode(Issue.self, from: json)
                print(issue)
                completionBlock(issue)
            } catch {
                errorBlock(.deserialization(error))
            }
        }, errorBlock:errorBlock)
    }
    
    public func issues(for board: Board, sprint: Sprint, completionBlock:(@escaping ([Issue]) -> Void), errorBlock:(@escaping (RestClientError) -> Void)) {
        //FIXME - The start thing should work properly with bleow method
        let relativeURL = "agile/latest/board/\(board.id)/sprint/\(sprint.id)/issue?startAt="
        issues(for: relativeURL, startAt: 0, completionBlock: completionBlock, errorBlock:errorBlock)
    }
    
    func issues(for relativeURL: String, startAt: Int, completionBlock:(@escaping ([Issue]) -> Void), errorBlock:(@escaping (RestClientError) -> Void)){
        jsonData(relativeURL: relativeURL + "&startAt=\(startAt)", completionBlock: { (json) in
            
            let decoder = JSONDecoder()
            
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
    
    
    public func issues(for filter: JQLFilter, completionBlock:(@escaping ([Issue]) -> Void), errorBlock:(@escaping (RestClientError) -> Void)) {
        let relativeUrl = "api/2/search?" + filter.getString()
        
        issues(for: relativeUrl, startAt: 0, completionBlock:completionBlock, errorBlock:errorBlock)
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
