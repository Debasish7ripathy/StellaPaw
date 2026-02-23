import SwiftUI

struct BreathingCircle: View {
    @State private var isBreathingIn = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Theme.calm.opacity(isBreathingIn ? 0.2 : 0.5))
                .scaleEffect(isBreathingIn ? 1.3 : 1.0)
            
            Text(isBreathingIn ? "Breathe In" : "Breathe Out")
                .font(.system(.title, design: .rounded).bold())
                .foregroundColor(.white)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
                isBreathingIn.toggle()
            }
        }
    }
}
