import Foundation

/// Whether a search result is an individual practitioner or a facility, so
/// results can list doctors ahead of the hospitals and clinics they work at.
enum ProviderKind: String, Hashable, Codable {
    case doctor
    case clinic
    case hospital
    case pharmacy
}
