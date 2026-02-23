import Foundation
import Combine

@MainActor
class AnalyticsViewModel: ObservableObject {
    private var appState: AppState
    
    enum MetricType: String, CaseIterable {
        case activity = "Activity"
        case hydration = "Hydration"
        case calories = "Calories"
    }
    
    @Published var selectedMetric: MetricType = .activity
    @Published var consistencyScore: Int = 0
    @Published var weeklyTrend: [ChartDataPoint] = []
    @Published var streak: Int = 0
    @Published var bestStreak: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init(appState: AppState) {
        self.appState = appState
        
        // Observe pet changes
        appState.$activePetID
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.refreshData()
                }
            }.store(in: &cancellables)
        
        // Observe daily goals changes — this is what fires when user logs activity/meals/water
        appState.$dailyGoals
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.refreshData()
                }
            }.store(in: &cancellables)
        
        // Also observe analyticsHistory for snapshot updates
        appState.$analyticsHistory
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.refreshData()
                }
            }.store(in: &cancellables)
        
        // Initial load
        refreshData()
    }
    
    func refreshData() {
        guard let id = appState.activePetID else {
            consistencyScore = 0
            weeklyTrend = []
            streak = 0
            return
        }
        let goals = appState.dailyGoals[id] ?? []
        consistencyScore = AnalyticsEngine.calculateConsistencyScore(goals: goals)
        weeklyTrend = AnalyticsEngine.calculateWeeklyTrend(goals: goals)
        streak = AnalyticsEngine.calculateStreak(goals: goals)
        bestStreak = calculateBestStreak(goals: goals)
        objectWillChange.send()
    }
    
    private func calculateBestStreak(goals: [DailyGoal]) -> Int {
        let sorted = goals.sorted { $0.date < $1.date }
        var best = 0
        var current = 0
        for goal in sorted {
            if goal.activityProgress >= 0.8 && goal.hydrationProgress >= 0.8 && goal.calorieProgress >= 0.8 {
                current += 1
                best = max(best, current)
            } else {
                current = 0
            }
        }
        return best
    }
}
