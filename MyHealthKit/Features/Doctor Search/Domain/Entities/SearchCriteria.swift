import Foundation

struct SearchCriteria: Hashable {
    var specialty: String?
    var radiusInMeters: Double
    var userLatitude: Double
    var userLongitude: Double
}
