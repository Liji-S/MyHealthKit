import Foundation

protocol PlaceEmergencyCallUseCaseProtocol {
    func execute(number: String) async throws
}
