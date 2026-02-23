import SwiftUI

struct MilestonesView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAdd = false
    @State private var editingMilestone: PetMilestone? = nil

    private var petID: UUID? { appState.activePetID }
    private var sorted: [PetMilestone] {
        (appState.milestones[petID ?? UUID()] ?? []).sorted { $0.date > $1.date }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Milestones", systemImage: "star.fill")
                    .font(.title3.bold())
                    .foregroundColor(.yellow)
                Spacer()
                Button(action: { showingAdd = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.yellow)
                }
            }

            if sorted.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Text("🐾").font(.largeTitle)
                        Text("Log your pet's first milestone!")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                }.padding(.vertical, 12)
            } else {
                ForEach(Array(sorted.enumerated()), id: \.element.id) { idx, milestone in
                    HStack(alignment: .top, spacing: 12) {
                        // Timeline spine
                        VStack(spacing: 0) {
                            ZStack {
                                Circle()
                                    .fill(Color.yellow.opacity(0.2))
                                    .frame(width: 38, height: 38)
                                Text(milestone.emoji).font(.title3)
                            }
                            if idx < sorted.count - 1 {
                                Rectangle()
                                    .fill(Color.yellow.opacity(0.3))
                                    .frame(width: 2)
                                    .frame(maxHeight: .infinity)
                                    .padding(.vertical, 2)
                            }
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(milestone.title).font(.headline)
                            Text(milestone.date, style: .date)
                                .font(.caption).foregroundColor(.secondary)
                            if !milestone.notes.isEmpty {
                                Text(milestone.notes)
                                    .font(.caption2).foregroundColor(.secondary)
                                    .lineLimit(2)
                            }
                        }
                        .padding(.vertical, 6)

                        Spacer()

                        Menu {
                            Button("Edit") { editingMilestone = milestone }
                            Button("Delete", role: .destructive) { delete(milestone) }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.bottom, 4)
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            MilestoneEditorSheet(milestone: nil, petID: appState.activePetID ?? UUID(), onSave: save)
        }
        .sheet(item: $editingMilestone) { m in
            MilestoneEditorSheet(milestone: m, petID: m.petID, onSave: save)
        }
    }

    private func save(_ m: PetMilestone) {
        guard let id = petID else { return }
        var list = appState.milestones[id] ?? []
        list.removeAll { $0.id == m.id }
        list.append(m)
        appState.milestones[id] = list
        appState.saveToDisk()
    }

    private func delete(_ m: PetMilestone) {
        guard let id = petID else { return }
        appState.milestones[id]?.removeAll { $0.id == m.id }
        appState.saveToDisk()
    }
}

// MARK: - Editor

struct MilestoneEditorSheet: View {
    @Environment(\.dismiss) var dismiss
    let milestone: PetMilestone?
    let petID: UUID
    let onSave: (PetMilestone) -> Void

    @State private var title: String
    @State private var emoji: String
    @State private var date: Date
    @State private var notes: String

    init(milestone: PetMilestone?, petID: UUID, onSave: @escaping (PetMilestone) -> Void) {
        self.milestone = milestone; self.petID = petID; self.onSave = onSave
        _title = State(initialValue: milestone?.title ?? "")
        _emoji = State(initialValue: milestone?.emoji ?? "🐾")
        _date  = State(initialValue: milestone?.date  ?? Date())
        _notes = State(initialValue: milestone?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Milestone") {
                    TextField("Title (e.g. First Walk 🐾)", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                Section("Emoji Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 10), spacing: 10) {
                        ForEach(PetMilestone.emojiOptions, id: \.self) { e in
                            Text(e).font(.title2)
                                .padding(4)
                                .background(emoji == e ? Color.yellow.opacity(0.3) : Color.clear)
                                .cornerRadius(8)
                                .onTapGesture { emoji = e }
                        }
                    }
                }
                Section("Notes") {
                    TextField("Notes (optional)", text: $notes, axis: .vertical).lineLimit(2...4)
                }
            }
            .navigationTitle(milestone == nil ? "New Milestone" : "Edit Milestone")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var m = PetMilestone(petID: petID, title: title, emoji: emoji, date: date, notes: notes)
                        if let existing = milestone { m.id = existing.id }
                        onSave(m); dismiss()
                    }.disabled(title.isEmpty).bold()
                }
            }
        }
    }
}
