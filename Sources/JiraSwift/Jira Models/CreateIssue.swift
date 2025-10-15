//
//  CreateIssue.swift
//  JiraSwift
//
//  Models for creating Jira issues via REST API
//

import Foundation

// MARK: - Request Models

public struct CreateIssueRequest: Codable, Sendable {
    public let fields: CreateIssueFields
    
    public init(fields: CreateIssueFields) {
        self.fields = fields
    }
}

public struct CreateIssueFields: Codable, Sendable {
    public let project: ProjectRef
    public let summary: String
    public let description: String?
    public let issuetype: IssueTypeRef
    public let priority: PriorityRef?
    public let labels: [String]?
    public let components: [ComponentRef]?
    public let assignee: AssigneeRef?
    
    // Custom fields can be added dynamically
    private var customFields: [String: AnyCodable] = [:]
    
    public init(project: ProjectRef,
                summary: String,
                description: String? = nil,
                issuetype: IssueTypeRef,
                priority: PriorityRef? = nil,
                labels: [String]? = nil,
                components: [ComponentRef]? = nil,
                assignee: AssigneeRef? = nil) {
        self.project = project
        self.summary = summary
        self.description = description
        self.issuetype = issuetype
        self.priority = priority
        self.labels = labels
        self.components = components
        self.assignee = assignee
    }
    
    // Allow adding custom fields
    public mutating func setCustomField(id: String, value: AnyCodable) {
        customFields[id] = value
    }
    
    enum CodingKeys: String, CodingKey {
        case project, summary, description, issuetype, priority, labels, components, assignee
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(project, forKey: .project)
        try container.encode(summary, forKey: .summary)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(issuetype, forKey: .issuetype)
        try container.encodeIfPresent(priority, forKey: .priority)
        try container.encodeIfPresent(labels, forKey: .labels)
        try container.encodeIfPresent(components, forKey: .components)
        try container.encodeIfPresent(assignee, forKey: .assignee)
        
        // Encode custom fields
        var dynamicContainer = encoder.container(keyedBy: DynamicCodingKeys.self)
        for (key, value) in customFields {
            let codingKey = DynamicCodingKeys(stringValue: key)!
            try dynamicContainer.encode(value, forKey: codingKey)
        }
    }
}

// MARK: - Reference Types

public struct ProjectRef: Codable, Sendable {
    public let key: String?
    public let id: String?
    
    public init(key: String) {
        self.key = key
        self.id = nil
    }
    
    public init(id: String) {
        self.id = id
        self.key = nil
    }
}

public struct IssueTypeRef: Codable, Sendable {
    public let name: String?
    public let id: String?
    
    public init(name: String) {
        self.name = name
        self.id = nil
    }
    
    public init(id: String) {
        self.id = id
        self.name = nil
    }
}

public struct PriorityRef: Codable, Sendable {
    public let name: String?
    public let id: String?
    
    public init(name: String) {
        self.name = name
        self.id = nil
    }
    
    public init(id: String) {
        self.id = id
        self.name = nil
    }
}

public struct ComponentRef: Codable, Sendable {
    public let name: String?
    public let id: String?
    
    public init(name: String) {
        self.name = name
        self.id = nil
    }
    
    public init(id: String) {
        self.id = id
        self.name = nil
    }
}

public struct AssigneeRef: Codable, Sendable {
    public let accountId: String?
    public let name: String?
    
    public init(accountId: String) {
        self.accountId = accountId
        self.name = nil
    }
    
    public init(name: String) {
        self.name = name
        self.accountId = nil
    }
}

// MARK: - Response Models

public struct CreateIssueResponse: Codable, Sendable {
    public let id: String
    public let key: String
    public let `self`: String
    
    public var issueURL: String? {
        // Extract base URL and construct browse URL
        if let url = URL(string: self.`self`),
           let scheme = url.scheme,
           let host = url.host {
            let baseURL = "\(scheme)://\(host)"
            return "\(baseURL)/browse/\(key)"
        }
        return nil
    }
}

// MARK: - Helper Types

struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        return nil
    }
}

// Type-erased wrapper for encoding any Codable value
public struct AnyCodable: Codable, @unchecked Sendable {
    private let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            value = intVal
        } else if let doubleVal = try? container.decode(Double.self) {
            value = doubleVal
        } else if let boolVal = try? container.decode(Bool.self) {
            value = boolVal
        } else if let stringVal = try? container.decode(String.self) {
            value = stringVal
        } else if let arrayVal = try? container.decode([AnyCodable].self) {
            value = arrayVal
        } else if let dictVal = try? container.decode([String: AnyCodable].self) {
            value = dictVal
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode value")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let intVal as Int:
            try container.encode(intVal)
        case let doubleVal as Double:
            try container.encode(doubleVal)
        case let boolVal as Bool:
            try container.encode(boolVal)
        case let stringVal as String:
            try container.encode(stringVal)
        case let arrayVal as [Any]:
            try container.encode(arrayVal.map { AnyCodable($0) })
        case let dictVal as [String: Any]:
            try container.encode(dictVal.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unable to encode value"))
        }
    }
}
