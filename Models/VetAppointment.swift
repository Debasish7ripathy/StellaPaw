import Foundation

struct VetAppointment: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var petID: UUID
    var title: String
    var vetName: String
    var date: Date
    var location: String = ""
    var notes: String = ""
    var notificationIDs: [String] = []

    var isUpcoming: Bool { date >= Date() }
    var isPast: Bool { date < Date() }

    var countdownText: String {
        let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: Date()), to: Calendar.current.startOfDay(for: date)).day ?? 0
        switch days {
        case 0:  return "Today"
        case 1:  return "Tomorrow"
        case 2...: return "In \(days) days"
        default: return "\(-days) days ago"
        }
    }

    var countdownColor: String {
        let days = Calendar.current.dateComponents([.day], from: Date(), to: date).day ?? 0
        if days < 0  { return "#888888" }
        if days <= 1 { return "#CC0000" }
        if days <= 7 { return "#FF8800" }
        return "#009966"
    }
}
