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
        .cardBackground()
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
            .cardBackground()
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

private struct QuickActionsGrid: View {
    let onNavigate: (AppRoute) -> Void

    // Adaptive rather than a fixed 2-column split: stays 2-up on iPhone
    // widths, but grows to 3-4 columns as the available width increases
    // (iPad, or the detail pane of the split view), instead of just
    // stretching the same 2 columns wider.
    private let columns = [GridItem(.adaptive(minimum: 130, maximum: 220), spacing: 12)]

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
