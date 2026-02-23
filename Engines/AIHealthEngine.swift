import Foundation
import Combine

#if canImport(FoundationModels)
import FoundationModels
#endif

// MARK: - AIHealthEngine (Petora)
// Uses Apple's on-device FoundationModels (Apple Intelligence) when available.
// Falls back to rule-based responses on unsupported devices.



@MainActor
final class AIHealthEngine: ObservableObject {

    static let shared = AIHealthEngine()

    @Published var isAvailable: Bool = false
    @Published var isThinking: Bool = false

    // Dynamic import — compiles on Xcode 16+ even without FoundationModels SDK
    private var sessionAvailable: Bool {
        // Runtime check — returns true only on supported Apple Intelligence devices (iOS 26+)
        if #available(iOS 26, macOS 26, *) {
            return _checkFoundationModelsAvailable()
        }
        return false
    }

    private init() {
        isAvailable = sessionAvailable
    }

    // MARK: - Pet Health Chat

    func ask(_ question: String, pet: PetProfile) async -> String {
        let prompt = buildChatPrompt(question: question, pet: pet)

        if isAvailable, #available(iOS 26, macOS 26, *) {
            if let answer = await callFoundationModel(prompt: prompt) {
                return answer
            }
        }
        return fallbackResponse(for: question, pet: pet)
    }

    // MARK: - Anomaly Explanation

    func explain(_ alert: AnomalyAlert, pet: PetProfile) async -> String {
        let prompt = """
        You are a pet health assistant. A \(pet.species.display) named \(pet.name) has triggered an alert:
        Title: \(alert.title)
        Detail: \(alert.detail)
        
        In 2-3 short sentences: explain why this might be happening and what the owner should do next. Be reassuring but clear. Do not diagnose.
        """

        if isAvailable, #available(iOS 26, macOS 26, *) {
            if let answer = await callFoundationModel(prompt: prompt) {
                return answer
            }
        }
        return "\(alert.detail)\n\nMonitor \(pet.name) closely and consult your vet if this continues for more than 24 hours."
    }

    // MARK: - Private Helpers

    private func buildChatPrompt(question: String, pet: PetProfile) -> String {
        """
        You are Petora, a knowledgeable, friendly pet health assistant inside the StellaPaw app.
        The user's pet: \(pet.name), a \(pet.age)-year-old \(pet.species.display) (\(pet.breed)), \(pet.weight)kg, energy level: \(pet.energyLevel.display).
        
        User question: \(question)
        
        Answer in 3-4 sentences. Be friendly, practical, and always recommend a vet for medical concerns. Never diagnose.
        """
    }

    private func fallbackResponse(for question: String, pet: PetProfile) -> String {
        let q = question.lowercased()
        if q.contains("eat") || q.contains("food") || q.contains("feed") {
            return "\(pet.name) should eat a species-appropriate diet based on their age and energy. Check the Nutrition tab for personalised meal recommendations. Always consult your vet for dietary changes."
        } else if q.contains("sick") || q.contains("ill") || q.contains("vomit") || q.contains("diarr") {
            return "If \(pet.name) seems unwell, monitor for 24 hours and contact your vet if symptoms persist or worsen. Keep them hydrated and comfortable."
        } else if q.contains("walk") || q.contains("exercise") || q.contains("activ") {
            return "\(pet.name)'s recommended activity depends on breed and age. Check the Activity tab to log walks and track daily goals."
        } else if q.contains("vaccin") {
            return "Vaccination schedules vary by species and region. Log upcoming vaccinations in the Appointments tab and ask your vet at the next check-up."
        } else {
            return "Great question about \(pet.name)! For personalised advice, I recommend checking with your vet. Use the Records and Analytics tabs to track \(pet.name)'s health trends over time."
        }
    }

    // Uses @_silgen_name trick to avoid hard linking FoundationModels at compile time
    @available(iOS 26, macOS 26, *)
    private func callFoundationModel(prompt: String) async -> String? {
        do {
            return try await _callFoundationModelDirect(prompt: prompt)
        } catch {
            print("[Petora] FoundationModels unavailable: \(error)")
            return nil
        }
    }

    @available(iOS 26, macOS 26, *)
    private func _callFoundationModelDirect(prompt: String) async throws -> String {
#if canImport(FoundationModels)
        // Use explicit model reference — more reliable than default init
        let model = SystemLanguageModel.default
        guard model.isAvailable else { throw AIError.unavailable }
        let session = LanguageModelSession(model: model)
        let response = try await session.respond(to: prompt)
        return response.content
#else
        throw AIError.notLinked
#endif
    }

    private func _checkFoundationModelsAvailable() -> Bool {
#if canImport(FoundationModels)
        if #available(iOS 26, macOS 26, *) {
            return SystemLanguageModel.default.isAvailable
        }
#endif
        return false
    }

}

enum AIError: Error {
    case notLinked
    case unavailable
}
