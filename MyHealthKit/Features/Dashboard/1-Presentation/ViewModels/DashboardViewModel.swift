import Foundation
import Observation

@Observable
final class DashboardViewModel {
    private(set) var upcomingRefills: [Medication] = []

    private let fetchMedicationsUseCase: FetchMedicationsUseCaseProtocol

    init(fetchMedicationsUseCase: FetchMedicationsUseCaseProtocol) {
        self.fetchMedicationsUseCase = fetchMedicationsUseCase
    }

    func loadUpcoming() {
        let medications = (try? fetchMedicationsUseCase.execute()) ?? []
        upcomingRefills = medications
            .filter { $0.refillDueDate != nil }
            .sorted { ($0.refillDueDate ?? .distantFuture) < ($1.refillDueDate ?? .distantFuture) }
            .prefix(3)
            .map { $0 }
    }
}
