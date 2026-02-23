import SwiftUI

struct SoundsView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var audioManager = AudioManager.shared
    @Environment(\.dismiss) var dismiss
    
    var isFullScreen: Bool = false
    @State private var selectedSound: CalmSound = .rain
    @State private var selectedDuration: Double = 10
    @State private var showingInfo = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Theme.calm.opacity(0.8), Theme.calm.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            VStack {
                // Header
                HStack {
                    if isFullScreen {
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.title2.bold())
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                    } else {
                        Text("Calm Mode")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: { showingInfo = true }) {
                        Image(systemName: "info.circle")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                Spacer()
                
                if audioManager.isPlaying {
                    BreathingCircle()
                        .frame(width: 250, height: 250)
                    
                    Spacer()
                    
                    Text(timeString(from: audioManager.remainingTime))
                        .font(.system(size: 48, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        audioManager.stopSound()
                        // In an actual scenario we should log it immediately, but for UI simplicity we log in onReceive or here.
                        if let sound = audioManager.currentTrack {
                            appState.completeCalmSession(duration: selectedDuration * 60 - audioManager.remainingTime, completedFully: false, sound: sound)
                        }
                    }) {
                        Text("Stop Session")
                            .font(.title3.bold())
                            .foregroundColor(Theme.calm)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
                    
                } else {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                        .padding(.bottom, 8)
                    
                    Text("Choose a calming sound")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(CalmSound.allCases, id: \.self) { sound in
                                Button(action: {
                                    withAnimation { selectedSound = sound }
                                }) {
                                    VStack(spacing: 12) {
                                        Image(systemName: sound.icon)
                                            .font(.largeTitle)
                                        Text(sound.displayName)
                                            .font(.caption.bold())
                                    }
                                    .padding()
                                    .frame(width: 120, height: 120)
                                    .background(selectedSound == sound ? Color.white : Color.white.opacity(0.2))
                                    .foregroundColor(selectedSound == sound ? Theme.calm : .white)
                                    .cornerRadius(20)
                                }
                            }
                        }
                        .padding()
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Duration: \(Int(selectedDuration)) minutes")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Slider(value: $selectedDuration, in: 5...30, step: 5)
                            .tint(.white)
                    }
                    .padding(.horizontal, 32)
                    .padding(.top, 24)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            audioManager.playSound(selectedSound, duration: selectedDuration * 60)
                        }
                    }) {
                        Text("Start Session")
                            .font(.title3.bold())
                            .foregroundColor(Theme.calm)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(16)
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
                }
            }
        }
        .sheet(isPresented: $showingInfo) {
            infoSheet
        }
        .onReceive(audioManager.$isPlaying) { playing in
            if !playing && audioManager.remainingTime <= 0 && audioManager.currentTrack != nil {
                // Natural finish
                appState.completeCalmSession(duration: selectedDuration * 60, completedFully: true, sound: selectedSound)
                // Need to clear current track conceptually, managed by AudioManager
            }
        }
    }
    
    private var infoSheet: some View {
        NavigationStack {
            List {
                Section(header: Text("Science of Stress Reduction")) {
                    Text("Calming sounds help reduce cortisol levels, lower heart rate, and mask environmental triggers that cause pet anxiety.")
                }
                
                Section(header: Text("Sound Benefits")) {
                    ForEach(CalmSound.allCases, id: \.self) { sound in
                        VStack(alignment: .leading, spacing: 4) {
                            Label(sound.displayName, systemImage: sound.icon)
                                .font(.headline)
                            Text(sound.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section(header: Text("When to Use")) {
                    Text("• During thunderstorms or fireworks")
                    Text("• When leaving the house (separation anxiety)")
                    Text("• Before bedtime for better sleep")
                    Text("• After vigorous exercise to cool down")
                }
            }
            .navigationTitle("Why Calming Sounds Work")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { showingInfo = false }
                }
            }
        }
    }
    
    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
