import Foundation

enum ActivityType: String, Codable, CaseIterable {
    case walk = "walk"
    case run = "run"
    case swim = "swim"
    case fetch = "fetch"
    case agility = "agility"
    case tug = "tug"
    case hiking = "hiking"
    case parkPlay = "parkPlay"
    case training = "training"
    case socialPlay = "socialPlay"

    var display: String {
        switch self {
        case .walk: return "Walk"
        case .run: return "Run"
        case .swim: return "Swim"
        case .fetch: return "Fetch"
        case .agility: return "Agility"
        case .tug: return "Tug of War"
        case .hiking: return "Hiking"
        case .parkPlay: return "Park Play"
        case .training: return "Training"
        case .socialPlay: return "Social Play"
        }
    }

    var icon: String {
        switch self {
        case .walk: return "pawprint.fill"
        case .run: return "hare.fill"
        case .swim: return "fish.fill"
        case .fetch: return "soccerball"
        case .agility: return "star.circle.fill"
        case .tug: return "bolt.fill"
        case .hiking: return "mountain.2.fill"
        case .parkPlay: return "tree.fill"
        case .training: return "checkmark.seal.fill"
        case .socialPlay: return "pawprint.circle.fill"
        }
    }

    /// Approximate km equivalent per minute (used to convert timed activities to distance)
    var kmPerMinute: Double {
        switch self {
        case .walk: return 0.08
        case .run: return 0.18
        case .swim: return 0.05
        case .fetch: return 0.12
        case .agility: return 0.15
        case .tug: return 0.03
        case .hiking: return 0.10
        case .parkPlay: return 0.07
        case .training: return 0.04
        case .socialPlay: return 0.06
        }
    }
}

struct ActivityEntry: Identifiable, Codable {
    var id: UUID = UUID()
    var type: ActivityType
    var durationMinutes: Int
    var distanceKM: Double
    var date: Date
}

struct DailyGoal: Identifiable, Codable {
    var id: UUID = UUID()
    var petID: UUID
    var date: Date

    var activityTargetKM: Double
    var activityCompletedKM: Double = 0.0
    var activityLog: [ActivityEntry] = []

    var waterTargetML: Double
    var waterConsumedML: Double = 0.0

    var caloriesTarget: Int
    var caloriesConsumed: Int = 0

    var mealsCompleted: [FoodItem] = []
    var relaxationMinutes: Int = 0

    var activityProgress: Double {
        activityTargetKM > 0 ? activityCompletedKM / activityTargetKM : 0.0
    }

    var hydrationProgress: Double {
        waterTargetML > 0 ? waterConsumedML / waterTargetML : 0.0
    }

    var calorieProgress: Double {
        caloriesTarget > 0 ? Double(caloriesConsumed) / Double(caloriesTarget) : 0.0
    }
}
