import Foundation

struct EmergencyCategory: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let color: String // hex
    let description: String
    let steps: [String]
    let warningSigns: [String]
    let callVetWhen: String
}

struct EmergencyGuide {
    
    static func categories(for species: PetSpecies) -> [EmergencyCategory] {
        switch species {
        case .dog: return dogGuides
        case .cat: return catGuides
        case .rabbit: return rabbitGuides
        case .bird: return birdGuides
        case .hamster: return hamsterGuides
        case .fish: return fishGuides
        case .turtle: return turtleGuides
        case .other: return genericGuides
        }
    }
    
    // MARK: - Dog Guides
    static let dogGuides: [EmergencyCategory] = [
        EmergencyCategory(
            name: "Choking",
            icon: "lungs.fill",
            color: "#FF4444",
            description: "Dog is pawing at mouth, gagging, or has blue-tinged gums.",
            steps: [
                "Look inside the mouth and remove visible objects with fingers or tweezers — only if clearly visible.",
                "For small dogs: Hold upside down by hind legs and give 5 firm back blows between shoulder blades.",
                "For large dogs: Stand behind, place hands under rib cage and thrust inward-upward 5 times (Heimlich).",
                "If still choking, sweep inside mouth from back to front.",
                "If unconscious, begin rescue breathing: close mouth, breathe into nose, check for chest rise.",
                "Rush to a vet immediately."
            ],
            warningSigns: ["Gagging", "Pawing at mouth", "Blue or pale gums", "High-pitched wheezing", "Extreme distress"],
            callVetWhen: "Immediately after any choking incident, even if object is removed."
        ),
        EmergencyCategory(
            name: "Poisoning",
            icon: "exclamationmark.triangle.fill",
            color: "#FF8800",
            description: "Dog may have ingested a toxic substance.",
            steps: [
                "Identify what was ingested — keep the package or note the substance.",
                "Do NOT induce vomiting unless instructed by a vet.",
                "Call the vet or animal poison helpline immediately.",
                "If skin/eye contact with toxin: flush with large amounts of water for 15 minutes.",
                "Keep the dog calm and warm during transport.",
                "Bring the toxin/container to the vet clinic."
            ],
            warningSigns: ["Vomiting", "Tremors or seizures", "Excessive drooling", "Lethargy", "Dilated pupils", "Sudden collapse"],
            callVetWhen: "Any suspected poisoning — do not wait for symptoms to worsen."
        ),
        EmergencyCategory(
            name: "Heatstroke",
            icon: "thermometer.sun.fill",
            color: "#FF6600",
            description: "Dog is overheating — often after being left in a hot car or exercising in heat.",
            steps: [
                "Move dog immediately to a cool, shaded area or air-conditioned room.",
                "Apply cool (NOT ice cold) water to paws, armpits, groin, and neck.",
                "Fan the dog to help evaporative cooling.",
                "Give small amounts of cool (not cold) water to drink if conscious.",
                "Place wet towels on the dog's body but do NOT wrap.",
                "Monitor rectal temperature if possible — target below 39.5°C.",
                "Transport to vet immediately."
            ],
            warningSigns: ["Excessive panting", "Drooling", "Red or pale gums", "Staggering", "Vomiting", "Collapse"],
            callVetWhen: "Immediately. Heatstroke can be fatal within minutes."
        ),
        EmergencyCategory(
            name: "Bleeding",
            icon: "drop.fill",
            color: "#CC0000",
            description: "Dog has an open wound with active blood loss.",
            steps: [
                "Stay calm — your dog will sense your anxiety.",
                "Apply direct pressure using a clean cloth or gauze for at least 5 minutes.",
                "Do NOT remove the cloth — add more on top if soaked through.",
                "Elevate the injured limb above the heart level if possible.",
                "For severe limb bleeding, apply a tourniquet above the wound — note the time applied.",
                "Muzzle the dog gently if biting due to pain.",
                "Transport to vet immediately without releasing pressure."
            ],
            warningSigns: ["Continuous blood flow", "Pale gums", "Weak pulse", "Rapid breathing", "Lethargy"],
            callVetWhen: "Any wound that doesn't stop bleeding within 5 minutes, or any puncture wound."
        ),
        EmergencyCategory(
            name: "Seizures",
            icon: "bolt.heart.fill",
            color: "#8B00FF",
            description: "Dog is convulsing or has uncontrolled muscle activity.",
            steps: [
                "Stay calm and DO NOT put your hands near the dog's mouth.",
                "Clear the area of furniture or sharp objects to prevent injury.",
                "Time the seizure using your phone.",
                "Gently hold the dog's head to prevent injury — do not restrain the body.",
                "Keep surroundings quiet and dim lights if possible.",
                "After the seizure, speak softly and keep the dog warm.",
                "Note seizure duration and any triggers — share with vet.",
                "Seek emergency care immediately."
            ],
            warningSigns: ["Convulsions", "Muscle twitching", "Loss of consciousness", "Paddling legs", "Drooling", "Loss of bladder/bowel control"],
            callVetWhen: "Any seizure lasting over 2 minutes, or multiple seizures in 24 hours."
        ),
        EmergencyCategory(
            name: "Fracture / Injury",
            icon: "bandage.fill",
            color: "#0066CC",
            description: "Dog may have broken a bone or suffered trauma.",
            steps: [
                "Do not move the dog unless necessary to avoid further injury.",
                "Muzzle gently if the dog may bite from pain.",
                "Stabilize the injured area: use a rolled magazine, stick, or firm padding as a splint.",
                "Secure the splint gently with bandage or cloth — do not cut off circulation.",
                "Lift the dog with full body support — use a blanket as a stretcher if needed.",
                "Keep the dog warm and still during transport.",
                "Go directly to the vet — do not attempt to set the bone."
            ],
            warningSigns: ["Limping or non-weight bearing", "Swelling or deformity", "Bone visible through skin", "Crying or whimpering", "Inability to stand"],
            callVetWhen: "Immediately. Fractures require professional X-ray and care."
        ),
        EmergencyCategory(
            name: "Drowning",
            icon: "water.waves",
            color: "#0099CC",
            description: "Dog has been submerged in water and may not be breathing.",
            steps: [
                "Pull dog from water and lay on a flat surface.",
                "Hold small dogs upside down for 10-20 seconds to drain water from lungs.",
                "For large dogs: lay on side, raise hindquarters to help drain fluid.",
                "Clear airway: wipe mouth and nose with cloth.",
                "Check for breathing and pulse.",
                "If not breathing: close mouth, breathe gently into nostrils every 3 seconds.",
                "If no pulse: begin chest compressions (30 per breath) until heartbeat returns.",
                "Rush to vet even if dog appears to recover."
            ],
            warningSigns: ["Coughing or gagging", "Blue gums", "Collapse", "Extreme lethargy", "No breathing"],
            callVetWhen: "Always — secondary drowning can occur hours later."
        ),
        EmergencyCategory(
            name: "Eye Injury",
            icon: "eye.fill",
            color: "#009966",
            description: "Dog has eye redness, discharge, or protrusion.",
            steps: [
                "Prevent the dog from pawing at the eye using an e-collar if available.",
                "Flush eye gently with saline or clean warm water using a syringe.",
                "Do NOT apply any eye drops unless prescribed.",
                "For eye prolapse (eye popped out): keep eye moist with saline-soaked cloth — do NOT push it back.",
                "Transport immediately to the vet.",
                "Keep the eye covered loosely with a damp cloth during transport."
            ],
            warningSigns: ["Eye bulging or prolapsed", "Cloudiness", "Discharge", "Squinting or pawing at eye", "Redness"],
            callVetWhen: "Immediately for prolapse or penetrating injury. Same day for other eye issues."
        )
    ]
    
