import Foundation
import os

/// Wraps os.Logger so call sites depend on AppLoggerProtocol, not a specific
/// logging framework — swappable for a no-op/spy implementation in tests.
/// `category` shows up in Console.app/log stream, letting you filter to one
/// feature's logs instead of scrolling through everything.
struct OSAppLogger: AppLoggerProtocol {
    private let logger: Logger

    init(category: String) {
        logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "MyHealthKit", category: category)
    }

    func log(_ message: String, level: LogLevel) {
        switch level {
        case .debug:
            logger.debug("\(message, privacy: .public)")
        case .info:
            logger.info("\(message, privacy: .public)")
        case .error:
            logger.error("\(message, privacy: .public)")
        }
    }
}
