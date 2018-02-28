//
//  JiraRestClient.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 10/28/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

//import Cocoa

//----------------
// Rest API Reference: https://developer.atlassian.com/jiradev/jira-apis/jira-rest-apis/jira-rest-api-tutorials
//

public class JiraRestClient: RestClient {
    
    
    public func getBoards(completionBlock:@escaping ([Board]) -> Void) {
        
        jsonFor(relativeURL: "agile/latest/board") { (json) in
            if let agileResponse = AgileResponse(json: json) {            
                
                let boards = Board.boardsWith(agileResponse: agileResponse).sorted(by: { $0.name < $1.name})
                
                completionBlock(boards)
            } else {
                //TODO: Call error block
            }            
        }
    }

    public func getCurrentSprintFor(board: Board, completion:@escaping ((Sprint?) -> Void)) -> Void {
        getSprintsFor(board: board, completion:{ (sprints) in
            for sprint in sprints {
                if sprint.state == "active" {
                    completion(sprint)
                }
            }            
            
            completion(nil)
            
        })
        
    }
    
    public func getSprintsFor(board: Board, completion:@escaping (([Sprint]) -> Void)) -> Void {
        getSprintsFor(board: board, startAt: 0, completion: completion)
    }
    
    public func getSprintsFor(board: Board, startAt: Int, completion:@escaping (([Sprint]) -> Void)) -> Void {
        
        jsonFor(relativeURL: "agile/latest/board/\(board.id)/sprint?startAt=\(startAt)") { (json) in
            
            if let agileResponse = AgileResponse(json: json) {            
                
                let sprints = Sprint.sprintsWith(agileResponse: agileResponse).sorted(by: { $0.name < $1.name})
                
                if agileResponse.isLast == false {
                    self.getSprintsFor(board: board, startAt: startAt + agileResponse.maxResults, completion: { (blockSprints)  in
                        completion(sprints + blockSprints)
                    })
                } else {
                    completion(sprints)                    
                }

            } else {
                //TODO: Call error block
                print("Error occurred")
            }
            
        }
        
    }
    
    public func issuesFor(board: Board, sprint: Sprint, completionBlock:(@escaping ([Issue]) -> Void)) {
        //FIXME - The start thing should work properly with bleow method
        let relativeURL = "agile/latest/board/\(board.id)/sprint/\(sprint.id)/issue?startAt="
        issuesFor(relativeURL: relativeURL, startAt: 0, completionBlock: completionBlock)
    }
    
    public func issuesFor(relativeURL: String, startAt: Int, completionBlock:(@escaping ([Issue]) -> Void)){
        jsonFor(relativeURL: relativeURL + "&startAt=\(startAt)") { json -> Void in
            if let issueResponse = IssueResponse(json: json) {
                let issues = issueResponse.issues
                let nextIndexToFetch = issueResponse.nextIndex()
                if nextIndexToFetch >= 0 {
                    //Recursive call to fetch next and add these results
                    self.issuesFor(relativeURL: relativeURL, startAt: nextIndexToFetch, completionBlock: { (nextIssues) in
                        completionBlock(issues + nextIssues)
                    })
                } else {
                    //Done, no more to fetch
                    completionBlock(issues)
                }
            }
        }
    }
    
    public func issuesFor(filter: JQLFilter, completionBlock:(@escaping ([Issue]) -> Void)){
        let relativeUrl = "api/2/search?" + filter.getString()
        
        issuesFor(relativeURL: relativeUrl, startAt: 0, completionBlock:completionBlock)
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