    // MARK: - Cat Guides
    static let catGuides: [EmergencyCategory] = [
        EmergencyCategory(
            name: "Choking",
            icon: "lungs.fill",
            color: "#FF4444",
            description: "Cat is gagging, drooling excessively, or has difficulty breathing.",
            steps: [
                "Open the mouth and look for any visible foreign object.",
                "Use tweezers to gently remove if clearly visible — never blindly reach in.",
                "Hold cat upside down firmly and give 5 back blows between shoulder blades.",
                "Apply modified Heimlich: place hands under last ribs and firmly compress 3-5 times.",
                "Check mouth again and sweep from back to front.",
                "Begin rescue breathing if cat loses consciousness.",
                "Rush to vet without delay."
            ],
            warningSigns: ["Open-mouth breathing", "Gagging repeatedly", "Pawing at face", "Blue lips or gums", "Silent distress"],
            callVetWhen: "Immediately — cats are obligate nasal breathers and deteriorate fast."
        ),
        EmergencyCategory(
            name: "Urinary Blockage",
            icon: "exclamationmark.circle.fill",
            color: "#CC0000",
            description: "Common in male cats — unable to urinate. Life-threatening within 24-48 hrs.",
            steps: [
                "This is a LIFE-THREATENING emergency. Go to vet immediately.",
                "Do NOT try to press the abdomen to force urination.",
                "Keep the cat calm and warm during transport.",
                "Do not offer food or water.",
                "Note the last time the cat urinated and any straining behavior.",
                "Call the vet in advance so they can prepare on arrival."
            ],
            warningSigns: ["Straining to urinate with no output", "Crying in the litter box", "Licking genitals repeatedly", "Lethargy", "Vomiting"],
            callVetWhen: "IMMEDIATELY — urinary blockage is fatal within 24–48 hours."
        ),
        EmergencyCategory(
            name: "Poisoning",
            icon: "exclamationmark.triangle.fill",
            color: "#FF8800",
            description: "Cat exposed to toxic plants, chemicals, or human medications.",
            steps: [
                "Identify what the cat ingested — take a photo of the plant/substance.",
                "Do NOT induce vomiting in cats — it can cause additional harm.",
                "Call the vet or animal poison control immediately.",
                "If substance is on skin/fur: wash with mild soap and warm water.",
                "Keep cat warm and confined to prevent further exposure.",
                "Bring the toxin/container to the clinic."
            ],
            warningSigns: ["Drooling", "Trembling", "Vomiting", "Dilated pupils", "Loss of coordination", "Collapse"],
            callVetWhen: "Any suspected toxin exposure — do not wait for symptoms."
        ),
        EmergencyCategory(
            name: "Heatstroke",
            icon: "thermometer.sun.fill",
            color: "#FF6600",
            description: "Cat is severely overheated, often from being in a car or hot room.",
            steps: [
                "Move cat to a cool environment immediately.",
                "Apply cool (not cold) water to pawpads, armpits, and the back of the neck.",
                "Do NOT use ice — it can cause shock.",
                "Offer small sips of cool water if conscious.",
                "Fan the cat during cooling.",
                "Transport to vet while keeping cool — windows open or AC on."
            ],
            warningSigns: ["Rapid panting (unusual for cats)", "Drooling", "Redness in mouth", "Staggering", "Loss of consciousness"],
            callVetWhen: "Immediately — cats are extremely sensitive to heat."
        ),
        EmergencyCategory(
            name: "Seizures",
            icon: "bolt.heart.fill",
            color: "#8B00FF",
            description: "Cat has sudden uncontrolled body movements.",
            steps: [
                "Do NOT restrain the cat during a seizure.",
                "Clear the area of sharp objects.",
                "Dim lights and keep sounds minimal.",
                "Time the seizure.",
                "After seizure: keep cat warm, speak softly, do not touch face.",
                "Note any potential triggers (toxins, stress, trauma).",
                "Rush to vet — especially for first-time seizures."
            ],
            warningSigns: ["Muscle twitching", "Loss of consciousness", "Paddling movements", "Temporary blindness after episode", "Excessive drooling"],
            callVetWhen: "Any seizure over 2 minutes or multiple in 24 hours."
        ),
        EmergencyCategory(
            name: "Bleeding",
            icon: "drop.fill",
            color: "#CC0000",
            description: "Cat has a wound with continuous blood loss.",
            steps: [
                "Apply firm pressure with a clean gauze or cloth.",
                "Hold pressure for at least 5 minutes without lifting the cloth.",
                "Use a bandage to secure the gauze in place.",
                "Avoid touching the wound with bare hands.",
                "Keep the cat calm and immobile.",
                "Transport to vet while maintaining pressure."
            ],
            warningSigns: ["Continuous bleeding", "Pale or white gums", "Rapid breathing", "Weakness"],
            callVetWhen: "Any wound that bleeds for more than 5 minutes continuously."
        )
    ]
    
