import SwiftUI

struct AppointmentsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAdd = false
    @State private var editingAppt: VetAppointment? = nil

    private var petID: UUID? { appState.activePetID }
    private var upcoming: [VetAppointment] {
        (appState.appointments[petID ?? UUID()] ?? [])
            .filter { $0.isUpcoming }
            .sorted { $0.date < $1.date }
    }
    private var past: [VetAppointment] {
        (appState.appointments[petID ?? UUID()] ?? [])
            .filter { $0.isPast }
            .sorted { $0.date > $1.date }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Vet Appointments", systemImage: "stethoscope")
                    .font(.title3.bold())
                Spacer()
                Button(action: { showingAdd = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(Theme.primary)
                }
            }

            if upcoming.isEmpty && past.isEmpty {
                emptyState
            } else {
                if !upcoming.isEmpty {
                    Text("Upcoming").font(.caption.bold()).foregroundColor(.secondary)
                    ForEach(upcoming) { appt in
                        AppointmentRow(appt: appt,
                            onEdit: { editingAppt = appt },
                            onDelete: { delete(appt) })
                    }
                }
                if !past.isEmpty {
                    Text("Past").font(.caption.bold()).foregroundColor(.secondary).padding(.top, 4)
                    ForEach(past.prefix(3)) { appt in
                        AppointmentRow(appt: appt,
                            onEdit: { editingAppt = appt },
                            onDelete: { delete(appt) })
                    }
                }
            }
        }
        .sheet(isPresented: $showingAdd) {
            AppointmentEditorSheet(appt: nil, onSave: save)
        }
        .sheet(item: $editingAppt) { appt in
            AppointmentEditorSheet(appt: appt, onSave: save)
        }
    }

    private var emptyState: some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                Image(systemName: "calendar.badge.plus")
                    .font(.largeTitle).foregroundColor(.secondary)
                Text("No appointments yet").font(.caption).foregroundColor(.secondary)
            }
            Spacer()
        }.padding(.vertical, 12)
    }

    private func save(_ appt: VetAppointment) {
        guard let id = petID else { return }
        var list = appState.appointments[id] ?? []
        // Cancel old notifications if editing
        if let old = list.first(where: { $0.id == appt.id }) {
            NotificationManager.shared.cancelNotifications(ids: old.notificationIDs)
            list.removeAll { $0.id == appt.id }
        }
        var updated = appt
        updated.notificationIDs = NotificationManager.shared.scheduleAppointment(appt)
        list.append(updated)
        appState.appointments[id] = list
        appState.saveToDisk()
    }

    private func delete(_ appt: VetAppointment) {
        guard let id = petID else { return }
        NotificationManager.shared.cancelNotifications(ids: appt.notificationIDs)
        appState.appointments[id]?.removeAll { $0.id == appt.id }
        appState.saveToDisk()
    }
}

// MARK: - Row

private struct AppointmentRow: View {
    let appt: VetAppointment
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(spacing: 2) {
                Text(appt.date, format: .dateTime.day())
                    .font(.title3.bold())
                    .foregroundColor(Color(hex: appt.countdownColor))
                Text(appt.date, format: .dateTime.month(.abbreviated))
                    .font(.caption2.bold())
                    .foregroundColor(.secondary)
            }
            .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(appt.title).font(.headline)
                Text(appt.vetName).font(.caption).foregroundColor(.secondary)
                if !appt.location.isEmpty {
                    Label(appt.location, systemImage: "mappin.circle")
                        .font(.caption2).foregroundColor(.secondary)
                }
            }
            Spacer()
            Text(appt.countdownText)
                .font(.caption.bold())
                .foregroundColor(Color(hex: appt.countdownColor))
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Color(hex: appt.countdownColor).opacity(0.12))
                .cornerRadius(8)
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

// MARK: - Editor Sheet

struct AppointmentEditorSheet: View {
    @Environment(\.dismiss) var dismiss
    let appt: VetAppointment?
    let onSave: (VetAppointment) -> Void

    @State private var title: String
    @State private var vetName: String
    @State private var date: Date
    @State private var location: String
    @State private var notes: String

    init(appt: VetAppointment?, onSave: @escaping (VetAppointment) -> Void) {
        self.appt = appt
        self.onSave = onSave
        let defaultDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        _title    = State(initialValue: appt?.title    ?? "")
        _vetName  = State(initialValue: appt?.vetName  ?? "")
        _date     = State(initialValue: appt?.date     ?? defaultDate)
        _location = State(initialValue: appt?.location ?? "")
        _notes    = State(initialValue: appt?.notes    ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Appointment Details") {
                    TextField("Title (e.g. Annual Checkup)", text: $title)
                    TextField("Vet / Clinic Name", text: $vetName)
                    DatePicker("Date & Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    TextField("Location (optional)", text: $location)
                }
                Section("Notes") {
                    TextField("Notes", text: $notes, axis: .vertical).lineLimit(3...6)
                }
            }
            .navigationTitle(appt == nil ? "New Appointment" : "Edit Appointment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var a = VetAppointment(petID: appt?.petID ?? UUID(),
                                               title: title, vetName: vetName,
                                               date: date, location: location, notes: notes)
                        if let existing = appt { a.id = existing.id; a.petID = existing.petID }
                        onSave(a); dismiss()
                    }.disabled(title.isEmpty || vetName.isEmpty).bold()
                }
            }
        }
    }
}
