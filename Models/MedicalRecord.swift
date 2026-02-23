import Foundation

enum RecordType: String, Codable, CaseIterable {
    case vaccination = "vaccination"
    case checkup = "checkup"
    case prescription = "prescription"
    case surgery = "surgery"
    case emergency = "emergency"
    case note = "note"
    
    var icon: String {
        switch self {
        case .vaccination: return "syringe.fill"
        case .checkup: return "stethoscope"
        case .prescription: return "pills.fill"
        case .surgery: return "cross.case.fill"
        case .emergency: return "exclamationmark.triangle.fill"
        case .note: return "note.text"
        }
    }
    
    var display: String {
        switch self {
        case .vaccination: return "Vaccination"
        case .checkup: return "Checkup"
        case .prescription: return "Prescription"
        case .surgery: return "Surgery"
        case .emergency: return "Emergency"
        case .note: return "General Note"
        }
    }
}

struct MedicalRecord: Identifiable, Codable {
    var id: UUID = UUID()
    var petID: UUID
    var title: String
    var date: Date
    var type: RecordType
    var notes: String
    var attachmentFilename: String?
    var isEmergency: Bool = false
    var attachedDocumentNames: [String] = []
}