    // MARK: - Rabbit Guides
    static let rabbitGuides: [EmergencyCategory] = [
        EmergencyCategory(
            name: "GI Stasis",
            icon: "waveform.path.ecg",
            color: "#CC0000",
            description: "Rabbit's digestive system has slowed or stopped — most common rabbit emergency.",
            steps: [
                "This is a MEDICAL EMERGENCY. Go to vet immediately.",
                "Encourage movement gently — rabbits need to move to restart gut.",
                "Offer fresh hay and water — do not force feed.",
                "Gently massage the abdomen in circular motions.",
                "Keep the rabbit warm using a heating pad on low.",
                "Do NOT give human medications or laxatives."
            ],
            warningSigns: ["No droppings for 12+ hours", "Hunched posture", "Teeth grinding", "Refusing all food/water", "Bloated abdomen"],
            callVetWhen: "If rabbit has not produced droppings in 12 hours or is not eating."
        ),
        EmergencyCategory(
            name: "Heatstroke",
            icon: "thermometer.sun.fill",
            color: "#FF6600",
            description: "Rabbits are extremely heat-sensitive and can die quickly from overheating.",
            steps: [
                "Move to a cool area immediately — shade or air conditioning.",
                "Place frozen water bottle wrapped in towel next to the rabbit.",
                "Dampen ears with cool water — major heat exchange area.",
                "Do NOT submerge in water.",
                "Offer cool water to drink if alert.",
                "Rush to vet — heatstroke in rabbits escalates very quickly."
            ],
            warningSigns: ["Limp body", "Labored breathing", "Red/hot ears", "Drooling", "Twitching"],
            callVetWhen: "Immediately — rabbits can die within 30 minutes of heatstroke."
        ),
        EmergencyCategory(
            name: "Injury / Fracture",
            icon: "bandage.fill",
            color: "#0066CC",
            description: "Rabbit bones are fragile — fractures can occur from falls or rough handling.",
            steps: [
                "Handle as little as possible — fractured spines can cause paralysis.",
                "Place rabbit in a padded, secure carrier.",
                "Keep warm and dark to reduce stress.",
                "Do not attempt to straighten or splint at home.",
                "Go directly to a rabbit-savvy vet."
            ],
            warningSigns: ["Dragging hind limbs", "Unable to hop", "Visible bone", "Crying or grinding teeth in pain"],
            callVetWhen: "Immediately. Rabbit spinal injuries are often irreversible if delayed."
        ),
        EmergencyCategory(
            name: "Breathing Issues",
            icon: "lungs.fill",
            color: "#FF4444",
            description: "Rabbits are obligate nasal breathers — any breathing problem is serious.",
            steps: [
                "Keep rabbit calm and upright — do not lay flat.",
                "Move to fresh, well-ventilated area.",
                "Do NOT administer anything by mouth.",
                "Check nostrils for discharge — gently clear with damp cloth.",
                "Rush to vet — do not wait to see if it improves."
            ],
            warningSigns: ["Mouth breathing", "Nasal discharge", "Head tilt", "Cyanotic gums", "Wheezing"],
            callVetWhen: "Immediately — breathing difficulties in rabbits are rapidly fatal."
        )
    ]
    
