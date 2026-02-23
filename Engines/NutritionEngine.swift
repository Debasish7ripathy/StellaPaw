import Foundation

struct NutritionEngine {
    
    static var mealDatabase: [FoodItem] = loadMealsFromJSON()
    
    /// Recommends a meal for the given pet, filtered by species first.
    static func recommendMeal(
        for pet: PetProfile,
        mealType: MealType,
        recentMeals: [FoodItem],
        excludingID: String? = nil
    ) -> FoodItem {
        // Filter by meal type, then by species
        let byType = mealDatabase.filter { $0.category == mealType }
        let bySpecies = byType.filter { $0.suitableSpecies.contains(pet.species) }
        
        // Use species-filtered pool if available, else fall back to all (for 'other'/'fish' with few items)
        let pool = bySpecies.isEmpty ? byType : bySpecies
        
        let candidates = buildCandidates(from: pool, pet: pet, excludingID: excludingID)
        
        if let pick = candidates.randomElement() {
            return pick
        }
        
        // Absolute fallback — species-appropriate generic meal
        return fallbackMeal(for: pet, mealType: mealType)
    }
    
    private static func buildCandidates(from pool: [FoodItem], pet: PetProfile, excludingID: String?) -> [FoodItem] {
        // Pass 1: Age + energy match, excluding last shown
        var candidates = pool.filter { meal in
            meal.suitableAge.contains(pet.age) &&
            (meal.suitableEnergy == pet.energyLevel || meal.suitableEnergy == .moderate) &&
            meal.id != excludingID
        }
        if !candidates.isEmpty { return candidates }
        
        // Pass 2: Relax energy constraint, still exclude last
        candidates = pool.filter { $0.id != excludingID }
        if !candidates.isEmpty { return candidates }
        
        // Pass 3: Use full pool
        return pool
    }
    
    private static func fallbackMeal(for pet: PetProfile, mealType: MealType) -> FoodItem {
        let (name, ingredients, desc): (String, [String], String) = {
            switch pet.species {
            case .dog:     return ("Balanced Dog Meal", ["protein", "rice", "vegetables"], "A balanced everyday meal suited for dogs.")
            case .cat:     return ("Balanced Cat Meal", ["fish", "chicken broth"], "High-protein meal designed for obligate carnivores.")
            case .bird:    return ("Seed & Pellet Mix", ["seeds", "pellets"], "Complete nutrition for daily bird feeding.")
            case .rabbit:  return ("Hay & Greens", ["timothy hay", "leafy greens"], "High-fibre staple to keep rabbit digestion healthy.")
            case .fish:    return ("Fish Pellets", ["fish meal", "spirulina"], "Balanced micro-pellets for aquatic pets.")
            case .hamster: return ("Seed & Veggie Mix", ["sunflower seeds", "carrot", "broccoli"], "Varied diet for hamster energy and foraging enrichment.")
            case .turtle:  return ("Leafy Greens & Pellets", ["romaine lettuce", "turtle pellets"], "Balanced reptile diet rich in calcium and vitamins.")
            case .other:   return ("Balanced Pet Meal", ["protein", "vegetables"], "A general balanced meal for your pet.")
            }
        }()
        return FoodItem(
            id: "fallback_\(pet.species.rawValue)",
            name: name,
            category: mealType,
            calories: 150,
            protein: 10,
            fat: 4,
            fiber: 3,
            suitableAge: .all,
            suitableEnergy: .moderate,
            healthBenefitDescription: desc,
            ingredients: ingredients,
            suitableSpecies: [pet.species]
        )
    }


    
    static func generateMealInsight(meal: FoodItem, pet: PetProfile, currentCalorieStatus: Double) -> String {
        var insights: [String] = []
        
        if pet.age > 10 {
            insights.append("Senior-friendly: Easier to digest and gentle on joints.")
        } else if pet.age < 2 {
            insights.append("Puppy power: High protein for growth.")
        }
        
        if pet.energyLevel == .veryHigh {
            insights.append("High energy breed: Extra calories for active metabolism.")
        }
        
        if currentCalorieStatus > 0.8 {
            insights.append("Nearly met daily goal: Light meal to avoid overfeeding.")
        } else if currentCalorieStatus < 0.5 {
            insights.append("More nutrition needed: Balanced meal to reach target.")
        }
        
        insights.append(meal.healthBenefitDescription)
        
        return insights.joined(separator: "\n\n")
    }
    
    private static func loadMealsFromJSON() -> [FoodItem] {
        guard let url = Bundle.main.url(forResource: "meals_database", withExtension: "json") else {
            print("meals_database.json not found in main bundle")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([FoodItem].self, from: data)
            return decoded
        } catch {
            print("Failed to load meals: \(error)")
            return []
        }
    }
}
