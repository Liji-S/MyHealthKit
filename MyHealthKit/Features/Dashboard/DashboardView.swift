import SwiftUI

struct DashboardView: View {
    @State private var viewModel: DashboardViewModel
    let onNavigate: (AppRoute) -> Void

    init(viewModel: DashboardViewModel, onNavigate: @escaping (AppRoute) -> Void) {
        _viewModel = State(initialValue: viewModel)
        self.onNavigate = onNavigate
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                ComplianceScoreCard()

                QuickActionsGrid(onNavigate: onNavigate)

                UpcomingExpiriesCard(medications: viewModel.upcomingRefills) {
                    onNavigate(.medicationReminders)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Home")
        .onAppear {
            viewModel.loadUpcoming()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.title2.bold())
            Text("Here's what your household needs today.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }
}

private struct ComplianceScoreCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Household Status")
                    .font(.headline)
                Spacer()
                StatusBadge(status: .comingSoon)
            }
            Text("Track visa, insurance, and document expiries for your whole family in one place.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct UpcomingExpiriesCard: View {
    let medications: [Medication]
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Upcoming")
                    .font(.headline)
                    .foregroundStyle(.primary)

                if medications.isEmpty {
                    Text("No refill reminders yet. Add a medication to see upcoming dates here.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(medications) { medication in
                            UpcomingRefillRow(medication: medication)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

private struct UpcomingRefillRow: View {
    let medication: Medication

    var body: some View {
        HStack {
            Image(systemName: "pills.fill")
                .foregroundStyle(.indigo)
            VStack(alignment: .leading, spacing: 2) {
                Text(medication.name)
                    .font(.subheadline.weight(.medium))
                if let dueDate = medication.refillDueDate {
                    Text("Refill due \(dueDate, style: .date)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
        }
    }
}

private enum FeatureStatus {
    case live
    case comingSoon
}

private struct StatusBadge: View {
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

private struct QuickActionsGrid: View {
    let onNavigate: (AppRoute) -> Void

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            QuickActionTile(title: "Find a Doctor", systemImage: "stethoscope", tint: .blue) {
                onNavigate(.doctorSearch)
            }
            QuickActionTile(title: "Emergency SOS", systemImage: "sos", tint: .red) {
                onNavigate(.emergencySOS)
            }
            QuickActionTile(title: "First Aid Guide", systemImage: "cross.case.fill", tint: .teal) {
                onNavigate(.firstAidGuide)
            }
            QuickActionTile(title: "Medication Reminders", systemImage: "pills.fill", tint: .indigo) {
                onNavigate(.medicationReminders)
            }
        }
    }
}

private struct QuickActionTile: View {
    let title: String
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(tint)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