    // MARK: - Bird Guides
    static let birdGuides: [EmergencyCategory] = [
        EmergencyCategory(
            name: "Trauma / Injury",
            icon: "bandage.fill",
            color: "#CC0000",
            description: "Bird has been injured — by cat/dog attack, window strike, or fall.",
            steps: [
                "Wear gloves — even small birds can bite when in pain.",
                "Place bird in a dark, ventilated box lined with clean paper towel.",
                "Keep at 25–30°C — use a heating pad under half the box.",
                "Do NOT offer food or water unless vet-advised (aspiration risk).",
                "Keep box away from pets and minimize handling.",
                "Transport to an avian vet as soon as possible."
            ],
            warningSigns: ["Inability to fly or perch", "Drooping wing", "Bleeding", "Sitting on bottom of cage", "Eyes closed"],
            callVetWhen: "Immediately after any physical trauma."
        ),
        EmergencyCategory(
            name: "Breathing Difficulty",
            icon: "lungs.fill",
            color: "#FF4444",
            description: "Bird is struggling to breathe — a critical emergency.",
            steps: [
                "Remove from any fumes, smoke, or aerosols immediately.",
                "Move to fresh air.",
                "Keep bird upright and calm.",
                "Do NOT use aerosols, non-stick cookware fumes, or candles near birds.",
                "Rush to avian vet immediately."
            ],
            warningSigns: ["Tail bobbing while breathing", "Open-mouth breathing", "Clicking sounds", "Fluffed feathers with lethargy"],
            callVetWhen: "Immediately — birds mask illness and deteriorate without warning."
        ),
        EmergencyCategory(
            name: "Poisoning",
            icon: "exclamationmark.triangle.fill",
            color: "#FF8800",
            description: "Bird may have ingested or inhaled toxic substances.",
            steps: [
                "Move bird away from the source of toxin.",
                "Identify the toxin — take note or photo.",
                "Fresh air immediately if fume exposure.",
                "Call avian vet or poison control.",
                "Keep bird warm and calm.",
                "Do NOT induce vomiting."
            ],
            warningSigns: ["Sudden collapse", "Seizures", "Vomiting", "Loss of coordination", "Labored breathing"],
            callVetWhen: "Immediately — birds are highly sensitive to airborne toxins."
        )
    ]
    
