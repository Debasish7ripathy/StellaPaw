import Foundation

enum CalmSound: String, Codable, CaseIterable {
    case rain = "rain"
    case forest = "forest"
    case whiteNoise = "whiteNoise"
    case heartbeat = "heartbeat"
    case piano = "piano"
    
    var rawValueString: String {
        switch self {
        case .rain: return "rain_loop"
        case .forest: return "forest_breeze"
        case .whiteNoise: return "white_noise"
        case .heartbeat: return "heartbeat_loop"
        case .piano: return "soft_piano"
        }
    }
    
    var displayName: String {
        switch self {
        case .rain: return "Gentle Rain"
        case .forest: return "Forest Breeze"
        case .whiteNoise: return "White Noise"
        case .heartbeat: return "Heartbeat Rhythm"
        case .piano: return "Soft Piano"
        }
    }
    
    var icon: String {
        switch self {
        case .rain: return "cloud.rain.fill"
        case .forest: return "leaf.fill"
        case .whiteNoise: return "waveform"
        case .heartbeat: return "heart.fill"
        case .piano: return "music.note"
        }
    }
    
    var description: String {
        switch self {
        case .rain: return "Mimics natural rainfall, shown to reduce cortisol"
        case .forest: return "Nature sounds promote relaxation and calmness"
        case .whiteNoise: return "Masks environmental noise, aids sleep"
        case .heartbeat: return "Reminds pets of maternal comfort"
        case .piano: return "Low-frequency tones soothe anxiety"
        }
    }
}

struct CalmSession: Identifiable, Codable {
    var id: UUID = UUID()
    var petID: UUID
    var date: Date
    var sound: CalmSound
    var durationMinutes: Int
    var completedFully: Bool
}
