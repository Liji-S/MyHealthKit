import Foundation

protocol ImportImageUseCaseProtocol {
    func execute(data: Data, fileName: String, fileExtension: String) throws -> VaultDocument
}
