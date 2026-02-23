import SwiftUI
import Charts

struct ActivityView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: ActivityViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if let goal = appState.todaysGoalForActivePet {
                        
                        // Progress Header
                        VStack(spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Today's Progress")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    HStack(spacing: 4) {
                                        Text("\(String(format: "%.1f", goal.activityCompletedKM))")
                                            .font(.system(size: 28, weight: .bold, design: .rounded))
                                            .foregroundColor(.primary)
                                        Text("/ \(String(format: "%.1f", goal.activityTargetKM)) km")
                                            .font(.headline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                Spacer()
                                HStack(spacing: 6) {
                                    Text("🔥")
                                    Text("\(viewModel.streak) Day Streak")
                                        .font(.subheadline.bold())
                                }
                                .foregroundColor(Theme.activity)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(LinearGradient(colors: [Theme.activity.opacity(0.15), Theme.activity.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .clipShape(Capsule())
                                .overlay(Capsule().stroke(Theme.activity.opacity(0.2), lineWidth: 1))
                            }
                            
                            // Visual Progress Bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.gray.opacity(0.15)).frame(height: 12)
                                    Capsule()
                                        .fill(LinearGradient(colors: [Theme.activity, Color(hex: "#00C896")], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: min(geo.size.width * CGFloat(goal.activityProgress), geo.size.width), height: 12)
                                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: goal.activityProgress)
                                        .shadow(color: Theme.activity.opacity(0.4), radius: 6, x: 0, y: 2)
                                }
                            }.frame(height: 12)
                        }
                        .padding(20)
                        .background(
                            ZStack {
                                Theme.cardBackground
                                LinearGradient(colors: [Theme.activity.opacity(0.05), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
                            }
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.primary.opacity(0.03), lineWidth: 1))
                        .padding(.horizontal)
                        
                        // Activity Type Picker
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Activity Type")
                                .font(.headline)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 12)], spacing: 12) {
                                ForEach(ActivityType.allCases, id: \.self) { type in
                                    Button(action: {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            viewModel.selectedActivity = type
                                        }
                                    }) {
                                        VStack(spacing: 8) {
                                            ZStack {
                                                Circle()
                                                    .fill(viewModel.selectedActivity == type ? .white.opacity(0.2) : Theme.activity.opacity(0.1))
                                                    .frame(width: 40, height: 40)
                                                Image(systemName: type.icon)
                                                    .font(.title3.weight(.semibold))
                                                    .foregroundColor(viewModel.selectedActivity == type ? .white : Theme.activity)
                                            }
                                            Text(type.display)
                                                .font(.caption.bold())
                                                .foregroundColor(viewModel.selectedActivity == type ? .white : .primary)
                                                .multilineTextAlignment(.center)
                                                .lineLimit(2)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(
                                            viewModel.selectedActivity == type
                                            ? AnyShapeStyle(LinearGradient(colors: [Theme.activity, Color(hex: "#00C896")], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            : AnyShapeStyle(Theme.cardBackground)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 18))
                                        .shadow(color: viewModel.selectedActivity == type ? Theme.activity.opacity(0.4) : .black.opacity(0.03), radius: 6, x: 0, y: 3)
                                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(viewModel.selectedActivity == type ? Color.clear : Color.primary.opacity(0.04), lineWidth: 1))
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.secondary.opacity(0.03))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal)
                        
                        // Log Mode + Input
                        VStack(alignment: .leading, spacing: 20) {
                            Toggle(isOn: $viewModel.useDistanceMode) {
                                HStack(spacing: 8) {
                                    ZStack {
                                        Circle().fill(Theme.activity.opacity(0.1)).frame(width: 32, height: 32)
                                        Image(systemName: viewModel.useDistanceMode ? "ruler" : "timer")
                                            .font(.caption.bold())
                                            .foregroundColor(Theme.activity)
                                    }
                                    Text(viewModel.useDistanceMode ? "Enter Distance Mode" : "Enter Duration Mode")
                                        .font(.subheadline.bold())
                                }
                            }
                            .tint(Theme.activity)
                            
                            if viewModel.useDistanceMode {
                                VStack(spacing: 12) {
                                    Text("\(String(format: "%.1f", viewModel.loggedDistance))")
                                        .font(.system(size: 64, weight: .bold, design: .rounded))
                                        .foregroundColor(Theme.activity)
                                    + Text(" km").font(.title2.bold()).foregroundColor(.secondary)
                                    
                                    Slider(value: $viewModel.loggedDistance, in: 0...(goal.activityTargetKM * 2), step: 0.1)
                                        .tint(Theme.activity)
                                        .padding(.horizontal, 10)
                                }
                            } else {
                                VStack(spacing: 12) {
                                    Text("\(viewModel.durationMinutes)")
                                        .font(.system(size: 64, weight: .bold, design: .rounded))
                                        .foregroundColor(Theme.activity)
                                    + Text(" min").font(.title2.bold()).foregroundColor(.secondary)
                                    
                                    Stepper("Duration", value: $viewModel.durationMinutes, in: 1...180)
                                        .labelsHidden()
                                        .padding(.horizontal, 20)
                                    
                                    Text("≈ \(String(format: "%.2f", viewModel.estimatedDistance)) km (\(viewModel.selectedActivity.display))")
                                        .font(.caption.bold())
                                        .padding(.horizontal, 12).padding(.vertical, 6)
                                        .background(Theme.activity.opacity(0.1))
                                        .foregroundColor(Theme.activity)
                                        .clipShape(Capsule())
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            Button(action: {
                                withAnimation {
                                    viewModel.logActivity()
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Log \(viewModel.selectedActivity.display)")
                                }
                                .font(.headline.bold())
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    viewModel.estimatedDistance > 0
                                    ? AnyShapeStyle(LinearGradient(colors: [Theme.activity, Color(hex: "#00C896")], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    : AnyShapeStyle(Color.gray.opacity(0.5))
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .shadow(color: viewModel.estimatedDistance > 0 ? Theme.activity.opacity(0.4) : .clear, radius: 6, x: 0, y: 3)
                            }
                            .disabled(viewModel.estimatedDistance <= 0)
                        }
                        .padding(20)
                        .background(Theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.primary.opacity(0.03), lineWidth: 1))
                        .padding(.horizontal)
                        
                        // Today's Activity Log
                        if !viewModel.todaysActivityLog.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Today's Activities")
                                    .font(.title3.bold())
                                    .padding(.horizontal)
                                
                                ForEach(viewModel.todaysActivityLog.reversed()) { entry in
                                    HStack(spacing: 14) {
                                        ZStack {
                                            Circle()
                                                .fill(Theme.activity.opacity(0.1))
                                                .frame(width: 44, height: 44)
                                            Image(systemName: entry.type.icon)
                                                .foregroundColor(Theme.activity)
                                                .font(.headline)
                                        }
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(entry.type.display)
                                                .font(.headline)
                                            if entry.durationMinutes > 0 {
                                                Text("\(entry.durationMinutes) min")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        Spacer()
                                        HStack(spacing: 4) {
                                            Text("+\(String(format: "%.2f", entry.distanceKM))")
                                                .font(.subheadline.bold())
                                                .foregroundColor(Theme.activity)
                                            Text("km")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()
                                    .background(Theme.cardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                    .shadow(color: .black.opacity(0.02), radius: 4, x: 0, y: 2)
                                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.primary.opacity(0.04), lineWidth: 1))
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // 7-Day Chart
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("7-Day Trend")
                                    .font(.title3.bold())
                                Spacer()
                                ZStack {
                                    Circle().fill(Theme.activity.opacity(0.1)).frame(width: 32, height: 32)
                                    Image(systemName: "chart.bar.fill")
                                        .font(.caption.bold())
                                        .foregroundColor(Theme.activity)
                                }
                            }
                            
                            Chart {
                                ForEach(viewModel.trendData) { data in
                                    BarMark(
                                        x: .value("Date", data.date, unit: .day),
                                        y: .value("Progress", data.activityPercent * 100)
                                    )
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: data.activityPercent >= 1.0 ? [Theme.success, Color(hex: "#34D399")] : [Theme.activity, Color(hex: "#00C896")],
                                            startPoint: .bottom, endPoint: .top
                                        )
                                    )
                                    .cornerRadius(6)
                                    
                                    RuleMark(y: .value("Target", 100))
                                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [4, 4]))
                                        .foregroundStyle(Color.secondary.opacity(0.4))
                                }
                            }
                            .chartYScale(domain: .automatic)
                            .chartXAxis { AxisMarks(values: .stride(by: .day)) { _ in AxisValueLabel(format: .dateTime.weekday(.narrow)) } }
                            .frame(height: 200)
                        }
                        .padding(20)
                        .background(Theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
                        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.primary.opacity(0.03), lineWidth: 1))
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
            .navigationTitle("Activity")
        }
    }
}
