import SwiftUI

struct AddMedicationView: View {
    let existingMedication: Medication?
    let onSave: (String, String, Int, Int, Int) async -> Bool

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var dosage: String
    @State private var currentSupply: Int
    @State private var dailyDoseCount: Int
    @State private var refillThreshold: Int
    @FocusState private var focusedField: Field?

    private enum Field {
        case name, dosage
    }

    @State private var isDuplicateAlertPresented = false

    init(existingMedication: Medication? = nil, onSave: @escaping (String, String, Int, Int, Int) async -> Bool) {
        self.existingMedication = existingMedication
        self.onSave = onSave
        _name = State(initialValue: existingMedication?.name ?? "")
        _dosage = State(initialValue: existingMedication?.dosage ?? "")
        _currentSupply = State(initialValue: existingMedication?.remainingSupply() ?? 30)
        _dailyDoseCount = State(initialValue: existingMedication?.dailyDoseCount ?? 1)
        _refillThreshold = State(initialValue: existingMedication?.refillThreshold ?? 5)
    }

    private var isEditing: Bool { existingMedication != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Medication") {
                    TextField("Name", text: $name)
                        .focused($focusedField, equals: .name)
                    TextField("Dosage (e.g. 500mg)", text: $dosage)
                        .focused($focusedField, equals: .dosage)
                }

                Section("Supply") {
                    Stepper("Tablets remaining today: \(currentSupply)", value: $currentSupply, in: 0...500)
                    Stepper("Taken per day: \(dailyDoseCount)", value: $dailyDoseCount, in: 0...10)
                    Stepper("Remind me to refill at: \(refillThreshold)", value: $refillThreshold, in: 0...100)
                }

                Section {
                    Text("Supply counts down automatically by \(dailyDoseCount) each day, starting tomorrow. You'll get a refill reminder once it reaches \(refillThreshold).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle(isEditing ? "Edit Medication" : "Add Medication")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            let saved = await onSave(name, dosage, currentSupply, dailyDoseCount, refillThreshold)
                            if saved {
                                dismiss()
                            } else {
                                isDuplicateAlertPresented = true
                            }
                        }
                    }
                    .disabled(name.isEmpty)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") { focusedField = nil }
                }
            }
            .alert("Already Added", isPresented: $isDuplicateAlertPresented) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("\(name) is already in your medication list.")
            }
        }
    }
}
