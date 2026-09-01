import UIKit

final class UIKitEmergencyCaller: EmergencyCallerProtocol {
    @MainActor
    func open(_ url: URL) async -> Bool {
        guard UIApplication.shared.canOpenURL(url) else { return false }
        return await UIApplication.shared.open(url)
    }
}
