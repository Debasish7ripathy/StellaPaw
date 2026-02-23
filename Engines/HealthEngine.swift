import Foundation

struct HealthEngine {
    
    static let breedActivityDefaults: [String: Double] = [
        "Border Collie": 5.0,
        "Labrador Retriever": 4.0,
        "German Shepherd": 4.5,
        "Beagle": 3.0,
        "Bulldog": 1.5,
        "Chihuahua": 1.0,
        "Poodle": 3.5,
        "Golden Retriever": 4.0
    ]
    
    static func calculateHydrationTarget(weight: Double) -> Double {
        return weight * 60.0
    }
    
    static func calculateCalorieTarget(weight: Double, age: Int, energyLevel: EnergyLevel) -> Int {
        let baseCalories = weight * 30.0
        
        let energyMultiplier: Double
        switch energyLevel {
        case .low: energyMultiplier = 0.8
        case .moderate: energyMultiplier = 1.0
        case .high: energyMultiplier = 1.3
        case .veryHigh: energyMultiplier = 1.5
        }
        
        let ageAdjustment: Double = age > 10 ? 0.9 : 1.0
        
        return Int(baseCalories * energyMultiplier * ageAdjustment)
    }
    
    static func calculateActivityTarget(breed: String, energyLevel: EnergyLevel, currentStreak: Int) -> Double {
        let baseDistance = breedActivityDefaults[breed] ?? 2.5
        
        let energyBonus: Double
        switch energyLevel {
        case .low: energyBonus = 0.0
        case .moderate: energyBonus = 0.5
        case .high: energyBonus = 1.0
        case .veryHigh: energyBonus = 1.5
        }
        
        let streakMultiplier = 1.0 + (Double(currentStreak / 5) * 0.05)
        
        return (baseDistance + energyBonus) * streakMultiplier
    }
    
    static func adaptGoalsForTomorrow(yesterdayGoal: DailyGoal, currentTarget: DailyGoal) -> DailyGoal {
        var adapted = currentTarget
        
        // Calories logic
        if yesterdayGoal.caloriesTarget > 0 {
            let calorieRatio = Double(yesterdayGoal.caloriesConsumed) / Double(yesterdayGoal.caloriesTarget)
            if calorieRatio > 1.1 {
                adapted.caloriesTarget = Int(Double(adapted.caloriesTarget) * 0.95)
            }
        }
        
        // Activity logic
        if yesterdayGoal.activityTargetKM > 0 {
            let activityRatio = yesterdayGoal.activityCompletedKM / yesterdayGoal.activityTargetKM
            if activityRatio > 1.0 {
                adapted.activityTargetKM = adapted.activityTargetKM * 1.02
            }
        }
        
        // Hydration logic doesn't increase difficulty if missed
        
        return adapted
    }
}
