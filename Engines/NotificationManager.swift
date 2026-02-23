import Foundation
import Combine
import UserNotifications

@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var permissionGranted = false

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async { self.permissionGranted = granted }
        }
    }

    // MARK: - Appointments

    /// Schedules two notifications: 24 h before and 1 h before the appointment.
    func scheduleAppointment(_ appt: VetAppointment) -> [String] {
        var ids: [String] = []

        let content = UNMutableNotificationContent()
        content.title = "🏥 Vet Appointment"
        content.body = "\(appt.title) with \(appt.vetName)"
        content.sound = .default

        let offsets: [(TimeInterval, String)] = [
            (-86400, "24h"),   // 24 hours before
            (-3600,  "1h")     // 1 hour before
        ]

        for (offset, label) in offsets {
            let fireDate = appt.date.addingTimeInterval(offset)
            guard fireDate > Date() else { continue }

            let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            let id = "\(appt.id.uuidString)-\(label)"
            UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
            ids.append(id)
        }
        return ids
    }

    // MARK: - Medications

    /// Schedules repeating notifications for a medication.
    func scheduleMedication(_ med: Medication) -> [String] {
        guard med.frequency != .asNeeded else { return [] }

        let content = UNMutableNotificationContent()
        content.title = "💊 Medication Reminder"
        content.body = "Time to give \(med.name) — \(med.dosageDisplay)"
        content.sound = .default

        var ids: [String] = []

        switch med.frequency {
        case .daily:
            let id = scheduleRepeating(content: content, hour: 8, minute: 0, weekday: nil, baseID: med.id.uuidString + "-daily")
            ids.append(id)

        case .twiceDaily:
            let id1 = scheduleRepeating(content: content, hour: 8, minute: 0, weekday: nil, baseID: med.id.uuidString + "-am")
            let id2 = scheduleRepeating(content: content, hour: 20, minute: 0, weekday: nil, baseID: med.id.uuidString + "-pm")
            ids.append(contentsOf: [id1, id2])

        case .weekly:
            let comps = Calendar.current.dateComponents([.weekday, .hour, .minute], from: med.startDate)
            let id = scheduleRepeating(content: content, hour: comps.hour ?? 9, minute: comps.minute ?? 0, weekday: comps.weekday, baseID: med.id.uuidString + "-weekly")
            ids.append(id)

        case .asNeeded:
            break
        }

        return ids
    }

    @discardableResult
    private func scheduleRepeating(content: UNMutableNotificationContent, hour: Int, minute: Int, weekday: Int?, baseID: String) -> String {
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        if let wd = weekday { comps.weekday = wd }
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        UNUserNotificationCenter.current().add(UNNotificationRequest(identifier: baseID, content: content, trigger: trigger))
        return baseID
    }

    // MARK: - Cancel

    func cancelNotifications(ids: [String]) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
    }
}
