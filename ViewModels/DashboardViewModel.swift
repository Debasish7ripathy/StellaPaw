import Foundation
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    private var appState: AppState
    
    @Published var currentStreak: Int = 0
    @Published var todaysGoal: DailyGoal? = nil
    @Published var activePet: PetProfile? = nil
    @Published var consistencyScore: Int = 0
    @Published var weeklyTrend: [ChartDataPoint] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init(appState: AppState) {
        self.appState = appState
        
        // Use appState.activePetID directly — not a stale local copy
        appState.$activePetID
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in self?.refreshData() }
            }.store(in: &cancellables)
        
        appState.$dailyGoals
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in self?.refreshData() }
            }.store(in: &cancellables)
        
        appState.$pets
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in self?.refreshData() }
            }.store(in: &cancellables)
        
        // Initial load
        refreshData()
    }
    
    func refreshData() {
        guard let id = appState.activePetID else {
            activePet = nil
            todaysGoal = nil
            currentStreak = 0
            consistencyScore = 0
            weeklyTrend = []
            return
        }
        
        let goals = appState.dailyGoals[id] ?? []
        let today = Date()
        
        activePet = appState.pets.first { $0.id == id }
        todaysGoal = goals.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) })
        currentStreak = AnalyticsEngine.calculateStreak(goals: goals)
        consistencyScore = AnalyticsEngine.calculateConsistencyScore(goals: goals)
        weeklyTrend = AnalyticsEngine.calculateWeeklyTrend(goals: goals)
        objectWillChange.send()
    }
}
