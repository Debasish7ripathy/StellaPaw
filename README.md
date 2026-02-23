# 🐾 StellaPaw

**StellaPaw** is an intelligent, all-in-one pet health & wellness iOS app built with SwiftUI. It combines on-device AI, CoreML predictions, and a beautiful interface to help pet owners track nutrition, activity, hydration, medical records, and more — for dogs, cats, rabbits, hamsters, birds, fish, turtles, and beyond.

---

## ✨ Features

### 📊 Dashboard
- At-a-glance daily progress rings for **calories, activity, and hydration**
- Smart **anomaly detection** alerts when patterns look unusual
- Upcoming vet appointment banners with countdown
- Pet switcher for multi-pet households

### 🍽️ Nutrition Engine
- Species- and age-aware **meal recommendations** from a curated database
- Meal type filtering (breakfast, lunch, dinner, snack)
- Calorie tracking with daily goal progress
- Hydration monitoring widget

### 🏃 Activity Tracking
- **CoreML-powered predictions** for recommended daily calories, activity distance, and water intake
- Confidence levels (High / Medium / Low) based on data history
- Smart insights generated from pet profile and activity trends
- Prediction insight cards with actionable tips

### 🧠 Petora — AI Health Chat
- On-device AI assistant powered by **Apple FoundationModels** (Apple Intelligence, iOS 26+)
- Ask health questions about your pet and get contextual answers
- Intelligent **rule-based fallback** on unsupported devices
- AI-powered anomaly explanations

### 🚨 Emergency Care
- Species-specific **first-aid guides** for common emergencies
- Emergency contact management with quick-dial
- Clear, step-by-step emergency instructions

### 🎵 Calm & Sounds
- Ambient sound player with **rain, forest breeze, heartbeat, soft piano, and white noise**
- Timer-based sessions for pet relaxation
- Breathing circle animation for guided calm moments

### 📈 Analytics
- **7-day trend charts** for activity, hydration, and calorie progress
- Consistency scoring and streak tracking
- Milestone achievements for pets
- Weekly analytics snapshots

### 🏥 Medical Records
- Vet appointment scheduling with reminders
- Medication tracking with dosage and frequency
- Medical record history
- Pet milestone logging

### 🎨 Theming
- Light / Dark / System theme modes
- Vibrant coral-based color palette with semantic colors
- Smooth animations and modern UI components

---

## 🏗️ Architecture

```
StellaPaw/
├── App/                  # App entry point & global state
├── Models/               # Data models (PetProfile, FoodItem, Medication, etc.)
├── ViewModels/           # MVVM view models for each feature
├── Views/                # SwiftUI views for all screens
├── Components/           # Reusable UI components (Theme, ProgressRing, etc.)
├── Engines/              # Business logic & AI engines
│   ├── AIHealthEngine        # On-device LLM via FoundationModels
│   ├── ActivityPredictionEngine  # CoreML activity predictions
│   ├── NutritionEngine       # Meal recommendation logic
│   ├── AnomalyDetector       # Health anomaly detection
│   ├── AnalyticsEngine       # Trend & consistency calculations
│   ├── AudioManager          # Ambient sound playback
│   ├── DataManager           # Persistence layer
│   └── NotificationManager   # Local notification scheduling
├── Assets/               # Audio files, JSON databases, images
└── ActivityPredictor.mlmodel  # CoreML model for activity predictions
```

---

## 🔧 Requirements

- **Xcode 16+**
- **iOS 17.0+** (iOS 26+ for Apple Intelligence features)
- Swift 5.9+

---

## 🚀 Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/Debasish7ripathy/StellaPaw.git
   cd StellaPaw
   ```

2. **Open in Xcode**
   ```bash
   open sweetanimals.xcodeproj
   ```
   > The project is self-contained — no external dependencies or package managers required.

3. **Build & Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

---

## 🐕 Supported Pets

| Species | Icon |
|---------|------|
| Dog     | 🐶   |
| Cat     | 🐱   |
| Rabbit  | 🐰   |
| Hamster | 🐹   |
| Bird    | 🐦   |
| Fish    | 🐟   |
| Turtle  | 🐢   |
| Other   | 🐾   |

---

## 📄 License

This project is open source. See the [LICENSE](LICENSE) file for details.

---

<p align="center">
  Made with ❤️ for pets everywhere
</p>
