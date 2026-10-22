import Foundation
import SwiftData

extension ModelContext {
    /// Fetches the first record matching `predicate`, or `nil` if none exists.
    func first<T: PersistentModel>(_ type: T.Type, where predicate: Predicate<T>) throws -> T? {
        var descriptor = FetchDescriptor<T>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try fetch(descriptor).first
    }
}
