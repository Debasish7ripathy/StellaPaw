import SwiftUI

struct EmergencyCareView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var selectedSpecies: PetSpecies = .dog
    @State private var selectedCategory: EmergencyCategory? = nil
    @State private var showingAddContact = false
    @State private var editingContact: EmergencyContact? = nil
    
    private var guides: [EmergencyCategory] {
        EmergencyGuide.categories(for: selectedSpecies)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Emergency header banner
                    HStack(spacing: 12) {
                        Image(systemName: "cross.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Emergency First Aid")
                                .font(.headline.bold())
                                .foregroundColor(.white)
                            Text("Select your pet and emergency type.")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.85))
                        }
                        Spacer()
                    }
                    .padding()
                    .background(
                        LinearGradient(colors: [Color.red.opacity(0.9), Color(hex: "#CC0000")],
                                       startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Disclaimer
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.orange)
                        Text("This guide provides basic first aid only. Always contact a vet for professional care.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    
                    // Species Selector
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Select Animal Type")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(PetSpecies.allCases, id: \.self) { species in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedSpecies = species
                                            selectedCategory = nil
                                        }
                                    }) {
                                        VStack(spacing: 6) {
                                            Text(species.icon)
                                                .font(.title)
                                            Text(species.display)
                                                .font(.caption.bold())
                                                .foregroundColor(selectedSpecies == species ? .white : .primary)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(selectedSpecies == species ? Color.red.opacity(0.85) : Theme.cardBackground)
                                        .cornerRadius(14)
                                        .shadow(color: selectedSpecies == species ? Color.red.opacity(0.3) : .black.opacity(0.05),
                                                radius: 6, x: 0, y: 3)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Emergency Category Grid
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Emergency Type")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(guides) { category in
                                Button(action: {
                                    withAnimation(.spring(response: 0.35)) {
                                        selectedCategory = selectedCategory?.id == category.id ? nil : category
                                    }
                                }) {
                                    HStack(spacing: 10) {
                                        Image(systemName: category.icon)
                                            .font(.title3)
                                            .foregroundColor(.white)
                                            .frame(width: 36, height: 36)
                                            .background(colorFromHex(category.color))
                                            .clipShape(Circle())
                                        
                                        Text(category.name)
                                            .font(.subheadline.bold())
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        
                                        Image(systemName: selectedCategory?.id == category.id ? "chevron.up" : "chevron.down")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(12)
                                    .background(
                                        selectedCategory?.id == category.id
                                        ? colorFromHex(category.color).opacity(0.1)
                                        : Theme.cardBackground
                                    )
                                    .cornerRadius(14)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(selectedCategory?.id == category.id ? colorFromHex(category.color) : Color.clear, lineWidth: 1.5)
                                    )
                                    .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Detail Card
                    if let category = selectedCategory {
                        EmergencyDetailCard(category: category)
                            .padding(.horizontal)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    // Emergency Contacts Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Emergency Contacts", systemImage: "phone.circle.fill")
                                .font(.title3.bold())
                                .foregroundColor(.red)
                            Spacer()
                            Button(action: { showingAddContact = true }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.horizontal)

                        ForEach(appState.emergencyContacts) { contact in
                            ContactRow(contact: contact,
                                       onEdit: { editingContact = contact },
                                       onDelete: {
                                           appState.emergencyContacts.removeAll { $0.id == contact.id }
                                           appState.saveToDisk()
                                       })
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)

                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Emergency Care")
            .navigationBarTitleDisplayMode(.inline)
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
        }
    }
    
    private func colorFromHex(_ hex: String) -> Color {
        Color(hex: hex)
    }
}

// MARK: - Detail Card

private struct EmergencyDetailCard: View {
    let category: EmergencyCategory
    @State private var showingSteps = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            // Header
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color(hex: category.color))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name)
                        .font(.title3.bold())
                    Text(category.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            
            Divider()
            
            // Warning Signs
            VStack(alignment: .leading, spacing: 8) {
                Label("Warning Signs", systemImage: "exclamationmark.circle.fill")
                    .font(.headline)
                    .foregroundColor(.orange)
                    .padding(.top, 12)
                
                FlowTagRow(tags: category.warningSigns, color: .orange)
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.vertical, 8)
            
            // First Aid Steps
            VStack(alignment: .leading, spacing: 10) {
                Label("First Aid Steps", systemImage: "cross.case.fill")
                    .font(.headline)
                    .foregroundColor(Color(hex: category.color))
                
                ForEach(Array(category.steps.enumerated()), id: \.offset) { idx, step in
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: category.color))
                                .frame(width: 26, height: 26)
                            Text("\(idx + 1)")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        }
                        Text(step)
                            .font(.subheadline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.vertical, 8)
            
            // Call Vet
            VStack(alignment: .leading, spacing: 6) {
                Label("Call the Vet When", systemImage: "phone.fill")
                    .font(.headline)
                    .foregroundColor(.red)
                
                Text(category.callVetWhen)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .background(Theme.cardBackground)
        .cornerRadius(18)
        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 4)
    }
}

