import Foundation

enum Gender: String, Codable, CaseIterable {
    case male = "male"
    case female = "female"
    case unknown = "unknown"
    
    var display: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .unknown: return "Unknown"
        }
    }
}

enum PetSpecies: String, Codable, CaseIterable {
    case dog = "dog"
    case cat = "cat"
    case rabbit = "rabbit"
    case hamster = "hamster"
    case bird = "bird"
    case fish = "fish"
    case turtle = "turtle"
    case other = "other"
    
    var display: String {
        switch self {
        case .dog: return "Dog"
        case .cat: return "Cat"
        case .rabbit: return "Rabbit"
        case .hamster: return "Hamster"
        case .bird: return "Bird"
        case .fish: return "Fish"
        case .turtle: return "Turtle"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .dog: return "🐶"
        case .cat: return "🐱"
        case .rabbit: return "🐰"
        case .hamster: return "🐹"
        case .bird: return "🐦"
        case .fish: return "🐟"
        case .turtle: return "🐢"
        case .other: return "🐾"
        }
    }
    
    var systemIcon: String {
        switch self {
        case .dog: return "pawprint.fill"
        case .cat: return "pawprint"
        case .rabbit: return "hare.fill"
        case .hamster: return "cursorarrow.motionlines"
        case .bird: return "bird.fill"
        case .fish: return "fish.fill"
        case .turtle: return "tortoise.fill"
        case .other: return "pawprint.circle.fill"
        }
    }
}

enum EnergyLevel: String, Codable, CaseIterable {
    case low = "low"
    case moderate = "moderate"
    case high = "high"
    case veryHigh = "veryHigh"
    
    var display: String {
        switch self {
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        case .veryHigh: return "Very High"
        }
    }
    
    var description: String {
        switch self {
        case .low: return "Senior or less active pets"
        case .moderate: return "Average activity level"
        case .high: return "Active breeds, daily exercise"
        case .veryHigh: return "Working/sport pets, high activity"
        }
    }
}

struct PetProfile: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var species: PetSpecies = .dog
    var breed: String
    var age: Int = 3
    var weight: Double = 15.0
    var gender: Gender = .unknown
    var energyLevel: EnergyLevel = .moderate
    var profileImageData: Data? = nil
    var createdAt: Date = Date()
    var lastActiveDate: Date = Date()
}