    // MARK: - Hamster Guides
    static let hamsterGuides: [EmergencyCategory] = [
        EmergencyCategory(
            name: "Wet Tail (Diarrhea)",
            icon: "exclamationmark.circle.fill",
            color: "#CC0000",
            description: "Bacterial infection causing severe diarrhea — most fatal in young hamsters.",
            steps: [
                "This is a LIFE-THREATENING emergency — go to vet immediately.",
                "Keep hamster warm — place on a heating pad under half the enclosure.",
                "Offer water with oral rehydration solution if drinking.",
                "Remove soiled bedding and clean area gently.",
                "Isolate from other hamsters.",
                "Do NOT delay — wet tail can kill within 24-48 hours."
            ],
            warningSigns: ["Wet tail area", "Diarrhea", "Hunched posture", "Lethargy", "Refusing food"],
            callVetWhen: "Immediately. Every hour matters with wet tail."
        ),
        EmergencyCategory(
            name: "Hibernation / Cold",
            icon: "snowflake",
            color: "#0099CC",
            description: "Hamster may appear dead if too cold — it could be hibernating.",
            steps: [
                "Check carefully — hamsters in torpor breathe very slowly.",
                "Warm gradually — hold in your hands or place on a warm (not hot) surface.",
                "Move to a warm room — target 20°C / 68°F.",
                "Offer warm water through a dropper if conscious.",
                "Do NOT use a hairdryer or heat lamp.",
                "If not responding after 30 minutes of warming, seek vet care."
            ],
            warningSigns: ["Stiff body", "No apparent breathing", "Cold to touch", "Pale gums"],
            callVetWhen: "If no response to warming after 30 minutes."
        ),
        EmergencyCategory(
            name: "Injury / Fall",
            icon: "bandage.fill",
            color: "#0066CC",
            description: "Hamster has fallen from height or is showing signs of internal injury.",
            steps: [
                "Place in a safe, calm enclosure with minimal objects.",
                "Check for external wounds — apply gentle pressure with clean cloth if bleeding.",
                "Do NOT manipulate limbs.",
                "Keep warm and quiet.",
                "Do not offer food immediately.",
                "Seek vet care promptly."
            ],
            warningSigns: ["Limping", "Paralysis of hind limbs", "Visible wounds", "Lethargy after fall"],
            callVetWhen: "Any fall from height — internal bleeding is difficult to detect."
        )
    ]
    
