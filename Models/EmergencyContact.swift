import Foundation

struct EmergencyContact: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var role: String      // e.g. "Vet", "Poison Control", "Emergency Clinic"
    var phone: String
    var notes: String = ""
    var isPrimary: Bool = false
    
    var roleIcon: String {
        let lower = role.lowercased()
        if lower.contains("vet") { return "stethoscope" }
        if lower.contains("poison") { return "exclamationmark.triangle.fill" }
        if lower.contains("hospital") || lower.contains("clinic") || lower.contains("emergency") { return "cross.fill" }
        if lower.contains("groomer") { return "scissors" }
        return "phone.fill"
    }
    
    var roleColor: String {
        let lower = role.lowercased()
        if lower.contains("vet") { return "#0066CC" }
        if lower.contains("poison") { return "#FF8800" }
        if lower.contains("hospital") || lower.contains("clinic") || lower.contains("emergency") { return "#CC0000" }
        return "#009966"
    }
    
    // MARK: - Built-in defaults
    static var defaults: [EmergencyContact] = [
        EmergencyContact(
            name: "ASPCA Animal Poison Control",
            role: "Poison Control",
            phone: "+18888264435",
            notes: "Available 24/7. Consultation fee may apply.",
            isPrimary: true
        ),
        EmergencyContact(
            name: "Pet Poison Helpline",
            role: "Poison Control",
            phone: "+18003137559",
            notes: "24/7 animal poison control center."
        ),
        EmergencyContact(
            name: "My Vet Clinic",
            role: "Vet",
            phone: "",
            notes: "Tap to edit and add your vet's number."
        )
    ]
}
