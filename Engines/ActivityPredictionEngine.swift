import Foundation
import CoreML

// MARK: - ActivityPredictionEngine
// Predicts tomorrow's recommended calorie target and activity distance
// based on the pet's history, profile, and activity patterns.
//
// Architecture:
//   1. If ActivityPredictor.mlmodel is bundled → use CoreML inference
//   2. Otherwise → use built-in regression formulas (identical logic to the trained model)
//
// To generate the CoreML model, run Scripts/TrainActivityModel.swift on macOS.

struct ActivityPrediction {
    let recommendedCalories: Int
    let recommendedActivityKM: Double
    let recommendedWaterML: Double
    let confidenceLevel: ConfidenceLevel
    let insights: [String]

    enum ConfidenceLevel: String {
        case high   = "High"
        case medium = "Medium"
        case low    = "Low (add more history)"

        var color: String {
            switch self {
            case .high:   return "#34C759"
            case .medium: return "#FF9500"
            case .low:    return "#8E8E93"
            }
        }
        var icon: String {
            switch self {
            case .high:   return "checkmark.seal.fill"
            case .medium: return "chart.line.uptrend.xyaxis"
            case .low:    return "ellipsis.circle"
            }
        }
    }
}

// MARK: - Feature Vector

private struct PetFeatures {
    let speciesCode: Double       // dog=0,cat=1,bird=2,rabbit=3,fish=4,hamster=5,turtle=6,other=7
    let ageYears: Double
    let weightKG: Double
    let energyCode: Double        // low=0, moderate=1, high=2
    let avgActivityKM: Double     // 7-day rolling average
    let avgCalories: Double       // 7-day rolling average consumed
    let avgWaterML: Double        // 7-day rolling average
    let activityStreak: Int       // consecutive active days
    let dayOfWeek: Double         // 0=Sun…6=Sat
}

// MARK: - Engine

final class ActivityPredictionEngine {

    static let shared = ActivityPredictionEngine()
    private var coreMLModel: MLModel?

    private init() {
        loadCoreMLModelIfAvailable()
    }

    // MARK: - Public

    func predict(for pet: PetProfile, history: [DailyGoal]) -> ActivityPrediction {
        let features = buildFeatures(pet: pet, history: history)

        if let model = coreMLModel {
            return predictWithCoreML(model: model, features: features, pet: pet, history: history)
        } else {
            return predictWithRegression(features: features, pet: pet, history: history)
        }
    }

    // MARK: - CoreML Path

    private func loadCoreMLModelIfAvailable() {
        guard let url = Bundle.main.url(forResource: "ActivityPredictor", withExtension: "mlmodelc")
                     ?? Bundle.main.url(forResource: "ActivityPredictor", withExtension: "mlmodel")
        else { return }
        coreMLModel = try? MLModel(contentsOf: url)
    }

    private func predictWithCoreML(model: MLModel, features: PetFeatures, pet: PetProfile, history: [DailyGoal]) -> ActivityPrediction {
        let input: [String: Any] = [
            "species":        features.speciesCode,
            "age":            features.ageYears,
            "weight":         features.weightKG,
            "energy":         features.energyCode,
            "avg_activity_km": features.avgActivityKM,
            "avg_calories":   features.avgCalories,
            "avg_water_ml":   features.avgWaterML,
            "streak":         Double(features.activityStreak),
            "day_of_week":    features.dayOfWeek
        ]
        guard let provider = try? MLDictionaryFeatureProvider(dictionary: input.mapValues { $0 as! NSObject }),
              let output = try? model.prediction(from: provider) else {
            return predictWithRegression(features: features, pet: pet, history: history)
        }
        let cal  = output.featureValue(for: "recommended_calories")?.doubleValue ?? Double(fallbackCalories(features))
        let km   = output.featureValue(for: "recommended_km")?.doubleValue ?? fallbackKM(features)
        let water = output.featureValue(for: "recommended_water_ml")?.doubleValue ?? fallbackWater(features)
        return ActivityPrediction(
            recommendedCalories: Int(cal),
            recommendedActivityKM: km,
            recommendedWaterML: water,
            confidenceLevel: history.count >= 7 ? .high : .medium,
            insights: buildInsights(features: features, calories: Int(cal), km: km, pet: pet)
        )
    }

    // MARK: - Built-in Regression (mirrors trained model logic)

    private func predictWithRegression(features: PetFeatures, pet: PetProfile, history: [DailyGoal]) -> ActivityPrediction {
        let cal  = fallbackCalories(features)
        let km   = fallbackKM(features)
        let water = fallbackWater(features)
        let confidence: ActivityPrediction.ConfidenceLevel = history.count >= 14 ? .high : history.count >= 5 ? .medium : .low
        return ActivityPrediction(
            recommendedCalories: cal,
            recommendedActivityKM: km,
            recommendedWaterML: water,
            confidenceLevel: confidence,
            insights: buildInsights(features: features, calories: cal, km: km, pet: pet)
        )
    }

    // MARK: - Regression Formulas

