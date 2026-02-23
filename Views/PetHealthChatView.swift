import SwiftUI

// MARK: - Chat Message Model

struct ChatMessage: Identifiable {
    let id: String = UUID().uuidString
    let role: Role
    let text: String
    let timestamp = Date()

    enum Role { case user, ai, system }
}

// MARK: - Pet Health Chat View

struct PetHealthChatView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var ai = AIHealthEngine.shared
    @State private var messages: [ChatMessage] = []
    @State private var input: String = ""
    @State private var isTyping = false
    @FocusState private var focused: Bool

    private var pet: PetProfile? { appState.activePet }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Status bar
                aiStatusBanner

                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(messages) { msg in
                                MessageBubble(message: msg)
                                    .id(msg.id)
                            }
                            if isTyping {
                                TypingIndicator()
                                    .id("typing")
                            }
                        }
                        .padding()
                    }
                    .onChange(of: messages.count) { _, _ in
                        withAnimation { proxy.scrollTo(messages.last?.id ?? "typing", anchor: .bottom) }
                    }
                    .onChange(of: isTyping) { _, typing in
                        if typing { withAnimation { proxy.scrollTo("typing", anchor: .bottom) } }
                    }
                }

                // Input bar
                inputBar
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Petora")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { loadWelcome() }
        }
    }


    // MARK: - Status Banner

    private var aiStatusBanner: some View {
        HStack(spacing: 8) {
            // Animated pulse dot
            ZStack {
                Circle()
                    .fill(ai.isAvailable ? Color.green.opacity(0.3) : Color.orange.opacity(0.3))
                    .frame(width: 14, height: 14)
                Circle()
                    .fill(ai.isAvailable ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
            }
            Text(ai.isAvailable
                 ? "Petora AI · Apple Intelligence active"
                 : "Petora AI · Smart mode")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(ai.isAvailable ? Color.green : Color(hex: "#FF9500"))
            Spacer()
            if !ai.isAvailable {
                Text("Needs iPhone 15 Pro+")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            (ai.isAvailable ? Color.green : Color.orange).opacity(0.06)
        )
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color.primary.opacity(0.08)),
            alignment: .bottom
        )
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: 10) {
            HStack {
                TextField("Ask Petora about \(pet?.name ?? "your pet")…", text: $input, axis: .vertical)
                    .lineLimit(1...5)
                    .font(.callout)
                    .focused($focused)
                    .padding(.leading, 4)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color(.secondarySystemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
            )

            // Send button
            Button(action: send) {
                ZStack {
                    Circle()
                        .fill(
                            input.trimmingCharacters(in: .whitespaces).isEmpty
                            ? AnyShapeStyle(Color(.tertiarySystemBackground))
                            : AnyShapeStyle(LinearGradient(
                                colors: [Color(hex: "#7C3AED"), Color(hex: "#2563EB")],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                        )
                        .frame(width: 42, height: 42)
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(
                            input.trimmingCharacters(in: .whitespaces).isEmpty
                            ? Color.secondary : .white
                        )
                }
            }
            .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty || isTyping)
            .animation(.spring(response: 0.3), value: input.isEmpty)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }

    // MARK: - Quick Suggestions

    private var suggestions: [String] {
        guard let pet else { return [] }
        switch pet.species {
        case .dog:    return ["Why is my dog lethargic?", "How much should \(pet.name) eat daily?", "Is panting normal?"]
        case .cat:    return ["My cat isn't eating", "How often should I groom \(pet.name)?", "Signs of dehydration?"]
        case .rabbit: return ["Safe vegetables for rabbits?", "\(pet.name) isn't pooping", "How much hay per day?"]
        case .bird:   return ["Why is my bird quiet?", "Safe fruits for \(pet.species.display)s?", "Signs of illness in birds"]
        case .fish:   return ["Cloudy tank water?", "Fish not eating?", "How often to change water?"]
        case .hamster: return ["Why is my hamster sleeping all day?", "Safe hamster treats?", "Exercise wheel importance"]
        case .turtle:  return ["Tortoise not eating?", "Shell health tips", "Basking temperature?"]
        case .other:  return ["General pet health tips", "When to see a vet?", "Hydration tips"]
        }
    }

    // MARK: - Actions

    private func loadWelcome() {
        guard messages.isEmpty else { return }
        let name = pet?.name ?? "your pet"
        let species = pet?.species.display ?? "pet"
        messages.append(ChatMessage(role: .system, text:
            "👋 Hi! I'm **Petora**, your AI pet health companion in StellaPaw. Ask me anything about \(name)'s health, diet, behaviour, or care.\n\nI specialise in \(species) care and give personalised advice based on \(name)'s profile."
        ))
        // Pre-load suggestion chips
        for s in suggestions.prefix(3) {
            messages.append(ChatMessage(role: .system, text: "💡 \(s)"))
        }
    }


    private func send() {
        let q = input.trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty, let pet else { return }
        input = ""
        focused = false
        messages.append(ChatMessage(role: .user, text: q))
        isTyping = true

        Task {
            let answer = await ai.ask(q, pet: pet)
            try? await Task.sleep(nanoseconds: 600_000_000) // slight delay for UX
            isTyping = false
            messages.append(ChatMessage(role: .ai, text: answer))
        }
    }
}

// MARK: - Message Bubble

private struct MessageBubble: View {
    let message: ChatMessage

    var isUser: Bool { message.role == .user }
    var isSystem: Bool { message.role == .system }
    var isSuggestion: Bool { message.text.hasPrefix("💡") }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 50) }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                if isSuggestion {
                    // Render suggestions as tappable chips (display only)
                    Text(String(message.text.dropFirst(2)))
                        .font(.caption)
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(Theme.primary.opacity(0.1))
                        .foregroundColor(Theme.primary)
                        .cornerRadius(14)
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.primary.opacity(0.3), lineWidth: 1))
                } else {
                    Text(message.text)
                        .font(.callout)
                        .padding(.horizontal, 14).padding(.vertical, 10)
                        .background(
                            isUser ? Theme.primary :
                            isSystem ? Theme.cardBackground : Theme.cardBackground
                        )
                        .foregroundColor(isUser ? .white : .primary)
                        .cornerRadius(18)
                        .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 2)
                }

                Text(message.timestamp, format: .dateTime.hour().minute())
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }

            if !isUser { Spacer(minLength: 50) }
        }
    }
}

// MARK: - Typing Indicator

private struct TypingIndicator: View {
    @State private var animating = false
    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Theme.primary.opacity(0.6))
                    .frame(width: 8, height: 8)
                    .scaleEffect(animating ? 1.3 : 0.7)
                    .animation(.easeInOut(duration: 0.4).repeatForever().delay(Double(i) * 0.15), value: animating)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(Theme.cardBackground)
        .cornerRadius(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { animating = true }
    }
}
