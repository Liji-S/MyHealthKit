import SwiftUI

enum FeatureStatus {
    case live
    case comingSoon
}

struct StatusBadge: View {
    let status: FeatureStatus

    var body: some View {
        Text(status == .live ? "Live" : "Coming soon")
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status == .live ? Color.green.opacity(0.15) : Color.orange.opacity(0.15))
            .foregroundStyle(status == .live ? .green : .orange)
            .clipShape(Capsule())
    }
}