    private func fallbackCalories(_ f: PetFeatures) -> Int {
        // Base metabolic rate × species multiplier × energy multiplier + activity adjustment
        let baseBMR: Double = 70 * pow(f.weightKG, 0.75)
        let speciesMultiplier: Double = [1.6, 1.4, 0.8, 0.6, 0.3, 0.5, 0.4, 1.0][Int(f.speciesCode)] 
        let energyMult: Double = [0.85, 1.0, 1.3][Int(f.energyCode)]
        let activityBonus: Double = f.avgActivityKM * 35   // ~35 kcal per km
        let ageFactor: Double = f.ageYears > 8 ? 0.85 : (f.ageYears < 1 ? 1.3 : 1.0)
        let base = baseBMR * speciesMultiplier * energyMult * ageFactor + activityBonus
        // Blend with historical average (regression toward mean)
        let blended = f.avgCalories > 0 ? (base * 0.6 + f.avgCalories * 0.4) : base
        return max(50, Int(blended))
    }

    private func fallbackKM(_ f: PetFeatures) -> Double {
        // Base by species, scaled by energy level and age
        let baseKM: [Double] = [3.0, 1.5, 0.0, 0.5, 0.0, 0.2, 0.1, 1.5]
        let base = baseKM[Int(f.speciesCode)]
        let energyMult: Double = [0.7, 1.0, 1.4][Int(f.energyCode)]
        let ageFactor: Double = f.ageYears > 8 ? 0.7 : (f.ageYears < 1 ? 0.6 : 1.0)
        // Weekend boost
        let weekendBoost: Double = (f.dayOfWeek == 0 || f.dayOfWeek == 6) ? 1.2 : 1.0
        let target = base * energyMult * ageFactor * weekendBoost
        // Blend with historical
        let blended = f.avgActivityKM > 0 ? (target * 0.55 + f.avgActivityKM * 0.45) : target
        return (blended * 100).rounded() / 100
    }

    private func fallbackWater(_ f: PetFeatures) -> Double {
        // ~50ml/kg for most pets, adjusted by activity and species
        let base = f.weightKG * 50
        let activityBonus = f.avgActivityKM * 100
        let speciesMult: [Double] = [1.0, 0.85, 0.3, 0.7, 0.0, 0.4, 0.2, 0.9]
        return (base + activityBonus) * speciesMult[Int(f.speciesCode)]
    }

    // MARK: - Feature Building

    private func buildFeatures(pet: PetProfile, history: [DailyGoal]) -> PetFeatures {
        let recent = history.suffix(7)
        let avgKM    = recent.isEmpty ? 0 : recent.map(\.activityCompletedKM).reduce(0, +) / Double(recent.count)
        let avgCal   = recent.isEmpty ? 0 : Double(recent.map(\.caloriesConsumed).reduce(0, +)) / Double(recent.count)
        let avgWater = recent.isEmpty ? 0 : recent.map(\.waterConsumedML).reduce(0, +) / Double(recent.count)
        let streak   = history.filter { $0.activityCompletedKM >= $0.activityTargetKM * 0.6 }.count
        let dow      = Double(Calendar.current.component(.weekday, from: Date()) - 1)
        let speciesCode: Double = {
            switch pet.species {
            case .dog: return 0; case .cat: return 1; case .bird: return 2
            case .rabbit: return 3; case .fish: return 4; case .hamster: return 5
            case .turtle: return 6; case .other: return 7
            }
        }()
        let energyCode: Double = pet.energyLevel == .low ? 0 : pet.energyLevel == .moderate ? 1 : 2
        return PetFeatures(
            speciesCode: speciesCode,
            ageYears: Double(pet.age),
            weightKG: pet.weight,
            energyCode: energyCode,
            avgActivityKM: avgKM,
            avgCalories: avgCal,
            avgWaterML: avgWater,
            activityStreak: streak,
            dayOfWeek: dow
        )
    }

    // MARK: - Insight Generation

    private func buildInsights(features: PetFeatures, calories: Int, km: Double, pet: PetProfile) -> [String] {
        var insights: [String] = []
        if features.avgActivityKM < km * 0.7 {
            insights.append("📈 \(pet.name) has been less active lately — a gentle increase would help.")
        } else if features.avgActivityKM > km * 1.3 {
            insights.append("💪 \(pet.name) is crushing their activity goals! Keep it up.")
        }
        if features.ageYears > 8 {
            insights.append("🐾 Senior pet adjustments applied — lower intensity recommended.")
        }
        if features.dayOfWeek == 0 || features.dayOfWeek == 6 {
            insights.append("🌤 Weekend! Great time for a longer walk or outdoor play session.")
        }
        if features.activityStreak >= 5 {
            insights.append("🔥 \(features.activityStreak)-day activity streak — amazing consistency!")
        }
        if features.energyCode == 2 {
            insights.append("⚡ High-energy profile — \(pet.name) needs regular vigorous exercise.")
        }
        return insights.isEmpty ? ["Keep logging to get personalised insights!"] : insights
    }
}
