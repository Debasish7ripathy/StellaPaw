import SwiftUI

struct MealCard: View {
    var meal: FoodItem
    @Binding var showingInsight: Bool
    var onReRoll: () -> Void
    var onComplete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(meal.name)
                    .font(.system(.title3, design: .rounded).bold())
                Spacer()
                Text("\(meal.calories) kcal")
                    .font(.caption.bold())
                    .padding(6)
                    .background(Theme.nutrition.opacity(0.2))
                    .foregroundColor(Theme.nutrition)
                    .cornerRadius(8)
            }
            
            HStack(spacing: 16) {
                Label("\(String(format: "%.1f", meal.protein))g P", systemImage: "figure.walk")
                Label("\(String(format: "%.1f", meal.fat))g F", systemImage: "drop.fill")
                Label("\(String(format: "%.1f", meal.fiber))g Fib", systemImage: "leaf.fill")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Button(action: {
                withAnimation { showingInsight.toggle() }
            }) {
                HStack {
                    Text("Why This Meal?")
                        .font(.system(.subheadline, design: .rounded).bold())
                    Spacer()
                    Image(systemName: showingInsight ? "chevron.up" : "chevron.down")
                }
                .foregroundColor(Theme.primary)
            }
            
            if showingInsight {
                Text(meal.healthBenefitDescription)
                    .font(.callout)
                    .padding()
                    .background(Color.primary.opacity(0.05))
                    .cornerRadius(8)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            HStack {
                Button(action: onReRoll) {
                    Text("Re-roll")
                        .font(.system(.body, design: .rounded).bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primary.opacity(0.05))
                        .cornerRadius(12)
                }
                
                Button(action: onComplete) {
                    Text("Mark Complete")
                        .font(.system(.body, design: .rounded).bold())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Theme.success)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
