import SwiftUI
import UIKit

struct DoctorSearchView: View {
    @State private var viewModel: DoctorSearchViewModel
    @FocusState private var focusedField: Field?

    private enum Field {
        case search
    }

    init(viewModel: DoctorSearchViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            Section {
                searchCard
            }
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)

            if viewModel.isLoading {
                ProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            } else if !viewModel.hasSearched {
                ContentUnavailableView(
                    "Search for a Doctor",
                    systemImage: "stethoscope",
                    description: Text("Enter a specialty or describe what you need above.")
                )
            } else if viewModel.doctors.isEmpty {
                ContentUnavailableView(
                    "No Results",
                    systemImage: "stethoscope",
                    description: Text("Try a different search or widen your filter.")
                )
            } else {
                ForEach(viewModel.doctors) { doctor in
                    DoctorCard(doctor: doctor, resolvedImage: viewModel.resolvedImages[doctor.id])
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.plain)
        .background(Color(.systemGroupedBackground))
        .scrollDismissesKeyboard(.immediately)
        .navigationTitle("Find a Doctor")
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
            }
        }
        .refreshable {
            await viewModel.search(forceRefresh: true)
        }
    }

    private var searchCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Find a doctor")
                .font(.subheadline.weight(.semibold))
            HStack {
                TextField("e.g. dermatologist, or \"Arabic speaking dermatologist near me\"", text: $viewModel.searchText)
                    .focused($focusedField, equals: .search)
                    .onSubmit { runSearch() }
                if viewModel.isParsingQuery {
                    ProgressView()
                } else {
                    Button {
                        runSearch()
                    } label: {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .font(.title2)
                    }
                    .disabled(viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .padding()
        .cardBackground()
        .padding(.horizontal)
        .padding(.vertical)
    }

    private func runSearch() {
        focusedField = nil
        Task { await viewModel.searchFromText() }
    }
}

private struct DoctorCard: View {
    let doctor: Doctor
    let resolvedImage: UIImage?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if doctor.photoURL != nil {
                Group {
                    if let resolvedImage {
                        Image(uiImage: resolvedImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ZStack {
                            Color(.tertiarySystemFill)
                            Image(systemName: "building.2.fill")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(height: 100)
                .clipped()
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(doctor.name)
                    .font(.headline)

                Text(doctor.specialty)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                if let rating = doctor.rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                        Text(String(format: "%.1f", rating))
                            .font(.subheadline.weight(.medium))
                        if let count = doctor.userRatingCount {
                            Text("(\(count))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if !doctor.address.isEmpty {
                    Label(doctor.address, systemImage: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                actionRow
            }
            .padding(12)
        }
        .cardBackground()
        .padding(.horizontal)
        .padding(.vertical, 6)
    }

    private var actionRow: some View {
        HStack {
            if !doctor.phone.isEmpty {
                Button {
                    call(doctor.phone)
                } label: {
                    Label("Call", systemImage: "phone.fill")
                }
            }
            if let websiteURL = doctor.websiteURL {
                Button {
                    UIApplication.shared.open(websiteURL)
                } label: {
                    Label("Website", systemImage: "safari.fill")
                }
            }
        }
        .buttonStyle(.bordered)
        .font(.caption)
        .padding(.top, 6)
    }

    private func call(_ phone: String) {
        guard let url = URL(string: "tel://\(phone.filter { $0.isNumber || $0 == "+" })") else { return }
        UIApplication.shared.open(url)
    }
}
