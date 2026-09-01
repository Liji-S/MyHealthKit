import Foundation

/// Abstracts opening a `tel://` URL so Domain/UseCase code never imports UIKit directly.
protocol EmergencyCallerProtocol {
    @discardableResult
    func open(_ url: URL) async -> Bool
}
