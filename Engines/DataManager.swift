import Foundation

struct DataManager {
    static let shared = DataManager()
    
    private let fileManager = FileManager.default
    private var appSupportDirectory: URL {
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        return urls[0].appendingPathComponent("PawTrack")
    }
    
    private init() {}
    
    private func createDirectoryIfNeeded() throws {
        if !fileManager.fileExists(atPath: appSupportDirectory.path) {
            try fileManager.createDirectory(at: appSupportDirectory, withIntermediateDirectories: true)
        }
    }
    
    func savePets(_ pets: [PetProfile]) throws {
        try createDirectoryIfNeeded()
        let url = appSupportDirectory.appendingPathComponent("pets.json")
        let data = try JSONEncoder().encode(pets)
        try data.write(to: url)
    }
    
    func loadPets() throws -> [PetProfile] {
        let url = appSupportDirectory.appendingPathComponent("pets.json")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([PetProfile].self, from: data)
    }
    
    func saveDailyGoals(_ goals: [UUID: [DailyGoal]]) throws {
        try createDirectoryIfNeeded()
        let url = appSupportDirectory.appendingPathComponent("daily_goals.json")
        let data = try JSONEncoder().encode(goals)
        try data.write(to: url)
    }
    
    func loadDailyGoals() throws -> [UUID: [DailyGoal]] {
        let url = appSupportDirectory.appendingPathComponent("daily_goals.json")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([UUID: [DailyGoal]].self, from: data)
    }
    
    func saveImage(_ imageData: Data, forPetID petID: UUID) throws -> String {
        try createDirectoryIfNeeded()
        let imagesDir = appSupportDirectory.appendingPathComponent("PetImages")
        if !fileManager.fileExists(atPath: imagesDir.path) {
            try fileManager.createDirectory(at: imagesDir, withIntermediateDirectories: true)
        }
        let filename = "\(petID.uuidString).jpg"
        let url = imagesDir.appendingPathComponent(filename)
        try imageData.write(to: url)
        return filename
    }
    
    func loadImage(forPetID petID: UUID) -> Data? {
        let imagesDir = appSupportDirectory.appendingPathComponent("PetImages")
        let url = imagesDir.appendingPathComponent("\(petID.uuidString).jpg")
        return try? Data(contentsOf: url)
    }
    
    // MARK: - Document Vault
    
    private var documentsVaultURL: URL {
        appSupportDirectory.appendingPathComponent("DocumentsVault")
    }
    
    func saveDocument(from sourceURL: URL, withName filename: String) throws -> String {
        try createDirectoryIfNeeded()
        if !fileManager.fileExists(atPath: documentsVaultURL.path) {
            try fileManager.createDirectory(at: documentsVaultURL, withIntermediateDirectories: true)
        }
        
        let targetURL = documentsVaultURL.appendingPathComponent(filename)
        
        // Ensure we have access to security-scoped resource if it was picked via UIDocumentPicker
        let accessing = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if accessing {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }
        
        if fileManager.fileExists(atPath: targetURL.path) {
            try fileManager.removeItem(at: targetURL)
        }
        
        try fileManager.copyItem(at: sourceURL, to: targetURL)
        return filename
    }
    
    func saveImageDocument(_ data: Data, withName filename: String) throws -> String {
        try createDirectoryIfNeeded()
        if !fileManager.fileExists(atPath: documentsVaultURL.path) {
            try fileManager.createDirectory(at: documentsVaultURL, withIntermediateDirectories: true)
        }
        let targetURL = documentsVaultURL.appendingPathComponent(filename)
        try data.write(to: targetURL)
        return filename
    }
    
    func documentURL(for filename: String) -> URL {
        return documentsVaultURL.appendingPathComponent(filename)
    }
}
