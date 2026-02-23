import SwiftUI

struct NutritionView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: NutritionViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // Pet species badge
                    if let pet = appState.activePet {
                        HStack(spacing: 8) {
                            Text(pet.species.icon)
                                .font(.title2)
                            Text("\(pet.name)'s \(pet.species.display) Menu")
                                .font(.headline)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 4)
                    }

                    // Meal type picker
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(MealType.allCases, id: \.self) { type in
                                Button(action: {
                                    withAnimation(.spring(response: 0.3)) { viewModel.currentMealType = type }
                                }) {
                                    Text(type.display)
                                        .font(.subheadline.bold())
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(
                                            viewModel.currentMealType == type
                                            ? AnyShapeStyle(LinearGradient(colors: [Theme.nutrition, Color(hex: "#10B981")], startPoint: .topLeading, endPoint: .bottomTrailing))
                                            : AnyShapeStyle(Color.gray.opacity(0.1))
                                        )
                                        .foregroundColor(viewModel.currentMealType == type ? .white : .primary)
                                        .clipShape(Capsule())
                                        .shadow(color: viewModel.currentMealType == type ? Theme.nutrition.opacity(0.4) : .clear, radius: 4, x: 0, y: 2)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // Calorie progress
                    if let goal = appState.todaysGoalForActivePet {
                        CalorieSummaryCard(goal: goal)
                            .padding(.horizontal)
                    }

                    // Food list for this pet + meal type
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Available Options")
                                .font(.title3.bold())
                            Spacer()
                            Text("\(viewModel.foodList.count) items")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)

                        if viewModel.foodList.isEmpty {
                            Text("No meals found for this type. Try another meal slot.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        } else {
                            ForEach(viewModel.foodList) { item in
                                FoodListCard(
                                    item: item,
                                    isLogged: appState.todaysGoalForActivePet?.mealsCompleted.contains(item) == true,
                                    onLog: { viewModel.logFood(item) }
                                )
                                .padding(.horizontal)
                            }
                        }
                    }

                    // Today's logged meals
                    if let meals = appState.todaysGoalForActivePet?.mealsCompleted, !meals.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Today's Logged Meals")
                                .font(.title3.bold())
                                .padding(.horizontal)
                            ForEach(meals, id: \.self) { meal in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(meal.name).font(.headline)
                                        Text(meal.category.display)
                                            .font(.caption).foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    HStack(spacing: 6) {
                                        Text("+\(meal.calories)")
                                            .font(.subheadline.bold())
                                            .foregroundColor(Theme.nutrition)
                                        Text("kcal")
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
                }
                .padding(.vertical)
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("Nutrition")
        }
    }
}

// MARK: - Calorie Summary Card

private struct CalorieSummaryCard: View {
    let goal: DailyGoal
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Calories")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Text("\(goal.caloriesConsumed)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        Text("/ \(goal.caloriesTarget) kcal")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if goal.caloriesConsumed >= goal.caloriesTarget {
                        Label("Met", systemImage: "checkmark.circle.fill")
                            .font(.caption.bold())
                            .foregroundColor(Theme.success)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Theme.success.opacity(0.15))
                            .clipShape(Capsule())
                    } else {
                        Text("\(goal.caloriesTarget - goal.caloriesConsumed) kcal left")
                            .font(.caption.bold())
                            .foregroundColor(Theme.nutrition)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Theme.nutrition.opacity(0.15))
                            .clipShape(Capsule())
                    }
                }
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.gray.opacity(0.15)).frame(height: 12)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: goal.caloriesConsumed > goal.caloriesTarget ? [Theme.alert, Color.red] : [Theme.nutrition, Color(hex: "#10B981")],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .frame(width: min(geo.size.width * CGFloat(goal.calorieProgress), geo.size.width), height: 12)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: goal.calorieProgress)
                        .shadow(color: (goal.caloriesConsumed > goal.caloriesTarget ? Theme.alert : Theme.nutrition).opacity(0.4), radius: 6, x: 0, y: 2)
                }
            }.frame(height: 12)
        }
        .padding(20)
        .background(
            ZStack {
                Theme.cardBackground
                LinearGradient(colors: [Theme.nutrition.opacity(0.05), .clear], startPoint: .topLeading, endPoint: .bottomTrailing)
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color.primary.opacity(0.03), lineWidth: 1))
    }
}

// MARK: - Food List Card

private struct FoodListCard: View {
    let item: FoodItem
    let isLogged: Bool
    let onLog: () -> Void

    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main row
            HStack(spacing: 12) {
                // Calorie badge
                VStack(spacing: 2) {
                    Text("\(item.calories)")
                        .font(.title3.bold())
                        .foregroundColor(Theme.nutrition)
                    Text("kcal")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(width: 48)
                .padding(.vertical, 8)
                .background(Theme.nutrition.opacity(0.08))
                .cornerRadius(10)

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.name).font(.headline).lineLimit(1)
                    HStack(spacing: 8) {
                        NutrientPill(label: "P", value: item.protein, color: .blue)
                        NutrientPill(label: "F", value: item.fat, color: .orange)
                        NutrientPill(label: "Fi", value: item.fiber, color: .green)
                    }
                }

                Spacer()

                // Log / Logged button
                Button(action: { if !isLogged { onLog() } }) {
                    ZStack {
                        if isLogged {
                            Circle()
                                .fill(LinearGradient(colors: [Theme.success, Color(hex: "#34D399")], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 32, height: 32)
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Circle()
                                .fill(Theme.nutrition.opacity(0.1))
                                .frame(width: 32, height: 32)
                            Image(systemName: "plus")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(Theme.nutrition)
                        }
                    }
                }
                .disabled(isLogged)
                .scaleEffect(isLogged ? 1.05 : 1.0)
                .animation(.spring(), value: isLogged)

                // Expand arrow
                Button(action: { withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { expanded.toggle() } }) {
                    Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                        .frame(width: 24, height: 24)
                        .background(Color.gray.opacity(0.08))
                        .clipShape(Circle())
                }
            }
            .padding()

            // Expanded details
            if expanded {
                Divider().padding(.horizontal)
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.healthBenefitDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Ingredients: \(item.ingredients.joined(separator: ", "))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding([.horizontal, .bottom])
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isLogged ? Theme.success.opacity(0.5) : Color.primary.opacity(0.05), lineWidth: isLogged ? 2 : 1)
        )

    }
}

private struct NutrientPill: View {
    let label: String
    let value: Double
    let color: Color
    var body: some View {
        HStack(spacing: 2) {
            Text(label).font(.caption2.bold()).foregroundColor(color)
            Text(String(format: "%.1fg", value)).font(.caption2).foregroundColor(.secondary)
        }
        .padding(.horizontal, 5).padding(.vertical, 2)
        .background(color.opacity(0.08))
        .cornerRadius(6)
    }
}

// MARK: - Compat extension
extension Binding where Value == Bool {
    var not: Binding<Value> {
        Binding<Value>(get: { !self.wrappedValue }, set: { self.wrappedValue = !$0 })
    }
}
