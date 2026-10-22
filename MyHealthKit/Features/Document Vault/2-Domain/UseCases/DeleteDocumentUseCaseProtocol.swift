import Foundation

protocol DeleteDocumentUseCaseProtocol {
    func execute(_ document: VaultDocument) throws
}
