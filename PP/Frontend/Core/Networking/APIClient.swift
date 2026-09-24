//
//  APIClient.swift
//  PP
//
//  Created by Ly Kimheng on 10/9/26.
//

import Foundation

protocol APIResponse: Decodable, Sendable {
    nonisolated var success: Bool { get }
    nonisolated var message: String? { get }
}

nonisolated extension APIResponse {
    var message: String? { nil }
}

nonisolated final class APIClient: Sendable {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(session: URLSession = .api) {
        self.session = session
    }

    // MARK: - Requests

    func get<Response: APIResponse>(
        _ path: String,
        query: [String: String] = [:]
    ) async throws -> Response {
        try await perform(path, method: .get, query: query, body: Optional<Empty>.none)
    }

    @discardableResult
    func send<Body: Encodable, Response: APIResponse>(
        _ path: String,
        method: HTTPMethod,
        body: Body
    ) async throws -> Response {
        try await perform(path, method: method, query: [:], body: body)
    }

    // MARK: - Core

    private func perform<Body: Encodable, Response: APIResponse>(
        _ path: String,
        method: HTTPMethod,
        query: [String: String],
        body: Body?
    ) async throws -> Response {
        let request = try makeRequest(path: path, method: method, query: query, body: body)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError where error.code == .cancelled {
            throw APIError.network("cancelled")
        } catch {
            throw APIError.network(error.localizedDescription)
        }

        let decoded: Response
        do {
            decoded = try decoder.decode(Response.self, from: data)
        } catch {
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                throw Self.failure(status: http.statusCode, body: data)
            }
            throw APIError.decoding("\(Response.self): \(error)")
        }

        guard decoded.success else {
            throw APIError.server(decoded.message ?? "Something went wrong. Please try again.")
        }

        return decoded
    }

    private func makeRequest<Body: Encodable>(
        path: String,
        method: HTTPMethod,
        query: [String: String],
        body: Body?
    ) throws -> URLRequest {
        var components = URLComponents(
            url: API.apiURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        )
        if !query.isEmpty {
            components?.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components?.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                throw APIError.decoding("encoding \(Body.self): \(error)")
            }
        }

        return request
    }

    private static func failure(status: Int, body: Data) -> APIError {
        let serverText = serverMessage(in: body)

        guard (400..<500).contains(status) else {
            AppLog.warning("Server error \(status): \(serverText ?? "no message")")
            return .server("The server ran into a problem. Please try again in a moment.")
        }

        guard let serverText, !serverText.isEmpty, serverText.count <= 200 else {
            return .server("That request couldn't be completed. Please check your details and try again.")
        }

        return .server(serverText)
    }

    private static func serverMessage(in data: Data) -> String? {
        struct ErrorBody: Decodable { let message: String? }
        return (try? JSONDecoder().decode(ErrorBody.self, from: data))?.message
    }

    private struct Empty: Encodable {}
}

// MARK: - Session

extension URLSession {
    nonisolated static let api: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.timeoutIntervalForRequest = 20
        return URLSession(configuration: configuration)
    }()
    nonisolated static let images: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.urlCache = URLCache(
            memoryCapacity: 32 * 1024 * 1024,
            diskCapacity: 256 * 1024 * 1024
        )
        configuration.timeoutIntervalForRequest = 30
        return URLSession(configuration: configuration)
    }()
}
