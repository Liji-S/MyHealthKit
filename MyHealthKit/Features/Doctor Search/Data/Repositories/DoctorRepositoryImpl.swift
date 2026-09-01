import CoreLocation

final class DoctorRepositoryImpl: DoctorRepositoryProtocol {
    private let placesSource: GooglePlacesDataSourceProtocol

    init(placesSource: GooglePlacesDataSourceProtocol) {
        self.placesSource = placesSource
    }

    func search(criteria: SearchCriteria, forceRefresh: Bool) async throws -> [Doctor] {
        let userLocation = CLLocation(latitude: criteria.userLatitude, longitude: criteria.userLongitude)

        let results = try await placesSource.nearbyMedicalFacilities(
            latitude: criteria.userLatitude,
            longitude: criteria.userLongitude,
            radiusInMeters: criteria.radiusInMeters,
            forceRefresh: forceRefresh
        )

        let filtered = filter(results, by: criteria, userLocation: userLocation)
        return sortByDistance(filtered, from: userLocation)
    }

    private func filter(_ doctors: [Doctor], by criteria: SearchCriteria, userLocation: CLLocation) -> [Doctor] {
        doctors.filter { doctor in
            let doctorLocation = CLLocation(latitude: doctor.latitude, longitude: doctor.longitude)
            guard doctorLocation.distance(from: userLocation) <= criteria.radiusInMeters else { return false }

            if let specialty = criteria.specialty, !specialty.isEmpty {
                guard doctor.specialty.localizedCaseInsensitiveContains(specialty) else { return false }
            }
            return true
        }
    }

    private func sortByDistance(_ doctors: [Doctor], from userLocation: CLLocation) -> [Doctor] {
        doctors.sorted {
            let d1 = CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: userLocation)
            let d2 = CLLocation(latitude: $1.latitude, longitude: $1.longitude).distance(from: userLocation)
            return d1 < d2
        }
    }
}
