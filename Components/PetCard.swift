import SwiftUI

struct PetCard: View {
    var pet: PetProfile
    var isActive: Bool
    
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Animated Gradient Border for active state
                if isActive {
                    Circle()
                        .fill(
                            AngularGradient(
                                colors: [Theme.primary, Color(hex: "#8B5CF6"), Theme.primary, Color(hex: "#F472B6"), Theme.primary],
                                center: .center,
                                angle: .degrees(rotation)
                            )
                        )
                        .frame(width: 76, height: 76)
                        .blur(radius: 2)
                        .onAppear {
                            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                                rotation = 360
                            }
                        }
                    
                    // Inner mask to create a ring
                    Circle()
                        .fill(Theme.cardBackground)
                        .frame(width: 70, height: 70)
                }
                
                // Outer subtle ring for inactive state
                if !isActive {
                    Circle()
                        .stroke(Color.primary.opacity(0.08), lineWidth: 2)
                        .frame(width: 70, height: 70)
                }
                
                // Profile Image or Initial
                Group {
                    if let data = pet.profileImageData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ZStack {
                            LinearGradient(
                                colors: isActive ? [Theme.primary.opacity(0.8), Theme.primary] : [Color.gray.opacity(0.1), Color.gray.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            Text(String(pet.name.prefix(1)).uppercased())
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(isActive ? .white : .primary.opacity(0.5))
                        }
                    }
                }
                .frame(width: 64, height: 64)
                .clipShape(Circle())
                
                // Selection shadow
                if isActive {
                    Circle()
                        .stroke(Color.white.opacity(0.8), lineWidth: 2)
                        .frame(width: 64, height: 64)
                }
            }
            .shadow(color: isActive ? Theme.primary.opacity(0.3) : .clear, radius: 10, x: 0, y: 5)
            
            Text(pet.name)
                .font(.system(size: 14, weight: isActive ? .bold : .medium, design: .rounded))
                .foregroundColor(isActive ? .primary : .secondary)
        }
        .scaleEffect(isActive ? 1.05 : 0.95)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isActive)
        .padding(.vertical, 4)
    }
}
