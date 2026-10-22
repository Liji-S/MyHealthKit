import Foundation

struct PlaceEmergencyCallUseCaseImpl: PlaceEmergencyCallUseCaseProtocol {
    private let caller: EmergencyCallerProtocol

    init(caller: EmergencyCallerProtocol) {
        self.caller = caller
    }

    func execute(number: String) async throws {
        guard let url = URL(string: "tel://\(number)") else {
            throw EmergencyCallError.invalidNumber
        }
        let opened = await caller.open(url)
        guard opened else {
            throw EmergencyCallError.couldNotOpenDialer
        }
    }
}
