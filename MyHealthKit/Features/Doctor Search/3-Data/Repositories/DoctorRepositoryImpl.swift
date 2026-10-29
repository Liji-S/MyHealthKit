import CoreLocation

final class DoctorRepositoryImpl: DoctorRepositoryProtocol {
    private let placesSource: GooglePlacesDataSourceProtocol

    init(placesSource: GooglePlacesDataSourceProtocol) {
        self.placesSource = placesSource
    }

    func search(criteria: SearchCriteria, forceRefresh: Bool) async throws -> [Doctor] {
        let userLocation = CLLocation(latitude: criteria.userLatitude, longitude: criteria.userLongitude)

        let results = try await placesSource.searchMedicalFacilities(
            specialty: criteria.specialty,
            latitude: criteria.userLatitude,
            longitude: criteria.userLongitude,
            radiusInMeters: criteria.radiusInMeters,
            forceRefresh: forceRefresh
        )

        // Text search only biases toward the location, unlike nearby search's
        // hard radius restriction, so still clamp to the requested radius.
        let withinRadius = results.filter { doctor in
            CLLocation(latitude: doctor.latitude, longitude: doctor.longitude).distance(from: userLocation) <= criteria.radiusInMeters
        }
        return sortDoctorsFirst(withinRadius, from: userLocation)
    }

    /// Individual doctors before facilities, each group nearest first.
    private func sortDoctorsFirst(_ doctors: [Doctor], from userLocation: CLLocation) -> [Doctor] {
        doctors.sorted {
            let isDoctor1 = $0.kind == .doctor
            let isDoctor2 = $1.kind == .doctor
            if isDoctor1 != isDoctor2 {
                return isDoctor1
            }
            let d1 = CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: userLocation)
            let d2 = CLLocation(latitude: $1.latitude, longitude: $1.longitude).distance(from: userLocation)
            return d1 < d2
        }
    }
}


