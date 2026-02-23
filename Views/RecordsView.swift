import SwiftUI
import QuickLook

struct RecordsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAddRecord = false
    @State private var showingAddContact = false
    @State private var editingContact: EmergencyContact? = nil
    @State private var previewURL: URL?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Emergency Contacts Card
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Label("Emergency Contacts", systemImage: "phone.circle.fill")
                                .font(.headline)
                                .foregroundColor(Theme.alert)
                            Spacer()
                            Button(action: { showingAddContact = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(Theme.alert)
                            }
                        }
                        
                        Divider()
                        
                        ForEach(appState.emergencyContacts) { contact in
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color(hex: contact.roleColor).opacity(0.15))
                                        .frame(width: 38, height: 38)
                                    Image(systemName: contact.roleIcon)
                                        .foregroundColor(Color(hex: contact.roleColor))
                                        .font(.subheadline)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    HStack(spacing: 6) {
                                        Text(contact.name)
                                            .font(.subheadline.bold())
                                            .lineLimit(1)
                                        if contact.isPrimary {
                                            Text("PRIMARY")
                                                .font(.caption2.bold())
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(LinearGradient(colors: [Color.red, Color.orange], startPoint: .topLeading, endPoint: .bottomTrailing))
                                                .clipShape(Capsule())
                                                .shadow(color: Color.red.opacity(0.3), radius: 3, x: 0, y: 1)
                                        }
                                    }
                                    Text(contact.role)
                                        .font(.caption.weight(.medium))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // Call button
                                if !contact.phone.isEmpty {
                                    Button(action: {
                                        if let url = URL(string: "tel://\(contact.phone.filter { $0.isNumber || $0 == "+" })") {
                                            UIApplication.shared.open(url)
                                        }
                                    }) {
                                        Image(systemName: "phone.fill")
                                            .foregroundColor(.white)
                                            .padding(10)
                                            .background(LinearGradient(colors: [Color.green, Color(hex: "#10B981")], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            .clipShape(Circle())
                                            .shadow(color: Color.green.opacity(0.4), radius: 4, x: 0, y: 2)
                                    }
                                }
                                
                                // Edit button
                                Button(action: { editingContact = contact }) {
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            if contact.id != appState.emergencyContacts.last?.id {
                                Divider()
                            }
                        }
                        
                        
                        if appState.emergencyContacts.isEmpty {
                            Text("No contacts added yet. Tap + to add your vet.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(20)
                    .background(
                        ZStack {
                            Theme.cardBackground
                            LinearGradient(colors: [Theme.alert.opacity(0.05), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.primary.opacity(0.03), lineWidth: 1))
                    .padding(.horizontal)

                    // Vet Appointments
                    AppointmentsView()
                        .padding()
                        .background(Theme.cardBackground)
                        .cornerRadius(16)
                        .padding(.horizontal)

                    // Medications
                    MedicationsView()
                        .padding()
                        .background(Theme.cardBackground)
                        .cornerRadius(16)
                        .padding(.horizontal)

                    // Milestones
                    MilestonesView()
                        .padding()
                        .background(Theme.cardBackground)
                        .cornerRadius(16)
                        .padding(.horizontal)
                    
                    // Medical Records List

                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Medical Records")
                                .font(.title3.bold())
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        if let petID = appState.activePetID, let records = appState.medicalRecords[petID], !records.isEmpty {
                            ForEach(records.sorted(by: { $0.date > $1.date })) { record in
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(record.isEmergency ? Theme.alert.opacity(0.15) : Theme.primary.opacity(0.1))
                                                .frame(width: 50, height: 50)
                                            Image(systemName: record.type.icon)
                                                .foregroundColor(record.isEmergency ? Theme.alert : Theme.primary)
                                                .font(.title3.weight(.semibold))
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(record.title)
                                                .font(.headline)
                                            Text(record.date, style: .date)
                                                .font(.caption.weight(.medium))
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        if record.isEmergency {
                                            Image(systemName: "exclamationmark.triangle.fill")
                                                .foregroundColor(Theme.alert)
                                                .shadow(color: Theme.alert.opacity(0.4), radius: 4, x: 0, y: 2)
                                        }
                                    }
                                    
                                    if !record.notes.isEmpty {
                                        Text(record.notes)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .lineLimit(3)
                                            .padding(.top, 4)
                                    }
                                    
                                    if !record.attachedDocumentNames.isEmpty {
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            HStack(spacing: 8) {
                                                ForEach(record.attachedDocumentNames, id: \.self) { filename in
                                                    Button(action: {
                                                        previewURL = DataManager.shared.documentURL(for: filename)
                                                    }) {
                                                        HStack(spacing: 6) {
                                                            Image(systemName: "doc.fill")
                                                            Text(filename)
                                                                .lineLimit(1)
                                                                .truncationMode(.middle)
                                                                .frame(maxWidth: 120)
                                                        }
                                                        .font(.caption.bold())
                                                        .padding(.horizontal, 10)
                                                        .padding(.vertical, 6)
                                                        .background(Theme.primary.opacity(0.1))
                                                        .foregroundColor(Theme.primary)
                                                        .cornerRadius(8)
                                                    }
                                                }
                                            }
                                        }
                                        .padding(.top, 4)
                                    }
                                }
                                .padding(20)
                                .background(Theme.cardBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
                                .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.primary.opacity(0.03), lineWidth: 1))
                                .padding(.horizontal)
                            }
                        } else {
                            VStack(spacing: 16) {
                                Image(systemName: "folder.badge.questionmark")
                                    .font(.largeTitle)
                                    .foregroundColor(.secondary)
                                Text("No Medical Records Yet")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 40)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Records")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddRecord = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddRecord) {
                AddRecordSheet()
            }
            .sheet(isPresented: $showingAddContact) {
                ContactEditorSheet(contact: nil) { newContact in
                    appState.emergencyContacts.append(newContact)
                    appState.saveToDisk()
                }
            }
            .sheet(item: $editingContact) { contact in
                ContactEditorSheet(contact: contact) { updated in
                    if let idx = appState.emergencyContacts.firstIndex(where: { $0.id == updated.id }) {
                        appState.emergencyContacts[idx] = updated
                        appState.saveToDisk()
                    }
                }
            }
            .quickLookPreview($previewURL)
        }
    }
}


