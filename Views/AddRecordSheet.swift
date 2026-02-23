import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct AddRecordSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    
    @State private var title = ""
    @State private var date = Date()
    @State private var type: RecordType = .checkup
    @State private var notes = ""
    @State private var isEmergency = false
    
    // Attachments
    @State private var attachedDocumentNames: [String] = []
    @State private var showingFileImporter = false
    @State private var showingPhotoPicker = false
    @State private var selectedPhotoItems: [PhotosPickerItem] = []
    
    @State private var isProcessing = false
    @State private var processingMessage = ""
    @State private var importError: String? = nil
    
    // Allowed file types: PDF, images, Word, Excel, text, RTF, HEIC, video, ZIP
    private let allowedTypes: [UTType] = [
        .pdf,
        .image,
        .jpeg,
        .png,
        .heic,
        .tiff,
        .plainText,
        .rtf,
        .spreadsheet,
        .presentation,
        UTType("com.microsoft.word.doc") ?? .data,
        UTType("org.openxmlformats.wordprocessingml.document") ?? .data,
        UTType("com.microsoft.excel.xls") ?? .data,
        UTType("org.openxmlformats.spreadsheetml.sheet") ?? .data,
        .zip,
        .data
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Record Title", text: $title)
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    
                    Picker("Type", selection: $type) {
                        ForEach(RecordType.allCases, id: \.self) { t in
                            Text(t.display).tag(t)
                        }
                    }
                    
                    Toggle("Mark as Emergency", isOn: $isEmergency)
                        .tint(Theme.alert)
                }
                
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
                
                Section {
                    // Attached files list
                    ForEach(attachedDocumentNames, id: \.self) { name in
                        HStack(spacing: 10) {
                            Image(systemName: fileIcon(for: name))
                                .foregroundColor(fileColor(for: name))
                                .frame(width: 24)
                            Text(name.components(separatedBy: "_").dropFirst().joined(separator: "_").isEmpty
                                 ? name
                                 : name.split(separator: "_", maxSplits: 1).dropFirst().joined(separator: "_"))
                                .font(.callout)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.caption)
                        }
                    }
                    .onDelete { indexSet in
                        attachedDocumentNames.remove(atOffsets: indexSet)
                    }
                    
                    if isProcessing {
                        HStack(spacing: 10) {
                            ProgressView()
                                .scaleEffect(0.85)
                            Text(processingMessage.isEmpty ? "Processing files…" : processingMessage)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if let err = importError {
                        Text("⚠️ \(err)")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    // Add File button — opens document picker
                    Button(action: { showingFileImporter = true }) {
                        Label("Add File (PDF, Word, Excel…)", systemImage: "doc.badge.plus")
                            .foregroundColor(Theme.primary)
                    }
                    
                    // Add Photo button
                    PhotosPicker(selection: $selectedPhotoItems,
                                 maxSelectionCount: 10,
                                 matching: .any(of: [.images, .videos]),
                                 photoLibrary: .shared()) {
                        Label("Add Photo / Video", systemImage: "photo.badge.plus")
                            .foregroundColor(Theme.primary)
                    }
                    .onChange(of: selectedPhotoItems) { _, items in
                        Task { await processPhotos(items) }
                    }

                    
                } header: {
                    Text("Attachments (\(attachedDocumentNames.count))")
                } footer: {
                    Text("Supported: PDF, Word, Excel, images, videos, text & more. Swipe left to remove.")
                        .font(.caption2)
                }
            }
            .navigationTitle("New Record")
            .navigationBarTitleDisplayMode(.inline)
            // Document / file picker
            .fileImporter(
                isPresented: $showingFileImporter,
                allowedContentTypes: allowedTypes,
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    Task { await processFiles(urls) }
                case .failure(let error):
                    importError = "Import failed: \(error.localizedDescription)"
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveRecord()
                    }
                    .disabled(title.isEmpty || isProcessing)
                    .bold()
                }
            }
        }
    }
    
    // MARK: - File Processing
    
    private func processFiles(_ urls: [URL]) async {
        await MainActor.run {
            isProcessing = true
            importError = nil
        }
        
        var errors: [String] = []
        for url in urls {
            // Must start security-scoped access for files outside sandbox
            let accessing = url.startAccessingSecurityScopedResource()
            defer { if accessing { url.stopAccessingSecurityScopedResource() } }
            
            let originalName = url.lastPathComponent
            let prefix = String(UUID().uuidString.prefix(4))
            let safeName = "\(prefix)_\(originalName)"
            
            await MainActor.run { processingMessage = "Saving \(originalName)…" }
            
            if let saved = try? DataManager.shared.saveDocument(from: url, withName: safeName) {
                await MainActor.run { attachedDocumentNames.append(saved) }
            } else {
                errors.append(originalName)
            }
        }
        
        await MainActor.run {
            isProcessing = false
            processingMessage = ""
            if !errors.isEmpty {
                importError = "Failed to import: \(errors.joined(separator: ", "))"
            }
        }
    }
    
    private func processPhotos(_ items: [PhotosPickerItem]) async {
        guard !items.isEmpty else { return }
        await MainActor.run {
            isProcessing = true
            processingMessage = "Saving photos…"
            importError = nil
        }
        
        for item in items {
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    let filename = "img_\(UUID().uuidString.prefix(8)).jpg"
                    if let saved = try? DataManager.shared.saveImageDocument(data, withName: filename) {
                        await MainActor.run { attachedDocumentNames.append(saved) }
                    }
                }
            } catch {
                await MainActor.run { importError = "Photo import error: \(error.localizedDescription)" }
            }
        }
        
        await MainActor.run {
            isProcessing = false
            processingMessage = ""
            selectedPhotoItems = []
        }
    }
    
    private func saveRecord() {
        guard let petID = appState.activePetID else { dismiss(); return }
        let record = MedicalRecord(
            petID: petID,
            title: title,
            date: date,
            type: type,
            notes: notes,
            isEmergency: isEmergency,
            attachedDocumentNames: attachedDocumentNames
        )
        var updated = appState.medicalRecords
        updated[petID, default: []].append(record)
        appState.medicalRecords = updated
        appState.saveToDisk()
        dismiss()
    }
    
    // MARK: - File Icon Helpers
    
    private func fileIcon(for name: String) -> String {
        let ext = (name as NSString).pathExtension.lowercased()
        switch ext {
        case "pdf": return "doc.richtext.fill"
        case "jpg", "jpeg", "png", "heic", "tiff", "gif", "webp": return "photo.fill"
        case "mp4", "mov", "m4v", "avi": return "video.fill"
        case "doc", "docx": return "doc.text.fill"
        case "xls", "xlsx": return "tablecells.fill"
        case "ppt", "pptx": return "rectangle.stack.fill"
        case "txt", "rtf", "md": return "text.alignleft"
        case "zip", "rar": return "archivebox.fill"
        default: return "doc.fill"
        }
    }
    
    private func fileColor(for name: String) -> Color {
        let ext = (name as NSString).pathExtension.lowercased()
        switch ext {
        case "pdf": return .red
        case "jpg", "jpeg", "png", "heic", "tiff", "gif": return .blue
        case "mp4", "mov", "m4v": return .purple
        case "doc", "docx": return Color(hex: "#2B579A")
        case "xls", "xlsx": return Color(hex: "#217346")
        case "ppt", "pptx": return Color(hex: "#D04423")
        case "txt", "rtf", "md": return .secondary
        case "zip", "rar": return .orange
        default: return Theme.primary
        }
    }
}

