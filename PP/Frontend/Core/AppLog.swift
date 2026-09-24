//
//  AppLog.swift
//  PP
//
//  Created by Ly Kimheng on 10/9/26.
//

import OSLog

nonisolated enum AppLog {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "PP", category: "app")

    static func network(_ action: String, _ error: Error) {
        let detail = (error as? APIError)?.debugDescription ?? error.localizedDescription
        logger.error("\(action, privacy: .public) failed: \(detail, privacy: .public)")
    }

    static func warning(_ message: String) {
        logger.warning("\(message, privacy: .public)")
    }
}
