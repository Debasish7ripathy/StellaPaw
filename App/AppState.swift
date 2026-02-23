import Foundation
import Combine
import SwiftUI

enum ThemeMode: String, Codable {
    case light = "light"
    case dark = "dark"
    case system = "system"
}

enum AppTab: String, Codable {
    case dashboard = "dashboard"
    case nutrition = "nutrition"
    case activity = "activity"
    case sounds = "sounds"
    case records = "records"
    case analytics = "analytics"
    case emergency = "emergency"
    case ai = "ai"
}


@MainActor
class AppState: ObservableObject {
    @Published var pets: [PetProfile] = []
    @Published var activePetID: UUID?
    @Published var dailyGoals: [UUID: [DailyGoal]] = [:]
    @Published var analyticsHistory: [UUID: [AnalyticsSnapshot]] = [:]
    @Published var medicalRecords: [UUID: [MedicalRecord]] = [:]
    @Published var calmModeSessions: [UUID: [CalmSession]] = [:]
    @Published var emergencyContacts: [EmergencyContact] = EmergencyContact.defaults
    @Published var appointments: [UUID: [VetAppointment]] = [:]
    @Published var medications: [UUID: [Medication]] = [:]
    @Published var milestones: [UUID: [PetMilestone]] = [:]
    
    @AppStorage("themeMode") var themeMode: ThemeMode = .system
    @Published var isOnboardingComplete: Bool = UserDefaults.standard.bool(forKey: "isOnboardingComplete") {
        didSet { UserDefaults.standard.set(isOnboardingComplete, forKey: "isOnboardingComplete") }
    }
    
    @Published var selectedTab: AppTab = .dashboard
    @Published var showingAddPetSheet: Bool = false
    @Published var showingCalmMode: Bool = false
    
    var activePet: PetProfile? {
        pets.first(where: { $0.id == activePetID })
    }
    
