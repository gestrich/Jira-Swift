//
//  StringTools.swift
//  JiraSwift
//
//  Created by Bill Gestrich on 10/14/17.
//  Copyright © 2017 Bill Gestrich. All rights reserved.
//

import Foundation

extension String {
    func regex (pattern: String, captureGroup: Int) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options:.anchorsMatchLines)
            let nsstr = self as NSString
            let all = NSRange(location: 0, length: nsstr.length)
            var matches : [String] = [String]()
            regex.enumerateMatches(in: self, options: [], range: all) {
                (result : NSTextCheckingResult?, _, _) in
                if let r = result {
                    if r.numberOfRanges > captureGroup {
                        let result = nsstr.substring(with: r.range(at: captureGroup)) as String
                        matches.append(result)
                        
                    } else {
                        let result = nsstr.substring(with: r.range) as String
                        matches.append(result)                        
                    }
                }
            }
            return matches
        } catch {
            return [String]()
        }
    }
    
    func getPartAfter(toSearch: String) -> String {
        
        var toRet = ""
        if let range = self.range(of: toSearch) {
            toRet = self.substring(from: range.upperBound)
        }    
        
        return toRet
    }
    
}


extension String {
    
    /// Percent escapes values to be added to a URL query as specified in RFC 3986
    ///
    /// This percent-escapes all characters besides the alphanumeric character set and "-", ".", "_", and "~".
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// - returns: Returns percent-escaped string.
    
    func addingPercentEncodingForURLQueryValue() -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: generalDelimitersToEncode + subDelimitersToEncode)
        
        return addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
    }
    
}


//https://stackoverflow.com/questions/27327067/append-text-or-data-to-text-file-in-swift

extension String {
    func appendLineToURL(fileURL: URL) throws {
        try (self + "\n").appendToURL(fileURL: fileURL)
    }
    
    func appendToURL(fileURL: URL) throws {
        let data = self.data(using: String.Encoding.utf8) ?? Data()
        try data.append(fileURL: fileURL)
    }
}

extension Data {
    func append(fileURL: URL) throws {
        if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
            defer {
                fileHandle.closeFile()
            }
            fileHandle.seekToEndOfFile()
            fileHandle.write(self)
        }
        else {
            try write(to: fileURL, options: .atomic)
        }
    }
}
