import Foundation
import Combine

@MainActor
class ActivityViewModel: ObservableObject {
    private var appState: AppState
    
    @Published var selectedActivity: ActivityType = .walk
    @Published var durationMinutes: Int = 15
    @Published var loggedDistance: Double = 0.0
    @Published var useDistanceMode: Bool = false
    
    @Published var streak: Int = 0
    @Published var trendData: [ChartDataPoint] = []
    @Published var todaysActivityLog: [ActivityEntry] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init(appState: AppState) {
        self.appState = appState
        
        appState.$activePetID.sink { [weak self] _ in
            DispatchQueue.main.async { self?.refreshData() }
        }.store(in: &cancellables)
        
        appState.$dailyGoals.sink { [weak self] _ in
            DispatchQueue.main.async { self?.refreshData() }
        }.store(in: &cancellables)
    }
    
    func refreshData() {
        guard let id = appState.activePetID else { return }
        let goals = appState.dailyGoals[id] ?? []
        streak = AnalyticsEngine.calculateStreak(goals: goals)
        trendData = AnalyticsEngine.calculateWeeklyTrend(goals: goals)
        todaysActivityLog = appState.todaysGoalForActivePet?.activityLog ?? []
    }
    
    /// Computed distance based on selected activity type and duration
    var estimatedDistance: Double {
        if useDistanceMode {
            return loggedDistance
        }
        return selectedActivity.kmPerMinute * Double(durationMinutes)
    }
    
    func logActivity() {
        let dist = estimatedDistance
        guard dist > 0 else { return }
        let entry = ActivityEntry(
            type: selectedActivity,
            durationMinutes: useDistanceMode ? 0 : durationMinutes,
            distanceKM: dist,
            date: Date()
        )
        appState.logActivity(entry: entry)
        // Reset
        durationMinutes = 15
        loggedDistance = 0.0
    }
}