// MARK: - Flow Tag Row

private struct FlowTagRow: View {
    let tags: [String]
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                ForEach(Array(tags.prefix(3).enumerated()), id: \.offset) { _, tag in
                    Text(tag)
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(color.opacity(0.15))
                        .foregroundColor(color)
                        .cornerRadius(20)
                }
            }
            if tags.count > 3 {
                HStack(spacing: 8) {
                    ForEach(Array(tags.dropFirst(3).enumerated()), id: \.offset) { _, tag in
                        Text(tag)
                            .font(.caption.bold())
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(color.opacity(0.15))
                            .foregroundColor(color)
                            .cornerRadius(20)
                    }
                }
            }
        }
        .padding(.bottom, 6)
    }
}

// Color(hex:) is defined in Theme.swift

// MARK: - Contact Row

private struct ContactRow: View {
    let contact: EmergencyContact
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: contact.roleColor).opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: contact.roleIcon)
                    .foregroundColor(Color(hex: contact.roleColor))
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                HStack {
                    Text(contact.name)
                        .font(.headline)
                    if contact.isPrimary {
                        Text("PRIMARY")
                            .font(.caption2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .cornerRadius(6)
                    }
                }
                Text(contact.role)
                    .font(.caption)
                    .foregroundColor(.secondary)
                if !contact.notes.isEmpty {
                    Text(contact.notes)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
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
                        .background(Color.green)
                        .clipShape(Circle())
                }
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.orange)
        }
    }
}

// MARK: - Contact Editor Sheet

struct ContactEditorSheet: View {
    @Environment(\.dismiss) var dismiss
    
    let contact: EmergencyContact?
    let onSave: (EmergencyContact) -> Void
    
    @State private var name: String
    @State private var role: String
    @State private var phone: String
    @State private var notes: String
    @State private var isPrimary: Bool
    
    init(contact: EmergencyContact?, onSave: @escaping (EmergencyContact) -> Void) {
        self.contact = contact
        self.onSave = onSave
        _name = State(initialValue: contact?.name ?? "")
        _role = State(initialValue: contact?.role ?? "Vet")
        _phone = State(initialValue: contact?.phone ?? "")
        _notes = State(initialValue: contact?.notes ?? "")
        _isPrimary = State(initialValue: contact?.isPrimary ?? false)
    }
    
    private let roleOptions = ["Vet", "Emergency Clinic", "Poison Control", "Groomer", "Pet Sitter", "Other"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Contact Details") {
                    TextField("Name", text: $name)
                    
                    Picker("Role", selection: $role) {
                        ForEach(roleOptions, id: \.self) { Text($0).tag($0) }
                    }
                    
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.green)
                        TextField("Phone Number", text: $phone)
                            .keyboardType(.phonePad)
                    }
                    
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
                
                Section {
                    Toggle("Mark as Primary Contact", isOn: $isPrimary)
                        .tint(.red)
                }
                
                if !phone.isEmpty {
                    Section {
                        Button(action: {
                            if let url = URL(string: "tel://\(phone.filter { $0.isNumber || $0 == "+" })") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Label("Test Call", systemImage: "phone.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
            .navigationTitle(contact == nil ? "New Contact" : "Edit Contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let updated = EmergencyContact(
                            id: contact?.id ?? UUID(),
                            name: name,
                            role: role,
                            phone: phone,
                            notes: notes,
                            isPrimary: isPrimary
                        )
                        onSave(updated)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                    .bold()
                }
            }
        }
    }
}

