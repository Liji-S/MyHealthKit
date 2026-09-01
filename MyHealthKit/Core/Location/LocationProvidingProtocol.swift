import CoreLocation

enum LocationError: Error {
    case permissionDenied
    case unavailable
}

/// Stateless contract wrapping CoreLocation. Shared across features (Doctor Search, SOS)
/// as a service, never as mutable app state.
protocol LocationProvidingProtocol {
    func requestAuthorization() async
    func currentLocation() async throws -> CLLocation
}
