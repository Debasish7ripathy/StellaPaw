import SwiftUI

struct HydrationWidget: View {
    var waterConsumed: Double
    var waterTarget: Double
    var onAdd: () -> Void
    
    var progress: Double {
        guard waterTarget > 0 else { return 0 }
        return min(waterConsumed / waterTarget, 1.0)
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Hydration")
                    .font(.system(.headline, design: .rounded).bold())
                Spacer()
                Button(action: onAdd) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(Theme.hydration)
                        .font(.title3)
                }
            }
            .padding([.horizontal, .top])
            
            ZStack(alignment: .bottom) {
                // Drop shape representation using a custom shape or standard Capsule
                Capsule()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 60, height: 100)
                
                Capsule()
                    .fill(LinearGradient(colors: [Theme.hydration.opacity(0.6), Theme.hydration], startPoint: .top, endPoint: .bottom))
                    .frame(width: 60, height: 100 * CGFloat(progress))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
            }
            .padding(.vertical, 8)
            
            Text("\(Int(waterConsumed)) / \(Int(waterTarget)) mL")
                .font(.system(.subheadline, design: .rounded).monospacedDigit())
                .padding(.bottom)
        }
        .background(Theme.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
