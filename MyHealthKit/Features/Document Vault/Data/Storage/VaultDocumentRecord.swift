import Foundation
import SwiftData

/// SwiftData persistence model. Kept separate from the Domain entity so
/// storage concerns (SwiftData macros, relationships) never leak upward.
@Model
final class VaultDocumentRecord {
    @Attribute(.unique) var id: UUID
    var fileName: String
    var addedAt: Date
    var relativePath: String
    var kindRawValue: String

    init(id: UUID, fileName: String, addedAt: Date, relativePath: String, kindRawValue: String) {
        self.id = id
        self.fileName = fileName
        self.addedAt = addedAt
        self.relativePath = relativePath
        self.kindRawValue = kindRawValue
    }
}
