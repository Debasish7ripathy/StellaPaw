import Foundation

enum MedFrequency: String, Codable, CaseIterable {
    case daily       = "daily"
    case twiceDaily  = "twiceDaily"
    case weekly      = "weekly"
    case asNeeded    = "asNeeded"

    var display: String {
        switch self {
        case .daily:      return "Once Daily"
        case .twiceDaily: return "Twice Daily"
        case .weekly:     return "Weekly"
        case .asNeeded:   return "As Needed"
        }
    }

    var icon: String {
        switch self {
        case .daily:      return "sun.max.fill"
        case .twiceDaily: return "arrow.2.circlepath"
        case .weekly:     return "calendar"
        case .asNeeded:   return "clock.badge.questionmark"
        }
    }
}

enum MedUnit: String, Codable, CaseIterable {
    case tablet  = "tablet(s)"
    case ml      = "ml"
    case mg      = "mg"
    case drops   = "drop(s)"
    case puff    = "puff(s)"
    case other   = "other"
}

struct Medication: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var petID: UUID
    var name: String
    var dosage: String          // e.g. "1"
    var unit: MedUnit = .tablet
    var frequency: MedFrequency
    var startDate: Date = Date()
    var endDate: Date? = nil
    var notes: String = ""
    var notificationIDs: [String] = []
    var color: String = "#5B5EA6"

    var isActive: Bool {
        guard let end = endDate else { return true }
        return end >= Calendar.current.startOfDay(for: Date())
    }

    var dosageDisplay: String { "\(dosage) \(unit.rawValue)" }
}