    // MARK: - Fish Guides
    static let fishGuides: [EmergencyCategory] = [
        EmergencyCategory(
            name: "Water Quality Crisis",
            icon: "drop.fill",
            color: "#0099CC",
            description: "Sudden tank water quality change causing fish distress.",
            steps: [
                "Immediately test water for ammonia, nitrite, pH, and temperature.",
                "Do a 25-30% water change with dechlorinated water at the same temperature.",
                "Check that the filter is running properly.",
                "Remove any dead fish or uneaten food immediately.",
                "Add aquarium detoxifying agents if ammonia levels are high.",
                "Do not overfeed during recovery.",
                "Monitor fish closely for 24 hours."
            ],
            warningSigns: ["Fish gasping at surface", "Fish at bottom not moving", "Loss of color", "Erratic swimming", "Clamped fins"],
            callVetWhen: "If fish continue to show distress after water change — seek aquatic vet."
        ),
        EmergencyCategory(
            name: "Disease / Infection",
            icon: "cross.circle.fill",
            color: "#CC6600",
            description: "Fish showing signs of bacterial, fungal, or parasitic infection.",
            steps: [
                "Isolate sick fish in a quarantine tank immediately.",
                "Identify symptoms: white spots (Ich), fin rot, bloating.",
                "Treat with appropriate medication for identified disease.",
                "Increase oxygenation in the quarantine tank.",
                "Monitor water temperature and quality closely.",
                "Do not introduce new fish during treatment."
            ],
            warningSigns: ["White spots on body", "Frayed fins", "Pinecone-like scales (dropsy)", "Ulcers", "Abnormal swimming pattern"],
            callVetWhen: "If symptoms persist after 3-5 days of standard treatment."
        )
    ]
    
    // MARK: - Turtle Guides
    static let turtleGuides: [EmergencyCategory] = [
        EmergencyCategory(
            name: "Respiratory Infection",
            icon: "lungs.fill",
            color: "#FF4444",
            description: "Turtles with respiratory infections often have mucus and swim tilted.",
            steps: [
                "Raise habitat temperature to the higher end of the species' range.",
                "Ensure proper basking temperature — critical for immune function.",
                "Reduce stress by limiting handling.",
                "Isolate from other reptiles.",
                "Do not allow the turtle to get cold.",
                "Seek reptile-specialized vet care."
            ],
            warningSigns: ["Mucus from nose or mouth", "Wheezing or clicking sounds", "Swimming tilted", "Lethargy", "Open-mouth breathing"],
            callVetWhen: "Within 24 hours — respiratory infections require antibiotics."
        ),
        EmergencyCategory(
            name: "Shell Injury",
            icon: "bandage.fill",
            color: "#996633",
            description: "Turtle has a cracked or penetrated shell from trauma.",
            steps: [
                "Rinse the shell crack gently with clean warm saline.",
                "Apply gentle antiseptic (diluted betadine) to exposed areas.",
                "Do NOT use superglue or epoxy.",
                "Keep the turtle warm and calm.",
                "Transport in a padded box lined with damp paper towels.",
                "Rush to reptile vet — shells can be repaired if treated quickly."
            ],
            warningSigns: ["Visible cracks in shell", "Bleeding from shell", "Exposed tissue", "Lethargy"],
            callVetWhen: "Immediately — an injured shell can lead to fatal infection."
        )
    ]
    
    // MARK: - Generic Guides
    static let genericGuides: [EmergencyCategory] = [
        EmergencyCategory(
            name: "Bleeding",
            icon: "drop.fill",
            color: "#CC0000",
            description: "Pet has an open wound with active bleeding.",
            steps: [
                "Apply firm pressure with a clean cloth or gauze.",
                "Maintain pressure for at least 5 minutes.",
                "Do not remove the cloth — layer more on top if soaked.",
                "Keep the pet calm and still.",
                "Transport to a vet immediately."
            ],
            warningSigns: ["Active blood flow", "Pale gums", "Weakness", "Rapid breathing"],
            callVetWhen: "If bleeding doesn't stop within 5 minutes."
        ),
        EmergencyCategory(
            name: "Poisoning",
            icon: "exclamationmark.triangle.fill",
            color: "#FF8800",
            description: "Pet may have ingested a toxic substance.",
            steps: [
                "Identify what was ingested and contact the vet immediately.",
                "Do NOT induce vomiting unless specifically instructed by the vet.",
                "Keep the pet calm and warm.",
                "Bring the toxin/container to the vet."
            ],
            warningSigns: ["Vomiting", "Tremors", "Drooling", "Lethargy", "Collapse"],
            callVetWhen: "Any suspected poisoning — do not wait for symptoms."
        )
    ]
}
