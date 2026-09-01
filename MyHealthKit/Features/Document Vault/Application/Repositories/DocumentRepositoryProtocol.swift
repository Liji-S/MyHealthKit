import Foundation

protocol DocumentRepositoryProtocol {
    func fetchAll() throws -> [VaultDocument]
    func importDocument(from sourceURL: URL) throws -> VaultDocument
    func importImage(data: Data, fileName: String, fileExtension: String) throws -> VaultDocument
    func delete(_ document: VaultDocument) throws
}
