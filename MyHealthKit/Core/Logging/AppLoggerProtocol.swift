import Foundation

enum LogLevel {
    case debug
    case info
    case error
}

protocol AppLoggerProtocol {
    func log(_ message: String, level: LogLevel)
}

extension AppLoggerProtocol {
    func debug(_ message: String) { log(message, level: .debug) }
    func info(_ message: String) { log(message, level: .info) }
    func error(_ message: String) { log(message, level: .error) }
}
