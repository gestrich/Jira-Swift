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
        getBoards(startAt: 0, completionBlock: completionBlock)
    }
    
    public func getBoards(startAt: Int, completionBlock:@escaping (([Board]) -> Void)) -> Void {
        
        jsonDataFor(relativeURL: "agile/latest/board?startAt=\(startAt)") { (json) in
            
            let decoder = JSONDecoder()
            
            do {
                let boardResponse = try decoder.decode(BoardResponse.self, from: json)
                let boards = boardResponse.boards
                
                if boardResponse.isLast == false {
                    self.getBoards(startAt: startAt + boardResponse.maxResults, completionBlock: { (blockBoards)  in
                        completionBlock(boards + blockBoards)
                    })
                } else {
                    completionBlock(boards)                    
                }
            } catch {
                print(error)
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
        
        jsonDataFor(relativeURL: "agile/latest/board/\(board.id)/sprint?startAt=\(startAt)") { (json) in
            
            let decoder = JSONDecoder()
            
            do {
                let sprintResponse = try decoder.decode(SprintResponse.self, from: json)
                let sprints = sprintResponse.sprints
                
                if sprintResponse.isLast == false {
                    self.getSprintsFor(board: board, startAt: startAt + sprintResponse.maxResults, completion: { (blockSprints)  in
                        completion(sprints + blockSprints)
                    })
                } else {
                    completion(sprints)                    
                }
            } catch {
                print(error)
            }
            
        }
    }
    
    public func issue(identifier: String, completionBlock:(@escaping (Issue) -> Void)){
        
        jsonDataFor(relativeURL: "api/2/issue/\(identifier)") { json -> Void in
            let decoder = JSONDecoder()
            
            do {
                let issue = try decoder.decode(Issue.self, from: json)
                print(issue)
                completionBlock(issue)
            } catch {
                print(error)
            }
        }
    }

    public func issuesFor(board: Board, sprint: Sprint, completionBlock:(@escaping ([Issue]) -> Void)) {
        //FIXME - The start thing should work properly with bleow method
        let relativeURL = "agile/latest/board/\(board.id)/sprint/\(sprint.id)/issue?startAt="
        issuesFor(relativeURL: relativeURL, startAt: 0, completionBlock: completionBlock)
    }
    
    public func issuesFor(relativeURL: String, startAt: Int, completionBlock:(@escaping ([Issue]) -> Void)){
        jsonDataFor(relativeURL: relativeURL + "&startAt=\(startAt)") { json -> Void in
            
            let decoder = JSONDecoder()
            
            do {
                let issueResponse = try decoder.decode(IssueResponse.self, from: json)
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
                
            } catch {
                print(error)
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
