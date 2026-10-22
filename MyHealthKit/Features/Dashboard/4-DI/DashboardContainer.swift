import Foundation

@MainActor
final class DashboardContainer {
    private let fetchMedicationsUseCase: FetchMedicationsUseCaseProtocol

    init(fetchMedicationsUseCase: FetchMedicationsUseCaseProtocol) {
        self.fetchMedicationsUseCase = fetchMedicationsUseCase
    }

    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(fetchMedicationsUseCase: fetchMedicationsUseCase)
    }
}
