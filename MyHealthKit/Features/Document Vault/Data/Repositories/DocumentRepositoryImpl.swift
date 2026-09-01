import Foundation
import SwiftData

final class DocumentRepositoryImpl: DocumentRepositoryProtocol {
    private let modelContext: ModelContext
    private let fileStore: DocumentFileStore

    private static let imageExtensions: Set<String> = ["jpg", "jpeg", "png", "heic"]

    init(modelContext: ModelContext, fileStore: DocumentFileStore) {
        self.modelContext = modelContext
        self.fileStore = fileStore
    }

    func fetchAll() throws -> [VaultDocument] {
        let descriptor = FetchDescriptor<VaultDocumentRecord>(
            sortBy: [SortDescriptor(\.addedAt, order: .reverse)]
        )
        let records = try modelContext.fetch(descriptor)
        return records.map { toDomain($0) }
    }

    func importDocument(from sourceURL: URL) throws -> VaultDocument {
        let id = UUID()
        let relativePath = try fileStore.copyIntoVault(sourceURL: sourceURL, id: id)
        let kind = Self.imageExtensions.contains(sourceURL.pathExtension.lowercased()) ? VaultDocumentKind.image : .pdf
        let record = VaultDocumentRecord(
            id: id,
            fileName: sourceURL.lastPathComponent,
            addedAt: Date(),
            relativePath: relativePath,
            kindRawValue: kind.rawValue
        )
        modelContext.insert(record)
        try modelContext.save()
        return toDomain(record)
    }

    func importImage(data: Data, fileName: String, fileExtension: String) throws -> VaultDocument {
        let id = UUID()
        let relativePath = try fileStore.writeIntoVault(data: data, id: id, fileExtension: fileExtension)
        let record = VaultDocumentRecord(
            id: id,
            fileName: fileName,
            addedAt: Date(),
            relativePath: relativePath,
            kindRawValue: VaultDocumentKind.image.rawValue
        )
        modelContext.insert(record)
        try modelContext.save()
        return toDomain(record)
    }

    func delete(_ document: VaultDocument) throws {
        let targetID = document.id
        let descriptor = FetchDescriptor<VaultDocumentRecord>(
            predicate: #Predicate { $0.id == targetID }
        )
        guard let record = try modelContext.fetch(descriptor).first else { return }
        try fileStore.delete(relativePath: record.relativePath)
        modelContext.delete(record)
        try modelContext.save()
    }

    private func toDomain(_ record: VaultDocumentRecord) -> VaultDocument {
        VaultDocument(
            id: record.id,
            fileName: record.fileName,
            addedAt: record.addedAt,
            fileURL: fileStore.absoluteURL(forRelativePath: record.relativePath),
            kind: VaultDocumentKind(rawValue: record.kindRawValue) ?? .pdf
        )
    }
}
