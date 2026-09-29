//
//  APIError.swift
//  PP
//
//  Created by Ly Kimheng on 10/9/26.
//

import Foundation

nonisolated enum APIError: LocalizedError, Equatable {
    case invalidURL
    case network(String)
    case server(String)
    case decoding(String)


    var message: LocalizedStringResource {
        switch self {
        case .invalidURL:            return "Something went wrong. Please try again."
        case .network:               return "No connection. Check your network and try again."
        case .server(let message):   return .dynamic(message)
        case .decoding:              return "The server sent something we couldn't read."
        }
    }

    var errorDescription: String? { String(localized: message) }

    var debugDescription: String {
        switch self {
        case .invalidURL:            return "APIError.invalidURL"
        case .network(let detail):   return "APIError.network(\(detail))"
        case .server(let detail):    return "APIError.server(\(detail))"
        case .decoding(let detail):  return "APIError.decoding(\(detail))"
        }
    }
}
