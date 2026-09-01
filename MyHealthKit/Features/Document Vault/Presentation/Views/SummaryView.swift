import SwiftUI

struct SummaryView: View {
    let document: VaultDocument
    @State private var viewModel: SummaryViewModel
    @Environment(\.dismiss) private var dismiss

    init(document: VaultDocument, viewModel: SummaryViewModel) {
        self.document = document
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    switch viewModel.state {
                    case .idle:
                        EmptyView()

                    case .extracting:
                        statusView(message: "Reading document…")

                    case .summarizing:
                        statusView(message: "Summarizing…")

                    case .result(let summary):
                        Text(summary)
                            .font(.body)
                            .textSelection(.enabled)

                        disclaimer

                    case .failed(let message):
                        Text(message)
                            .foregroundStyle(.red)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .task {
                await viewModel.summarize(fileURL: document.fileURL, kind: document.kind)
            }
        }
    }

    private func statusView(message: String) -> some View {
        HStack {
            ProgressView()
            Text(message)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private var disclaimer: some View {
        Text("This summary is AI-generated and may contain mistakes. For medical documents, always discuss results with a doctor.")
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.top, 8)
    }
}
