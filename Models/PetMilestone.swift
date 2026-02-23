import Foundation

struct PetMilestone: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var petID: UUID
    var title: String
    var emoji: String = "🐾"
    var date: Date
    var notes: String = ""

    static let emojiOptions = [
        "🐾","🎂","🏥","💉","🦮","🎓","🏆","❤️","🌟","🎉",
        "🏡","✈️","🌊","🌿","🦴","🐟","🎀","🔔","📷","🌈"
    ]
}
