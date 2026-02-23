import SwiftUI

struct MedicationsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAdd = false
    @State private var editingMed: Medication? = nil
    @State private var showingActive = true

    private var petID: UUID? { appState.activePetID }
    private var all: [Medication] { appState.medications[petID ?? UUID()] ?? [] }
    private var active: [Medication] { all.filter(\.isActive).sorted { $0.startDate < $1.startDate } }
    private var past: [Medication]   { all.filter { !$0.isActive }.sorted { ($0.endDate ?? Date()) > ($1.endDate ?? Date()) } }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Medications", systemImage: "pills.fill")
                    .font(.title3.bold())
                Spacer()
                Button(action: { showingAdd = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.purple)
                }
            }

            if !all.isEmpty {
                Picker("", selection: $showingActive) {
                    Text("Active (\(active.count))").tag(true)
                    Text("Past (\(past.count))").tag(false)
                }.pickerStyle(.segmented)
            }

            let displayed = showingActive ? active : past
            if displayed.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "pills.circle")
                            .font(.largeTitle).foregroundColor(.secondary)
                        Text(showingActive ? "No active medications" : "No past medications")
                            .font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                }.padding(.vertical, 12)
            } else {
                ForEach(displayed) { med in
                    MedicationRow(med: med,
                        onEdit: { editingMed = med },
                        onDelete: { delete(med) })
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            MedicationEditorSheet(med: nil, petID: appState.activePetID ?? UUID(), onSave: save)
        }
        .sheet(item: $editingMed) { med in
            MedicationEditorSheet(med: med, petID: med.petID, onSave: save)
        }
    }

    private func save(_ med: Medication) {
        guard let id = petID else { return }
        var list = appState.medications[id] ?? []
        if let old = list.first(where: { $0.id == med.id }) {
            NotificationManager.shared.cancelNotifications(ids: old.notificationIDs)
            list.removeAll { $0.id == med.id }
        }
        var updated = med
        updated.notificationIDs = NotificationManager.shared.scheduleMedication(med)
        list.append(updated)
        appState.medications[id] = list
        appState.saveToDisk()
    }

    private func delete(_ med: Medication) {
        guard let id = petID else { return }
        NotificationManager.shared.cancelNotifications(ids: med.notificationIDs)
        appState.medications[id]?.removeAll { $0.id == med.id }
        appState.saveToDisk()
    }
}

// MARK: - Row

private struct MedicationRow: View {
    let med: Medication
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: med.color).opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: "pills.fill")
                    .foregroundColor(Color(hex: med.color))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(med.name).font(.headline)
                Text(med.dosageDisplay).font(.caption).foregroundColor(.secondary)
                HStack(spacing: 4) {
                    Image(systemName: med.frequency.icon).font(.caption2)
                    Text(med.frequency.display).font(.caption2)
                }.foregroundColor(Color(hex: med.color))
            }
            Spacer()
            if !med.isActive {
                Text("Ended").font(.caption).foregroundColor(.secondary)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Color.secondary.opacity(0.1)).cornerRadius(8)
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: onDelete) { Label("Delete", systemImage: "trash") }
            Button(action: onEdit) { Label("Edit", systemImage: "pencil") }.tint(.orange)
        }
    }
}

// MARK: - Editor

struct MedicationEditorSheet: View {
    @Environment(\.dismiss) var dismiss
    let med: Medication?
    let petID: UUID
    let onSave: (Medication) -> Void

    @State private var name: String
    @State private var dosage: String
    @State private var unit: MedUnit
    @State private var frequency: MedFrequency
    @State private var startDate: Date
    @State private var hasEndDate: Bool
    @State private var endDate: Date
    @State private var notes: String
    @State private var color: String

    init(med: Medication?, petID: UUID, onSave: @escaping (Medication) -> Void) {
        self.med = med; self.petID = petID; self.onSave = onSave
        _name      = State(initialValue: med?.name      ?? "")
        _dosage    = State(initialValue: med?.dosage    ?? "1")
        _unit      = State(initialValue: med?.unit      ?? .tablet)
        _frequency = State(initialValue: med?.frequency ?? .daily)
        _startDate = State(initialValue: med?.startDate ?? Date())
        _hasEndDate = State(initialValue: med?.endDate != nil)
        _endDate   = State(initialValue: med?.endDate ?? Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date())
        _notes     = State(initialValue: med?.notes     ?? "")
        _color     = State(initialValue: med?.color     ?? "#5B5EA6")
    }

    let colorOptions = ["#5B5EA6","#CC0000","#009966","#FF8800","#0066CC","#CC6600"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Medication Details") {
                    TextField("Name (e.g. Bravecto)", text: $name)
                    HStack {
                        TextField("Dosage", text: $dosage).keyboardType(.decimalPad)
                        Picker("Unit", selection: $unit) {
                            ForEach(MedUnit.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                        }.pickerStyle(.menu)
                    }
                    Picker("Frequency", selection: $frequency) {
                        ForEach(MedFrequency.allCases, id: \.self) { Text($0.display).tag($0) }
                    }
                }
                Section("Schedule") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    Toggle("Has End Date", isOn: $hasEndDate)
                    if hasEndDate {
                        DatePicker("End Date", selection: $endDate, in: startDate..., displayedComponents: .date)
                    }
                }
                Section("Colour") {
                    HStack(spacing: 12) {
                        ForEach(colorOptions, id: \.self) { c in
                            Circle().fill(Color(hex: c)).frame(width: 28, height: 28)
                                .overlay(Circle().stroke(Color.white, lineWidth: color == c ? 3 : 0))
                                .shadow(radius: color == c ? 4 : 0)
                                .onTapGesture { color = c }
                        }
                    }
                }
                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical).lineLimit(2...4)
                }
            }
            .navigationTitle(med == nil ? "New Medication" : "Edit Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var m = Medication(petID: petID, name: name, dosage: dosage, unit: unit,
                                           frequency: frequency, startDate: startDate,
                                           endDate: hasEndDate ? endDate : nil, notes: notes, color: color)
                        if let existing = med { m.id = existing.id }
                        onSave(m); dismiss()
                    }.disabled(name.isEmpty).bold()
                }
            }
        }
    }
}
