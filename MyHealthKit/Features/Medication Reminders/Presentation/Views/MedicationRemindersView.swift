import SwiftUI

struct MedicationRemindersView: View {
    @State private var viewModel: MedicationRemindersViewModel
    @State private var isAddSheetPresented = false
    @State private var medicationBeingEdited: Medication?

    init(viewModel: MedicationRemindersViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        List {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundStyle(.red)
            }

            if viewModel.medications.isEmpty {
                ContentUnavailableView(
                    "No Medications Yet",
                    systemImage: "pills",
                    description: Text("Add a medication to track your supply and get refill reminders.")
                )
            } else {
                ForEach(viewModel.medications) { medication in
                    MedicationRow(medication: medication)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            medicationBeingEdited = medication
                        }
                }
                .onDelete { offsets in
                    Task {
                        for index in offsets {
                            await viewModel.delete(viewModel.medications[index])
                        }
                    }
                }
            }
        }
        .navigationTitle("Medications")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isAddSheetPresented = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isAddSheetPresented) {
            AddMedicationView { name, dosage, currentSupply, dailyDoseCount, refillThreshold in
                await viewModel.addMedication(
                    name: name,
                    dosage: dosage,
                    currentSupply: currentSupply,
                    dailyDoseCount: dailyDoseCount,
                    refillThreshold: refillThreshold
                )
            }
        }
        .sheet(item: $medicationBeingEdited) { medication in
            AddMedicationView(existingMedication: medication) { name, dosage, currentSupply, dailyDoseCount, refillThreshold in
                await viewModel.updateMedication(
                    medication,
                    name: name,
                    dosage: dosage,
                    currentSupply: currentSupply,
                    dailyDoseCount: dailyDoseCount,
                    refillThreshold: refillThreshold
                )
            }
        }
        .onAppear {
            viewModel.loadMedications()
        }
    }
}

private struct MedicationRow: View {
    let medication: Medication

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(medication.name).font(.headline)
                if medication.isLowOnSupply() {
                    Label("Low", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption2.bold())
                        .foregroundStyle(.orange)
                }
            }
            Text(medication.dosage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("\(medication.remainingSupply()) remaining")
                .font(.caption)
                .foregroundStyle(medication.isLowOnSupply() ? .orange : .secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 4)
    }
}
