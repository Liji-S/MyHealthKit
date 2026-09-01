import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct DocumentVaultView: View {
    @State private var viewModel: DocumentVaultViewModel
    let makeSummaryViewModel: () -> SummaryViewModel
    @State private var isImporterPresented = false
    @State private var isPhotoPickerPresented = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    init(viewModel: DocumentVaultViewModel, makeSummaryViewModel: @escaping () -> SummaryViewModel) {
        _viewModel = State(initialValue: viewModel)
        self.makeSummaryViewModel = makeSummaryViewModel
    }

    var body: some View {
        List {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage).foregroundStyle(.red)
            }

            if viewModel.documents.isEmpty {
                ContentUnavailableView(
                    "No Documents Yet",
                    systemImage: "folder",
                    description: Text("Import a PDF or photo to keep your insurance and medical documents in one place.")
                )
            } else {
                ForEach(viewModel.documents) { document in
                    NavigationLink {
                        DocumentDetailView(
                            document: document,
                            makeSummaryViewModel: makeSummaryViewModel
                        )
                    } label: {
                        HStack {
                            Image(systemName: document.kind == .pdf ? "doc.fill" : "photo.fill")
                                .foregroundStyle(.secondary)
                            VStack(alignment: .leading) {
                                Text(document.fileName).font(.headline)
                                Text(document.addedAt, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .onDelete { offsets in
                    for index in offsets {
                        viewModel.delete(viewModel.documents[index])
                    }
                }
            }
        }
        .navigationTitle("Documents")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        isImporterPresented = true
                    } label: {
                        Label("Import PDF", systemImage: "doc.badge.plus")
                    }
                    Button {
                        isPhotoPickerPresented = true
                    } label: {
                        Label("Import Photo", systemImage: "photo.badge.plus")
                    }
                } label: {
                    Label("Import", systemImage: "plus")
                }
            }
        }
        .fileImporter(
            isPresented: $isImporterPresented,
            allowedContentTypes: [.pdf]
        ) { result in
            if case .success(let url) = result {
                viewModel.importDocument(from: url)
            }
        }
        .photosPicker(isPresented: $isPhotoPickerPresented, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    let name = "Photo \(Date().formatted(date: .abbreviated, time: .shortened))"
                    viewModel.importImage(data: data, fileName: name, fileExtension: "jpg")
                }
                selectedPhotoItem = nil
            }
        }
        .onAppear {
            viewModel.loadDocuments()
        }
    }
}

private struct DocumentDetailView: View {
    let document: VaultDocument
    let makeSummaryViewModel: () -> SummaryViewModel
    @State private var isSummarySheetPresented = false

    var body: some View {
        Group {
            switch document.kind {
            case .pdf:
                PDFKitView(url: document.fileURL)
            case .image:
                ImageDocumentView(fileURL: document.fileURL)
            }
        }
        .navigationTitle(document.fileName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isSummarySheetPresented = true
                } label: {
                    Label("Summarize", systemImage: "sparkles")
                }
            }
        }
        .sheet(isPresented: $isSummarySheetPresented) {
            SummaryView(document: document, viewModel: makeSummaryViewModel())
        }
    }
}

private struct ImageDocumentView: View {
    let fileURL: URL

    @State private var currentZoom: CGFloat = 1
    @State private var totalZoom: CGFloat = 1

    var body: some View {
        if let uiImage = UIImage(contentsOfFile: fileURL.path) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .scaleEffect(currentZoom * totalZoom)
                .gesture(
                    MagnifyGesture()
                        .onChanged { value in
                            currentZoom = value.magnification
                        }
                        .onEnded { value in
                            totalZoom *= currentZoom
                            currentZoom = 1
                            totalZoom = max(1, min(totalZoom, 5))
                        }
                )
                .onTapGesture(count: 2) {
                    withAnimation {
                        totalZoom = 1
                        currentZoom = 1
                    }
                }
        } else {
            ContentUnavailableView("Couldn't Load Photo", systemImage: "photo")
        }
    }
}
