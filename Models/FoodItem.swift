import Foundation

enum MealType: String, Codable, CaseIterable, Equatable {
    case breakfast = "breakfast"
    case snack1 = "snack1"
    case lunch = "lunch"
    case snack2 = "snack2"
    case eveningSnack = "eveningSnack"
    case dinner = "dinner"
    
    var display: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .snack1: return "Mid-Morning Snack"
        case .lunch: return "Lunch"
        case .snack2: return "Afternoon Snack"
        case .eveningSnack: return "Evening Snack"
        case .dinner: return "Dinner"
        }
    }
}

enum AgeRange: String, Codable, Equatable {
    case puppy = "puppy"
    case adult = "adult"
    case senior = "senior"
    case all = "all"
    
    func contains(_ age: Int) -> Bool {
        switch self {
        case .puppy: return age >= 0 && age < 2
        case .adult: return age >= 2 && age < 10
        case .senior: return age >= 10
        case .all: return true
        }
    }
}

struct FoodItem: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var name: String
    var category: MealType
    var calories: Int
    var protein: Double
    var fat: Double
    var fiber: Double
    var suitableAge: AgeRange
    var suitableEnergy: EnergyLevel
    var healthBenefitDescription: String
    var ingredients: [String]
    var suitableSpecies: [PetSpecies] = PetSpecies.allCases
}

