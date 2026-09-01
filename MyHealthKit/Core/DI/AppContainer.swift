import Foundation
import SwiftData

/// Root composition point. Holds shared, stateless Core services and one
/// container per feature — never a feature's individual dependencies directly.
@MainActor
final class AppContainer {
    // MARK: - Core services (shared, stateless)

    lazy var locationProvider: LocationProvidingProtocol = LocationProvider()

    lazy var imageCache: ImageCacheProtocol = DiskImageCache()

    lazy var chatCompletionClient: ChatCompletionClientProtocol = OllamaChatCompletionClient(
        baseURL: AppConfig.ollamaBaseURL,
        model: AppConfig.ollamaModel
    )

    lazy var modelContainer: ModelContainer = {
        let schema = Schema([VaultDocumentRecord.self, MedicationRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Feature containers

    lazy var doctorSearch = DoctorSearchContainer(
        locationProvider: locationProvider,
        imageCache: imageCache,
        chatCompletionClient: chatCompletionClient
    )

    lazy var documentVault = DocumentVaultContainer(
        modelContext: modelContainer.mainContext,
        chatCompletionClient: chatCompletionClient
    )

    lazy var emergencySOS = EmergencySOSContainer()

    lazy var firstAid = FirstAidContainer()

    lazy var medicationReminders = MedicationRemindersContainer(modelContext: modelContainer.mainContext)

    lazy var dashboard = DashboardContainer(fetchMedicationsUseCase: medicationReminders.fetchMedicationsUseCase)
}
