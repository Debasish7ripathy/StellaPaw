import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var appState: AppState
    @State private var showingAddPetSheet = false
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "pawprint.fill")
                .font(.system(size: 80))
                .foregroundColor(Theme.primary)
            
            VStack(spacing: 8) {
                Text("Welcome to StellaPaw")
                    .font(.system(.largeTitle, design: .rounded).bold())
                
                Text("Preventive Pet Wellness, Thoughtfully Designed.")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
            
            Button {
                showingAddPetSheet = true
            } label: {
                Text("Add Your First Pet")
                    .font(.system(.title3, design: .rounded).bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 48)
        }
        .background(Theme.background.ignoresSafeArea())
        .sheet(isPresented: $showingAddPetSheet, onDismiss: {
            if !appState.pets.isEmpty {
                appState.isOnboardingComplete = true
            }
        }) {
            AddPetSheet(isFirstPet: true)
                .environmentObject(appState)
        }
    }
}
