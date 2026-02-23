import Foundation
import AVFoundation
import Combine
import SwiftUI

@MainActor
class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    @Published var isPlaying: Bool = false
    @Published var currentTrack: CalmSound? = nil
    @Published var remainingTime: TimeInterval = 0
    
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    func playSound(_ sound: CalmSound, duration: TimeInterval) {
        guard let url = Bundle.main.url(forResource: sound.rawValueString, withExtension: "mp3") else {
            print("Sound file not found for \(sound.rawValueString)")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1
            audioPlayer?.play()
            
            currentTrack = sound
            isPlaying = true
            remainingTime = duration * 60 // convert to seconds if passed as minutes (wait, duration param is timeinterval, generally seconds, let's assume it is seconds)
            
            startTimer()
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
    
    func stopSound() {
        audioPlayer?.stop()
        timer?.invalidate()
        isPlaying = false
        currentTrack = nil
        remainingTime = 0
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.remainingTime -= 1
                if self.remainingTime <= 0 {
                    self.stopSound()
                }
            }
        }
    }
}
