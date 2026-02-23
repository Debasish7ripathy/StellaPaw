import SwiftUI
import PhotosUI

struct AddPetSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    
    var isFirstPet: Bool = false
    
    @State private var name = ""
    @State private var species: PetSpecies = .dog
    @State private var breed = "Golden Retriever"
    @State private var age = 3
    @State private var weight = 15.0
    @State private var gender: Gender = .unknown
    @State private var energyLevel: EnergyLevel = .moderate
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var profileImageData: Data?
    
    private let breedsBySpecies: [PetSpecies: [String]] = [
        .dog: ["Golden Retriever", "Labrador Retriever", "German Shepherd", "French Bulldog",
               "Bulldog", "Poodle", "Beagle", "Rottweiler", "Yorkshire Terrier", "Dachshund",
               "Siberian Husky", "Shih Tzu", "Chihuahua", "Border Collie", "Pomeranian",
               "Boxer", "Great Dane", "Maltese", "Doberman", "Cocker Spaniel"],
        .cat: ["Persian", "Maine Coon", "Siamese", "Ragdoll", "Bengal", "Russian Blue",
               "Sphynx", "British Shorthair", "Scottish Fold", "Abyssinian",
               "American Shorthair", "Norwegian Forest Cat", "Birman", "Tonkinese", "Mixed"],
        .rabbit: ["Holland Lop", "Netherland Dwarf", "Mini Rex", "Lionhead", "Flemish Giant",
                  "English Angora", "Dutch", "Californian", "New Zealand", "Rex"],
        .hamster: ["Syrian", "Dwarf Campbell", "Winter White", "Roborovski", "Chinese Hamster"],
        .bird: ["Budgerigar", "Cockatiel", "African Grey Parrot", "Macaw", "Conure",
                "Lovebird", "Canary", "Finch", "Eclectus", "Cockatoo"],
        .fish: ["Goldfish", "Betta", "Guppies", "Oscar", "Koi", "Angelfish",
                "Clownfish", "Tetra", "Cichlid", "Discus"],
        .turtle: ["Red-Eared Slider", "Box Turtle", "Russian Tortoise", "Painted Turtle",
                  "Map Turtle", "Sulcata Tortoise"],
        .other: ["Mixed Breed", "Unknown", "Other"]
    ]
    
    private var availableBreeds: [String] {
        breedsBySpecies[species] ?? ["Mixed Breed", "Other"]
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Species Selection
                Section("Pet Type") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 70), spacing: 10)], spacing: 10) {
                        ForEach(PetSpecies.allCases, id: \.self) { s in
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    species = s
                                    // Reset breed to first valid option for new species
                                    breed = breedsBySpecies[s]?.first ?? "Other"
                                }
                            }) {
                                VStack(spacing: 6) {
                                    Text(s.icon)
                                        .font(.title)
                                    Text(s.display)
                                        .font(.caption.bold())
                                        .foregroundColor(species == s ? Theme.primary : .primary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(species == s ? Theme.primary.opacity(0.15) : Color(UIColor.systemGroupedBackground))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(species == s ? Theme.primary : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 6)
                }
                
                // Profile Picture
                Section("Profile Picture") {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            if let profileImageData, let uiImage = UIImage(data: profileImageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(Theme.primary.opacity(0.15))
                                        .frame(width: 100, height: 100)
                                    Text(species.icon)
                                        .font(.system(size: 44))
                                }
                            }
                        }
                        .onChange(of: selectedItem) { _, newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data),
                                   let compressed = uiImage.jpegData(compressionQuality: 0.6) {
                                    profileImageData = compressed
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                // Basic Info
                Section("Basic Information") {
                    TextField("Pet Name", text: $name)
                    
                    Picker("Breed", selection: $breed) {
                        ForEach(availableBreeds, id: \.self) {
                            Text($0).tag($0)
                        }
                    }
                    
                    Stepper("Age: \(age) years", value: $age, in: 0...30)
                    
                    VStack {
                        HStack {
                            Text("Weight")
                            Spacer()
                            Text("\(weight, specifier: "%.1f") kg")
                        }
                        Slider(value: $weight, in: 0.1...100, step: 0.5)
                            .tint(Theme.primary)
                    }
                    
                    Picker("Gender", selection: $gender) {
                        ForEach(Gender.allCases, id: \.self) { g in
                            Text(g.display).tag(g)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    Picker("Energy Level", selection: $energyLevel) {
                        ForEach(EnergyLevel.allCases, id: \.self) { e in
                            Text(e.display).tag(e)
                        }
                    }
                }
                
                // Daily Goals Preview
                Section("Daily Goals Preview") {
                    let water = Int(HealthEngine.calculateHydrationTarget(weight: weight))
                    let cal = HealthEngine.calculateCalorieTarget(weight: weight, age: age, energyLevel: energyLevel)
                    let dist = HealthEngine.calculateActivityTarget(breed: breed, energyLevel: energyLevel, currentStreak: 0)
                    
                    HStack {
                        Text("Hydration Target")
                        Spacer()
                        Text("\(water) mL").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Calorie Target")
                        Spacer()
                        Text("\(cal) kcal").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Activity Target")
                        Spacer()
                        Text("\(dist, specifier: "%.1f") km").foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(isFirstPet ? "Add Your Pet" : "New Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    if !isFirstPet {
                        Button("Cancel") { dismiss() }
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let profile = PetProfile(
                            id: UUID(),
                            name: name,
                            species: species,
                            breed: breed,
                            age: age,
                            weight: weight,
                            gender: gender,
                            energyLevel: energyLevel,
                            profileImageData: profileImageData,
                            createdAt: Date(),
                            lastActiveDate: Date()
                        )
                        appState.addPet(profile)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
