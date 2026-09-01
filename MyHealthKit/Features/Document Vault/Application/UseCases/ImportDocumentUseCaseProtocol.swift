import Foundation

protocol ImportDocumentUseCaseProtocol {
    func execute(sourceURL: URL) throws -> VaultDocument
}
