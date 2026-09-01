import Foundation

@MainActor
final class EmergencySOSContainer {
    private lazy var emergencyCaller: EmergencyCallerProtocol = UIKitEmergencyCaller()

    private lazy var placeCallUseCase: PlaceEmergencyCallUseCaseProtocol = PlaceEmergencyCallUseCaseImpl(
        caller: emergencyCaller
    )

    func makeEmergencySOSViewModel() -> EmergencySOSViewModel {
        EmergencySOSViewModel(placeCallUseCase: placeCallUseCase)
    }
}
