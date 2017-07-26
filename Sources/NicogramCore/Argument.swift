//
//  Utility.swift
//  nico
//
//  Created by gibachan on 2017/07/24.
//
//

import Foundation

func extractVideoId(_ url: String) -> String? {
    let regex = try! NSRegularExpression(pattern: "^http.*/watch/(sm\\d+)/*", options
        : [.caseInsensitive])
    let nsUrl = NSString(string: url)
    let range = NSRange(location: 0, length: nsUrl.length)
    let match = regex.firstMatch(in: url, options: [], range:
        range)
    if let match = match, match.numberOfRanges == 2 {
        let resultRange = match.rangeAt(1)
        return nsUrl.substring(with: resultRange)
    }
    return nil
}


enum ArgumentError: Error {
    case Insufficient
    case InvalidEmail
    case InvalidPassword
}

enum ArgumentType {
    case Standard
    case Email
    case Password
    
    init(value: String) {
        if value.range(of: "-")?.lowerBound == value.startIndex {
            let option = value.replacingOccurrences(of: "-", with: "").lowercased()
            switch option {
            case "e", "email":
                self = .Email
            case "p", "password":
                self = .Password
            default:
                self = .Standard
            }
        } else {
            self = .Standard
        }
    }
}

func parseArguments(_ arguments: [String]) throws -> (String, String, String) {
    var email = ""
    var password = ""
    var videoUrl = ""
    
    var i = 1
    while i < arguments.count {
        let current = ArgumentType(value: arguments[i])
        switch current {
        case .Standard:
            videoUrl = arguments[i]
        case .Email:
            if i == arguments.count - 1 {
                throw ArgumentError.InvalidEmail
            }
            if arguments[i + 1].range(of: "-")?.lowerBound == arguments[i + 1].startIndex {
                throw ArgumentError.InvalidEmail
            }
            
            email = arguments[i + 1]
            i += 1
        case .Password:
            if i == arguments.count - 1 {
                throw ArgumentError.InvalidPassword
            }
            if arguments[i + 1].range(of: "-")?.lowerBound == arguments[i + 1].startIndex {
                throw ArgumentError.InvalidEmail
            }
            
            password = arguments[i + 1]
            i += 1
        }
        i += 1
    }
    
    if email.isEmpty || password.isEmpty || videoUrl.isEmpty {
        throw ArgumentError.Insufficient
    }
    
    return (email, password, videoUrl)
}