    var todaysGoalForActivePet: DailyGoal? {
        guard let petID = activePetID else { return nil }
        let today = Date()
        return dailyGoals[petID]?.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) })
    }
    
    init() {
        loadFromDisk()
    }
    
    func addPet(_ profile: PetProfile) {
        pets.append(profile)
        dailyGoals[profile.id] = []
        medicalRecords[profile.id] = []
        calmModeSessions[profile.id] = []
        analyticsHistory[profile.id] = []
        activePetID = profile.id
        createOrUpdateTodaysGoalIfExists(for: profile)
        saveToDisk()
    }
    
    func updatePet(_ profile: PetProfile) {
        if let idx = pets.firstIndex(where: { $0.id == profile.id }) {
            pets[idx] = profile
            createOrUpdateTodaysGoalIfExists(for: profile)
            saveToDisk()
        }
    }
    
    func deletePet(id: UUID) {
        pets.removeAll(where: { $0.id == id })
        dailyGoals.removeValue(forKey: id)
        medicalRecords.removeValue(forKey: id)
        calmModeSessions.removeValue(forKey: id)
        analyticsHistory.removeValue(forKey: id)
        if activePetID == id {
            activePetID = pets.first?.id
        }
        saveToDisk()
    }
    
    func switchActivePet(to id: UUID) {
        if let idx = pets.firstIndex(where: { $0.id == id }) {
            activePetID = id
            pets[idx].lastActiveDate = Date()
            if todaysGoalForActivePet == nil {
                createOrUpdateTodaysGoalIfExists(for: pets[idx])
            }
            saveToDisk()
        }
    }
    
    func logMeal(meal: FoodItem) {
        guard let petID = activePetID, var goal = todaysGoalForActivePet else { return }
        goal.mealsCompleted.append(meal)
        goal.caloriesConsumed += meal.calories
        updateTodayGoal(goal, for: petID)
    }
    
    func updateHydration(amount: Double) {
        guard let petID = activePetID, var goal = todaysGoalForActivePet else { return }
        let maxWater = goal.waterTargetML * 1.5
        goal.waterConsumedML = min(goal.waterConsumedML + amount, maxWater)
        updateTodayGoal(goal, for: petID)
    }
    
    func logActivity(distance: Double) {
        guard let petID = activePetID, var goal = todaysGoalForActivePet else { return }
        goal.activityCompletedKM += distance
        updateTodayGoal(goal, for: petID)
    }

    func logActivity(entry: ActivityEntry) {
        guard let petID = activePetID, var goal = todaysGoalForActivePet else { return }
        goal.activityCompletedKM += entry.distanceKM
        goal.activityLog.append(entry)
        updateTodayGoal(goal, for: petID)
    }
    
    func completeCalmSession(duration: TimeInterval, completedFully: Bool, sound: CalmSound) {
        guard let petID = activePetID else { return }
        let durationMins = Int(duration / 60)
        let session = CalmSession(petID: petID, date: Date(), sound: sound, durationMinutes: durationMins, completedFully: completedFully)
        calmModeSessions[petID]?.append(session)
        
        if var goal = todaysGoalForActivePet {
            goal.relaxationMinutes += durationMins
            updateTodayGoal(goal, for: petID)
        } else {
            saveToDisk()
        }
    }
    
    private func updateTodayGoal(_ goal: DailyGoal, for petID: UUID) {
        // Build a full mutable copy so @Published fires reliably on any mutation
        var updatedGoals = dailyGoals
        var petGoals = updatedGoals[petID] ?? []
        if let idx = petGoals.firstIndex(where: { $0.id == goal.id }) {
            petGoals[idx] = goal
        } else {
            petGoals.append(goal)
        }
        updatedGoals[petID] = petGoals
        dailyGoals = updatedGoals   // Full reassignment — guarantees @Published fires
        updateSnapshot(for: petID, with: goal)
        saveToDisk()
    }
    
    private func updateSnapshot(for petID: UUID, with goal: DailyGoal) {
        let snapshot = AnalyticsSnapshot(
            date: goal.date,
            activityPercent: goal.activityProgress,
            hydrationPercent: goal.hydrationProgress,
            caloriePercent: goal.calorieProgress,
            relaxationMinutes: goal.relaxationMinutes
        )
        if let idx = analyticsHistory[petID]?.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: goal.date) }) {
            analyticsHistory[petID]?[idx] = snapshot
        } else {
            analyticsHistory[petID]?.append(snapshot)
        }
    }
    
    func createOrUpdateTodaysGoalIfExists(for profile: PetProfile) {
        let actTgt = HealthEngine.calculateActivityTarget(breed: profile.breed, energyLevel: profile.energyLevel, currentStreak: AnalyticsEngine.calculateStreak(goals: dailyGoals[profile.id] ?? []))
        let waterTgt = HealthEngine.calculateHydrationTarget(weight: profile.weight)
        let calTgt = HealthEngine.calculateCalorieTarget(weight: profile.weight, age: profile.age, energyLevel: profile.energyLevel)
        
        let today = Date()
        if let idx = dailyGoals[profile.id]?.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            dailyGoals[profile.id]?[idx].activityTargetKM = actTgt
            dailyGoals[profile.id]?[idx].waterTargetML = waterTgt
            dailyGoals[profile.id]?[idx].caloriesTarget = calTgt
        } else {
            let newGoal = DailyGoal(petID: profile.id, date: today, activityTargetKM: actTgt, waterTargetML: waterTgt, caloriesTarget: calTgt)
            if dailyGoals[profile.id] != nil {
                dailyGoals[profile.id]?.append(newGoal)
            } else {
                dailyGoals[profile.id] = [newGoal]
            }
        }
    }
    
    func saveToDisk() {
        do {
            try DataManager.shared.savePets(pets)
            try DataManager.shared.saveDailyGoals(dailyGoals)
            
            let fm = FileManager.default
            let appSupport = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("PawTrack")
            if !fm.fileExists(atPath: appSupport.path) {
                try fm.createDirectory(at: appSupport, withIntermediateDirectories: true)
            }
            try JSONEncoder().encode(medicalRecords).write(to: appSupport.appendingPathComponent("medical_records.json"))
            try JSONEncoder().encode(calmModeSessions).write(to: appSupport.appendingPathComponent("calm_sessions.json"))
            try JSONEncoder().encode(analyticsHistory).write(to: appSupport.appendingPathComponent("analytics_history.json"))
            try JSONEncoder().encode(emergencyContacts).write(to: appSupport.appendingPathComponent("emergency_contacts.json"))
            try JSONEncoder().encode(appointments).write(to: appSupport.appendingPathComponent("appointments.json"))
            try JSONEncoder().encode(medications).write(to: appSupport.appendingPathComponent("medications.json"))
            try JSONEncoder().encode(milestones).write(to: appSupport.appendingPathComponent("milestones.json"))
            
        } catch {
            print("Failed to save to disk: \(error)")
        }
    }
    
    func loadFromDisk() {
        // Each section loaded independently so one missing file doesn't abort the rest
        if let loaded = try? DataManager.shared.loadPets() {
            pets = loaded
        }
        if let loaded = try? DataManager.shared.loadDailyGoals() {
            dailyGoals = loaded
        }
        
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("PawTrack")
        
        let medURL = appSupport.appendingPathComponent("medical_records.json")
        if let d = try? Data(contentsOf: medURL),
           let decoded = try? JSONDecoder().decode([UUID: [MedicalRecord]].self, from: d) {
            medicalRecords = decoded
        }
        
        let calmURL = appSupport.appendingPathComponent("calm_sessions.json")
        if let d = try? Data(contentsOf: calmURL),
           let decoded = try? JSONDecoder().decode([UUID: [CalmSession]].self, from: d) {
            calmModeSessions = decoded
        }
        
        let anaURL = appSupport.appendingPathComponent("analytics_history.json")
        if let d = try? Data(contentsOf: anaURL),
           let decoded = try? JSONDecoder().decode([UUID: [AnalyticsSnapshot]].self, from: d) {
            analyticsHistory = decoded
        }

        let contactsURL = appSupport.appendingPathComponent("emergency_contacts.json")
        if let d = try? Data(contentsOf: contactsURL),
           let decoded = try? JSONDecoder().decode([EmergencyContact].self, from: d) {
            emergencyContacts = decoded
        }
        
        let apptURL = appSupport.appendingPathComponent("appointments.json")
        if let d = try? Data(contentsOf: apptURL),
           let decoded = try? JSONDecoder().decode([UUID: [VetAppointment]].self, from: d) {
            appointments = decoded
        }
        
        let medURL2 = appSupport.appendingPathComponent("medications.json")
        if let d = try? Data(contentsOf: medURL2),
           let decoded = try? JSONDecoder().decode([UUID: [Medication]].self, from: d) {
            medications = decoded
        }
        
        let msURL = appSupport.appendingPathComponent("milestones.json")
        if let d = try? Data(contentsOf: msURL),
           let decoded = try? JSONDecoder().decode([UUID: [PetMilestone]].self, from: d) {
            milestones = decoded
        }
        
        if activePetID == nil, let first = pets.first {
            activePetID = first.id
        }
        if let active = activePet {
            createOrUpdateTodaysGoalIfExists(for: active)
        }
    }
}
