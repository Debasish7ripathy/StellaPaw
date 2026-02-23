import SwiftUI
import Charts

struct ConsistencyScoreCard: View {
    var score: Int
    
    var color: Color {
        if score >= 80 { return Theme.success }
        if score >= 60 { return Theme.warning }
        return Theme.alert
    }
    
    var grade: String {
        if score >= 90 { return "Excellent" }
        if score >= 75 { return "Great" }
        if score >= 60 { return "Good" }
        if score >= 40 { return "Fair" }
        return "Needs Improvement"
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Consistency Score")
                .font(.headline)
            
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 20)
                
                Circle()
                    .trim(from: 0, to: CGFloat(MathCompat.clamp(score, 0, 100)) / 100.0)
                    .stroke(
                        color,
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.0, dampingFraction: 0.7), value: score)
                
                VStack {
                    Text("\(score)")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                    Text(grade)
                        .font(.title3.bold())
                        .foregroundColor(color)
                }
            }
            .frame(width: 250, height: 250)
            .padding()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Theme.cardBackground)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// Utility for compatibility
struct MathCompat {
    static func clamp(_ value: Int, _ min: Int, _ max: Int) -> Int {
        if value < min { return min }
        if value > max { return max }
        return value
    }
}

struct AnalyticsView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: AnalyticsViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let _ = appState.activePetID {
                        // Streak summary row
                        HStack(spacing: 12) {
                            StatBadge(label: "Current Streak", value: "🔥 \(viewModel.streak) days", color: Theme.activity)
                            StatBadge(label: "Best Streak", value: "⭐ \(viewModel.bestStreak) days", color: Theme.primary)
                            StatBadge(label: "Score", value: "\(viewModel.consistencyScore)%", color: Theme.success)
                        }
                        .padding(.horizontal)

                        // CoreML Prediction Card
                        if let pet = appState.activePet {
                            let history = appState.dailyGoals[pet.id] ?? []
                            let prediction = ActivityPredictionEngine.shared.predict(for: pet, history: history)
                            PredictionInsightCard(prediction: prediction)
                                .padding(.horizontal)
                        }

                        ConsistencyScoreCard(score: viewModel.consistencyScore)
                            .padding(.horizontal)

                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Metric Details")
                                .font(.title3.bold())
                            
                            Picker("Metric", selection: $viewModel.selectedMetric) {
                                ForEach(AnalyticsViewModel.MetricType.allCases, id: \.self) { metric in
                                    Text(metric.rawValue).tag(metric)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            Chart {
                                ForEach(viewModel.weeklyTrend) { data in
                                    let value: Double = {
                                        switch viewModel.selectedMetric {
                                        case .activity: return data.activityPercent
                                        case .hydration: return data.hydrationPercent
                                        case .calories: return data.caloriePercent
                                        }
                                    }() * 100.0
                                    
                                    let color: Color = {
                                        switch viewModel.selectedMetric {
                                        case .activity: return Theme.activity
                                        case .hydration: return Theme.hydration
                                        case .calories: return Theme.nutrition
                                        }
                                    }()
                                    
                                    LineMark(
                                        x: .value("Date", data.date, unit: .day),
                                        y: .value("Percentage", value)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(color)
                                    .lineStyle(StrokeStyle(lineWidth: 3))
                                    
                                    AreaMark(
                                        x: .value("Date", data.date, unit: .day),
                                        y: .value("Percentage", value)
                                    )
                                    .interpolationMethod(.catmullRom)
                                    .foregroundStyle(LinearGradient(colors: [color.opacity(0.3), .clear], startPoint: .top, endPoint: .bottom))
                                }
                            }
                            .chartYScale(domain: 0...120)
                            .frame(height: 250)
                            .padding(.top, 8)
                        }
                        .padding()
                        .background(Theme.cardBackground)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        // Insights Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Insights")
                                .font(.title3.bold())
                            
                            let recentActivity = viewModel.weeklyTrend.suffix(3).map(\.activityPercent).reduce(0, +) / 3.0
                            if recentActivity > 0.9 {
                                Text("🔥 Activity improving consistently this week!")
                            } else {
                                Text("💡 Try to squeeze in a slightly longer walk today.")
                            }
                            
                            let recentHydration = viewModel.weeklyTrend.suffix(3).map(\.hydrationPercent).reduce(0, +) / 3.0
                            if recentHydration < 0.8 {
                                Text("💧 Hydration dipped recently - ensure water bowl is fresh!")
                            } else {
                                Text("💧 Great job keeping hydration levels up.")
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.cardBackground)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                    } else {
                        Text("No active pet goal found.")
                            .foregroundColor(.secondary)
                            .padding(.top, 50)
                    }
                }
                .padding(.vertical)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Analytics")
            .onAppear { viewModel.refreshData() }
        }
    }
}

private struct StatBadge: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(14)
    }
}
