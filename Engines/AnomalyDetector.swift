import Foundation

struct AnomalyAlert: Identifiable {
    var id: UUID = UUID()
    var title: String
    var detail: String
    var icon: String
    var severity: Severity

    enum Severity { case warning, critical }

    var color: String {
        switch severity {
        case .warning:  return "#FF8800"
        case .critical: return "#CC0000"
        }
    }
}

struct AnomalyDetector {

    /// Analyses recent DailyGoal history and returns any detected anomalies.
    static func detect(goals: [DailyGoal]) -> [AnomalyAlert] {
        guard goals.count >= 4 else { return [] }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Sort newest first
        let sorted = goals.sorted { $0.date > $1.date }

        // 7-day baseline (skip today)
        let baseline = sorted.filter {
            let d = calendar.startOfDay(for: $0.date)
            return d < today
        }.prefix(7)

        guard baseline.count >= 3 else { return [] }

        let avgActivity   = baseline.map(\.activityProgress).average
        let avgHydration  = baseline.map(\.hydrationProgress).average
        let avgCalorie    = baseline.map(\.calorieProgress).average

        // Recent 3 days (again skip today / use last 3 completed days)
        let recent3 = Array(baseline.prefix(3))
        let recentActivity  = recent3.map(\.activityProgress).average
        let recentHydration = recent3.map(\.hydrationProgress).average
        let recentCalorie   = recent3.map(\.calorieProgress).average

        var alerts: [AnomalyAlert] = []

        // Activity drop > 40%
        if avgActivity > 0.3 && recentActivity < avgActivity * 0.6 {
            let drop = Int((1 - recentActivity / max(avgActivity, 0.01)) * 100)
            alerts.append(AnomalyAlert(
                title: "Activity Drop Detected",
                detail: "Activity is \(drop)% below your pet's 7-day average. Could indicate fatigue or illness.",
                icon: "figure.walk.motion",
                severity: drop > 70 ? .critical : .warning
            ))
        }

        // Hydration dip > 35%
        if avgHydration > 0.3 && recentHydration < avgHydration * 0.65 {
            let drop = Int((1 - recentHydration / max(avgHydration, 0.01)) * 100)
            alerts.append(AnomalyAlert(
                title: "Hydration Dip",
                detail: "Water intake has dropped \(drop)% recently. Dehydration can be serious — check the water bowl.",
                icon: "drop.triangle.fill",
                severity: drop > 50 ? .critical : .warning
            ))
        }

        // Calorie drop > 40% (skipping meals)
        if avgCalorie > 0.3 && recentCalorie < avgCalorie * 0.6 {
            let drop = Int((1 - recentCalorie / max(avgCalorie, 0.01)) * 100)
            alerts.append(AnomalyAlert(
                title: "Meal Skipping Detected",
                detail: "Calorie intake is \(drop)% below normal. Reduced appetite can be an early illness indicator.",
                icon: "fork.knife.circle.fill",
                severity: drop > 60 ? .critical : .warning
            ))
        }

        // All-round wellness drop (all three below 50%)
        if recentActivity < 0.5 && recentHydration < 0.5 && recentCalorie < 0.5 {
            alerts.append(AnomalyAlert(
                title: "Overall Wellness Decline",
                detail: "Activity, hydration AND meals are all significantly below typical levels this week. Please consult your vet.",
                icon: "stethoscope",
                severity: .critical
            ))
        }

        return alerts
    }
}

// MARK: - Helpers

private extension Array where Element == Double {
    var average: Double {
        guard !isEmpty else { return 0 }
        return reduce(0, +) / Double(count)
    }
}
