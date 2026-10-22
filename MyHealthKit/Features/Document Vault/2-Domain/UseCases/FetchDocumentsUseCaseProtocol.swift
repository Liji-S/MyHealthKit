import Foundation

protocol FetchDocumentsUseCaseProtocol {
    func execute() throws -> [VaultDocument]
}
