//
//  Logger.swift
//  NetflixProject
//
//  Created by George Popkich on 1.04.26.
//

import Foundation

final class Logger {
    enum Level: String {
        case success = "✅ Success"
        case error = "❌ Error"
        case info = "ℹ️ Info"
    }

    private let context: String

    init<T>(_ type: T.Type) {
        self.context = String(describing: type)
    }

    init(context: String) {
        self.context = context
    }

    private func log(_ message: String, level: Level) {
        print("[\(level.rawValue)] [\(context)]: \(message)")
    }

    func success(_ message: String) {
        log(message, level: .success)
    }

    func error(_ message: String) {
        log(message, level: .error)
    }

    func info(_ message: String) {
        log(message, level: .info)
    }
}
