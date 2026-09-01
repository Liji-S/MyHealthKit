import Foundation
import Observation

@Observable
final class EmergencySOSViewModel {
    private(set) var errorMessage: String?

    let emergencyNumber = "998"

    private let placeCallUseCase: PlaceEmergencyCallUseCaseProtocol

    init(placeCallUseCase: PlaceEmergencyCallUseCaseProtocol) {
        self.placeCallUseCase = placeCallUseCase
    }

    func call() async {
        do {
            errorMessage = nil
            try await placeCallUseCase.execute(number: emergencyNumber)
        } catch {
            errorMessage = "Couldn't open the phone dialer. Dial \(emergencyNumber) manually."
        }
    }
}
