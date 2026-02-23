import Foundation

struct AnalyticsSnapshot: Codable, Equatable {
    var date: Date
    var activityPercent: Double
    var hydrationPercent: Double
    var caloriePercent: Double
    var relaxationMinutes: Int
}

struct ChartDataPoint: Identifiable, Equatable {
    var id: UUID = UUID()
    var date: Date
    var activityPercent: Double
    var hydrationPercent: Double
    var caloriePercent: Double
}
