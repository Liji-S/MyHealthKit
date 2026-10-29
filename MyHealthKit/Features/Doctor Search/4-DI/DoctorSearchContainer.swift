import Foundation
import NetworkKit

/// Feature-scoped composition root for Doctor Search. Owns wiring for everything
/// this feature needs; AppContainer only holds one instance of this, not each
/// dependency individually.
@MainActor
final class DoctorSearchContainer {
    private let locationProvider: LocationProvidingProtocol
    let imageCache: ImageCacheProtocol
    private let chatCompletionClient: ChatCompletionClientProtocol

    private let logger: AppLoggerProtocol = OSAppLogger(category: "DoctorSearch")

    private lazy var placesSearchCache = PlacesSearchCache()

    private lazy var placesClient: NetworkClientProtocol = NetworkClient(
        configuration: NetworkClientConfiguration(environment: .googlePlaces(apiKey: AppConfig.googlePlacesAPIKey))
    )

    private lazy var googlePlacesDataSource: GooglePlacesDataSourceProtocol = CachedGooglePlacesDataSource(
        wrapping: GooglePlacesDataSourceImpl(client: placesClient, apiKey: AppConfig.googlePlacesAPIKey),
        cache: placesSearchCache,
        logger: logger
    )

    private lazy var doctorRepository: DoctorRepositoryProtocol = DoctorRepositoryImpl(
        placesSource: googlePlacesDataSource
    )

    private lazy var searchDoctorsUseCase: SearchDoctorsUseCaseProtocol = SearchDoctorsUseCaseImpl(
        repository: doctorRepository
    )

    private lazy var parseSearchQueryUseCase: ParseDoctorSearchQueryUseCaseProtocol = ParseDoctorSearchQueryUseCaseImpl(
        chatClient: chatCompletionClient
    )

    init(
        locationProvider: LocationProvidingProtocol,
        imageCache: ImageCacheProtocol,
        chatCompletionClient: ChatCompletionClientProtocol
    ) {
        self.locationProvider = locationProvider
        self.imageCache = imageCache
        self.chatCompletionClient = chatCompletionClient
    }

    func makeDoctorSearchViewModel() -> DoctorSearchViewModel {
        DoctorSearchViewModel(
            searchUseCase: searchDoctorsUseCase,
            locationProvider: locationProvider,
            parseQueryUseCase: parseSearchQueryUseCase,
            imageCache: imageCache,
            logger: logger
        )
    }
}
