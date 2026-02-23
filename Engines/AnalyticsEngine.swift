import Foundation

struct AnalyticsEngine {
    
    /// Returns exactly 7 ChartDataPoints for the past 7 days.
    /// Days with no recorded goal are filled with zero progress.
    static func calculateWeeklyTrend(goals: [DailyGoal]) -> [ChartDataPoint] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return (0..<7).reversed().map { daysAgo -> ChartDataPoint in
            let day = calendar.date(byAdding: .day, value: -daysAgo, to: today)!
            
            // Find a goal recorded on this day
            let match = goals.first(where: {
                calendar.isDate($0.date, inSameDayAs: day)
            })
            
            return ChartDataPoint(
                date: day,
                activityPercent: min(match?.activityProgress ?? 0.0, 1.0),
                hydrationPercent: min(match?.hydrationProgress ?? 0.0, 1.0),
                caloriePercent: min(match?.calorieProgress ?? 0.0, 1.0)
            )
        }
    }
    
    static func calculateConsistencyScore(goals: [DailyGoal]) -> Int {
        guard !goals.isEmpty else { return 0 }
        let sumScore = goals.reduce(0.0) { sum, goal in
            let activity = min(goal.activityProgress, 1.0)
            let hydration = min(goal.hydrationProgress, 1.0)
            let calorie = min(goal.calorieProgress, 1.0)
            let avg = (activity + hydration + calorie) / 3.0
            return sum + avg
        }
        let avgAcrossAll = sumScore / Double(goals.count)
        return Int(avgAcrossAll * 100)
    }
    
    static func calculateStreak(goals: [DailyGoal]) -> Int {
        let calendar = Calendar.current
        let sortedDesc = goals.sorted(by: { $0.date > $1.date })
        var streak = 0
        var expectedDate = calendar.startOfDay(for: Date())
        
        for goal in sortedDesc {
            let goalDay = calendar.startOfDay(for: goal.date)
            guard goalDay == expectedDate else { break }
            
            if goal.activityProgress >= 0.8 && goal.hydrationProgress >= 0.8 && goal.calorieProgress >= 0.8 {
                streak += 1
                expectedDate = calendar.date(byAdding: .day, value: -1, to: expectedDate)!
            } else {
                break
            }
        }
        return streak
    }
}
