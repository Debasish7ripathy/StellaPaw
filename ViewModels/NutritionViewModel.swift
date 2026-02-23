import Foundation
import Combine

@MainActor
class NutritionViewModel: ObservableObject {
    private var appState: AppState
    
    @Published var currentMealType: MealType = .breakfast
    @Published var recommendedMeal: FoodItem? = nil
    @Published var insightText: String = ""
    @Published var foodList: [FoodItem] = []   // full species-filtered list for current type
    
    private var cancellables = Set<AnyCancellable>()
    private var lastRecommendedID: String? = nil
    
    init(appState: AppState) {
        self.appState = appState
        
        $currentMealType
            .dropFirst()
            .sink { [weak self] mealType in
                DispatchQueue.main.async {
                    self?.lastRecommendedID = nil
                    self?.refresh(for: mealType)
                }
            }.store(in: &cancellables)
        
        appState.$activePetID.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.lastRecommendedID = nil
                if let type = self?.currentMealType {
                    self?.refresh(for: type)
                }
            }
        }.store(in: &cancellables)
        
        refresh(for: currentMealType)
    }
    
    // MARK: - Public
    
    func refresh(for type: MealType) {
        generateRecommendation(for: type)
        generateFoodList(for: type)
    }
    
    func generateRecommendation(for type: MealType) {
        guard let pet = appState.activePet, let goal = appState.todaysGoalForActivePet else {
            recommendedMeal = nil; insightText = ""; return
        }
        let meal = NutritionEngine.recommendMeal(
            for: pet, mealType: type,
            recentMeals: goal.mealsCompleted,
            excludingID: lastRecommendedID
        )
        lastRecommendedID = meal.id
        recommendedMeal = meal
        insightText = NutritionEngine.generateMealInsight(meal: meal, pet: pet, currentCalorieStatus: goal.calorieProgress)
        objectWillChange.send()
    }
    
    func generateFoodList(for type: MealType) {
        guard let pet = appState.activePet else { foodList = []; return }
        let all = NutritionEngine.mealDatabase
        let byType = all.filter { $0.category == type }
        let bySpecies = byType.filter { $0.suitableSpecies.contains(pet.species) }
        foodList = bySpecies.isEmpty ? byType : bySpecies
    }
    
    func reRoll() { refresh(for: currentMealType) }
    
    func markComplete() {
        guard let meal = recommendedMeal else { return }
        appState.logMeal(meal: meal)
        lastRecommendedID = nil
        refresh(for: currentMealType)
    }
    
    func logFood(_ item: FoodItem) {
        appState.logMeal(meal: item)
        refresh(for: currentMealType)
    }
}

