import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: DashboardViewModel
    @EnvironmentObject var nutritionViewModel: NutritionViewModel
    @State private var dismissedAnomalyIDs: Set<UUID> = []
    
    private var anomalies: [AnomalyAlert] {
        guard let petID = appState.activePetID,
              let goals = appState.dailyGoals[petID] else { return [] }
        return AnomalyDetector.detect(goals: goals)
            .filter { !dismissedAnomalyIDs.contains($0.id) }
    }
    
    private var nextAppointment: VetAppointment? {
        guard let petID = appState.activePetID else { return nil }
        return (appState.appointments[petID] ?? [])
            .filter { $0.isUpcoming }
            .sorted { $0.date < $1.date }
            .first
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    petSwitcher
                    
                    if let activePet = viewModel.activePet, let goal = viewModel.todaysGoal {
                        greetingHeader(activePet: activePet)
                        
                        // Upcoming appointment banner
                        if let appt = nextAppointment {
                            HStack(spacing: 12) {
                                Image(systemName: "stethoscope")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color(hex: appt.countdownColor))
                                    .clipShape(Circle())
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(appt.title).font(.subheadline.bold()).foregroundColor(.primary)
                                    Text("\(appt.vetName) · \(appt.countdownText)").font(.caption).foregroundColor(.secondary)
                                }
                                Spacer()
                                Button { appState.selectedTab = .records } label: {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding()
                            .background(Color(hex: appt.countdownColor).opacity(0.08))
                            .cornerRadius(14)
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color(hex: appt.countdownColor).opacity(0.3), lineWidth: 1))
                            .padding(.horizontal)
                        }
                        
                        // Anomaly alerts
                        if !anomalies.isEmpty {
                            VStack(spacing: 8) {
                                ForEach(anomalies.prefix(2)) { alert in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack(spacing: 12) {
                                            Image(systemName: alert.icon)
                                                .font(.title3)
                                                .foregroundColor(Color(hex: alert.color))
                                                .padding(10)
                                                .background(Color(hex: alert.color).opacity(0.1))
                                                .clipShape(Circle())
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(alert.title).font(.subheadline.bold())
                                                Text(alert.detail).font(.caption).foregroundColor(.secondary).lineLimit(2)
                                            }
                                            Spacer()
                                            Button { dismissedAnomalyIDs.insert(alert.id) } label: {
                                                Image(systemName: "xmark").font(.caption2).foregroundColor(.secondary)
                                            }
                                        }
                                        // Ask AI button
                                        Button {
                                            appState.selectedTab = .ai
                                        } label: {
                                            Label("Ask Petora AI", systemImage: "sparkles")
                                                .font(.caption.bold())
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 14).padding(.vertical, 8)
                                                .background(
                                                    LinearGradient(colors: [Color(hex: alert.color), Color(hex: alert.color).opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                                )
                                                .clipShape(Capsule())
                                                .shadow(color: Color(hex: alert.color).opacity(0.4), radius: 4, x: 0, y: 2)
                                        }
                                    }
                                    .padding(18)
                                    .background(
                                        ZStack {
                                            Theme.cardBackground
                                            LinearGradient(colors: [Color(hex: alert.color).opacity(0.1), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        }
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 24))
                                    .shadow(color: Color(hex: alert.color).opacity(0.08), radius: 12, x: 0, y: 6)
                                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color(hex: alert.color).opacity(0.2), lineWidth: 1))
                                }
                            }
                            .padding(.horizontal)


                        }
                        
                        // Bento Grid constructed with VStacks and HStacks for spanning
                        VStack(spacing: 16) {
                            activityWidget(goal: goal)
                            
                            HStack(spacing: 16) {
                                HydrationWidget(waterConsumed: goal.waterConsumedML, waterTarget: goal.waterTargetML) {
                                    appState.updateHydration(amount: 250) // Quick log 250ml
                                }
                                
                                nextMealWidget
                            }
                            
                            calmModeWidget(goal: goal)
                            
                            weeklyChartWidget
                        }
                        .padding(.horizontal)
                        
                    } else {
                        Text("No active pet. Add one to get started!")
                            .foregroundColor(.secondary)
                            .padding(.top, 50)
                    }
                }
                .padding(.vertical)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("StellaPaw")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var petSwitcher: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(appState.pets) { pet in
                    PetCard(pet: pet, isActive: pet.id == appState.activePetID)
                        .onTapGesture {
                            withAnimation { appState.switchActivePet(to: pet.id) }
                        }
                }
                
                Button(action: { appState.showingAddPetSheet = true }) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 64, height: 64)
                                .shadow(color: .black.opacity(0.04), radius: 4)
                            Image(systemName: "plus")
                                .font(.title3.bold())
                                .foregroundColor(Theme.primary)
                        }
                        
                        Text("Add")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .padding(.leading, 4)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                Capsule()
                    .fill(Theme.cardBackground.opacity(0.5))
                    .shadow(color: .black.opacity(0.02), radius: 10, y: 5)
            )
            .padding(.horizontal)
        }
    }
    
    private func greetingHeader(activePet: PetProfile) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello, \(activePet.name)!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                Text("Day \(viewModel.currentStreak) Streak 🔥")
                    .font(.subheadline.bold())
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(LinearGradient(colors: [.orange.opacity(0.2), .red.opacity(0.1)], startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.orange)
                    .clipShape(Capsule())
            }
            Spacer()
            ConsistencyBadge(score: viewModel.consistencyScore)
        }
        .padding(.horizontal)
    }

    
    private func activityWidget(goal: DailyGoal) -> some View {
        VStack {
            HStack {
                Text("Activity")
                    .font(.headline)
                Spacer()
                Image(systemName: "figure.walk.circle.fill")
                    .font(.title2)
                    .foregroundColor(Theme.activity)
            }
            
            HStack(spacing: 32) {
                ZStack {
                    ProgressRing(progress: goal.activityProgress, color: Theme.activity)
                        .frame(width: 100, height: 100)
                        .shadow(color: Theme.activity.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    VStack(spacing: 0) {
                        Text(String(format: "%.1f", goal.activityCompletedKM))
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        Text("/ \(String(format: "%.1f", goal.activityTargetKM)) km")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Button(action: { appState.selectedTab = .activity }) {
                    HStack(spacing: 6) {
                        Text("Log Walk")
                            .font(.subheadline.bold())
                        Image(systemName: "arrow.right")
                            .font(.caption.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [Theme.activity.opacity(0.15), Theme.activity.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .foregroundColor(Theme.activity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.activity.opacity(0.2), lineWidth: 1))
                }
            }
        }
        .padding(20)
        .frame(height: 190)
        .background(
            ZStack {
                Theme.cardBackground
                LinearGradient(colors: [Theme.activity.opacity(0.05), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.primary.opacity(0.03), lineWidth: 1))
    }

    
    private var nextMealWidget: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Next Meal")
                    .font(.headline)
                Spacer()
                ZStack {
                    Circle().fill(Theme.nutrition.opacity(0.15)).frame(width: 32, height: 32)
                    Image(systemName: "fork.knife")
                        .font(.caption.bold())
                        .foregroundColor(Theme.nutrition)
                }
            }
            Spacer(minLength: 12)
            if let meal = nutritionViewModel.recommendedMeal {
                VStack(alignment: .leading, spacing: 6) {
                    Text(meal.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(alignment: .center, spacing: 6) {
                        Text("\(meal.calories) kcal")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.nutrition)
                        
                        Text("•")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary.opacity(0.5))
                        
                        Text(meal.category.display)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                        
                        Spacer(minLength: 0)
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.secondary.opacity(0.7))
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tap to view recommendations")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                    HStack {
                        Text("View plan")
                            .font(.caption.bold())
                            .foregroundColor(Theme.nutrition)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.nutrition.opacity(0.7))
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ZStack {
                Theme.cardBackground
                LinearGradient(colors: [Theme.nutrition.opacity(0.08), .clear], startPoint: .topTrailing, endPoint: .bottomLeading)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.primary.opacity(0.03), lineWidth: 1))
        .onTapGesture {
            appState.selectedTab = .nutrition
        }
    }

    
    private func calmModeWidget(goal: DailyGoal) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "moon.stars.fill")
                        .font(.headline)
                        .foregroundColor(Theme.calm)
                        .symbolEffect(.pulse, options: .repeating)
                    Text("Calm Mode")
                        .font(.headline)
                }
                Text("\(goal.relaxationMinutes) mins today")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.secondary)
            }
            Spacer()
            Button(action: { appState.showingCalmMode = true }) {
                Text("Start")
                    .font(.subheadline.bold())
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(colors: [Theme.calm, Color(hex: "#4F46E5")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .shadow(color: Theme.calm.opacity(0.4), radius: 6, x: 0, y: 3)
            }
        }
        .padding(20)
        .background(
            ZStack {
                Theme.cardBackground
                LinearGradient(colors: [Theme.calm.opacity(0.08), .clear], startPoint: .leading, endPoint: .trailing)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.primary.opacity(0.03), lineWidth: 1))
    }

    
    private var weeklyChartWidget: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Weekly Trend")
                    .font(.headline)
                Spacer()
                ZStack {
                    Circle().fill(Theme.primary.opacity(0.1)).frame(width: 32, height: 32)
                    Image(systemName: "chart.xyaxis.line")
                        .font(.caption.bold())
                        .foregroundColor(Theme.primary)
                }
            }
            .padding(.bottom, 8)
            
            Chart {
                ForEach(viewModel.weeklyTrend) { data in
                    LineMark(
                        x: .value("Date", data.date, unit: .day),
                        y: .value("Score", (data.activityPercent + data.hydrationPercent + data.caloriePercent) / 3.0 * 100)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(colors: [Theme.primary, Color(hex: "#2563EB")], startPoint: .leading, endPoint: .trailing)
                    )
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    
                    AreaMark(
                        x: .value("Date", data.date, unit: .day),
                        y: .value("Score", (data.activityPercent + data.hydrationPercent + data.caloriePercent) / 3.0 * 100)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(LinearGradient(colors: [Theme.primary.opacity(0.2), .clear], startPoint: .top, endPoint: .bottom))
                }
            }
            .chartYScale(domain: .automatic)
            .chartXAxis { AxisMarks(values: .stride(by: .day)) { _ in AxisValueLabel(format: .dateTime.weekday(.narrow)) } }
            .frame(height: 150)
        }
        .padding(20)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.primary.opacity(0.03), lineWidth: 1))
        .onTapGesture {
            appState.selectedTab = .analytics
        }
    }

}
