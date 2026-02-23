import SwiftUI

struct ConsistencyBadge: View {
    var score: Int
    
    var color: Color {
        if score >= 80 { return Theme.success }
        if score >= 60 { return Theme.warning }
        return Theme.alert
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
            Text("\(score)")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(
            LinearGradient(
                colors: [color, color.opacity(0.7)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        )
        .clipShape(Capsule())
        .shadow(color: color.opacity(0.4), radius: 6, x: 0, y: 3)
        .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
    }
}
