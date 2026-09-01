import Foundation

enum EmergencyCallError: Error {
    case invalidNumber
    case couldNotOpenDialer
}

protocol PlaceEmergencyCallUseCaseProtocol {
    func execute(number: String) async throws
}
