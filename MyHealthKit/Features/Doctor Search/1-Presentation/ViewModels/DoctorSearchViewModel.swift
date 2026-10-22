import CoreLocation
import Foundation
import Observation
import UIKit

@Observable
final class DoctorSearchViewModel {
    private(set) var doctors: [Doctor] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var isParsingQuery = false
    private(set) var hasSearched = false

    /// Resolved photo images, keyed by Doctor.id. Fetched once per search
    /// result set here in the ViewModel rather than via a per-card async task
    /// in the view — ~20 cards each running their own concurrent .task(id:)
    /// image fetch was disrupting SwiftUI's touch handling: main-thread
    /// contention from that much simultaneous async churn made Button taps on
    /// visible cards intermittently fail to register, unrelated to any single
    /// card's load timing. Resolving images up front means card views have no
    /// ongoing async work of their own to interfere with gestures.
    private(set) var resolvedImages: [String: UIImage] = [:]

    private(set) var specialty: String = ""
    var radiusInMeters: Double = 20000
    var searchText: String = ""

    private let searchUseCase: SearchDoctorsUseCaseProtocol
    private let locationProvider: LocationProvidingProtocol
    private let parseQueryUseCase: ParseDoctorSearchQueryUseCaseProtocol
    private let imageCache: ImageCacheProtocol
    private let logger: AppLoggerProtocol

    init(
        searchUseCase: SearchDoctorsUseCaseProtocol,
        locationProvider: LocationProvidingProtocol,
        parseQueryUseCase: ParseDoctorSearchQueryUseCaseProtocol,
        imageCache: ImageCacheProtocol,
        logger: AppLoggerProtocol
    ) {
        self.searchUseCase = searchUseCase
        self.locationProvider = locationProvider
        self.parseQueryUseCase = parseQueryUseCase
        self.imageCache = imageCache
        self.logger = logger
    }

    func search(forceRefresh: Bool = false) async {
        hasSearched = true
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        await locationProvider.requestAuthorization()

        let location: CLLocation
        do {
            location = try await locationProvider.currentLocation()
        } catch {
            logger.error("currentLocation() failed: \(error)")
            errorMessage = "Couldn't determine your location. Check location permissions and try again."
            return
        }

        let criteria = SearchCriteria(
            specialty: specialty.isEmpty ? nil : specialty,
            radiusInMeters: radiusInMeters,
            userLatitude: location.coordinate.latitude,
            userLongitude: location.coordinate.longitude
        )

        do {
            doctors = try await searchUseCase.execute(criteria: criteria, forceRefresh: forceRefresh)
            logger.info("Search returned \(doctors.count) doctors")
            await loadImages(for: doctors)
        } catch {
            logger.error("searchUseCase.execute() failed: \(error)")
            errorMessage = "Couldn't load nearby doctors. Please try again."
        }
    }

    /// Parses `searchText` — a specialty word or a free-text query like
    /// "Arabic speaking dermatologist near me" — into a specialty filter,
    /// then runs the search.
    func searchFromText() async {
        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        isParsingQuery = true
        errorMessage = nil
        defer { isParsingQuery = false }

        do {
            let filters = try await parseQueryUseCase.execute(query: trimmedQuery)
            specialty = filters.searchQuery ?? trimmedQuery
            await search()
        } catch {
            errorMessage = "Couldn't understand that. Try a simpler search term."
        }
    }

    private func loadImages(for doctors: [Doctor]) async {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
        await withTaskGroup(of: (String, UIImage?).self) { group in
            for doctor in doctors {
                guard let photoURL = doctor.photoURL else { continue }
                group.addTask { [imageCache] in
                    let data = try? await imageCache.image(
                        for: photoURL,
                        headers: ["X-Ios-Bundle-Identifier": bundleIdentifier]
                    )
                    return (doctor.id, data.flatMap { UIImage(data: $0) })
                }
            }
            for await (id, image) in group {
                if let image {
                    resolvedImages[id] = image
                }
            }
        }
    }
}
