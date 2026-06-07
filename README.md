# 🌌 KreaFlow

> A high-end, glassmorphic creatine tracker & gym log app built with Flutter. Engineered to assist athletes in maintaining creatine saturation, monitoring hydration, logging workouts, and tracking bodyweight evolution with visual excellence.

---

## ✨ Features

### 1. 📊 Dashboard (The Command Center)
- **Creatine Saturation Ring**: High-contrast, dynamic tracker indicating current intake vs. daily goal (e.g. 5g loading/maintenance).
- **Interactive Hydration Wave**: Smooth wave indicator emphasizing water intake, critical for optimal creatine synthesis.
- **Daily Muscle Checklist**: A unified daily checklist tracking Creatine, Water, Weight log, and Workouts.
- **Streak & Consistency HUD**: Track consecutive days of compliance.

### 2. 🏋️ Gym & Weight Analytics
- **Weight Journey Line Graph**: Smooth, gradient-filled bezier line charts plotting your body weight trends over time (powered by `fl_chart`).
- **Granular Workout Logger**: Add gym sessions categorized by workout type (Strength, Hypertrophy, Cardio, Active Recovery) with time trackers and custom notes.

### 3. 🗓️ Saturation Grid (Heatmap)
- **21-Day Contribution Map**: Beautiful GitHub-inspired heatmap grid displaying complete, partial, or missed goals for both creatine and hydration tracking over a rolling 3-week window.
- **Chronological Logs**: Fully browsable historical cards showing date and time stamps of every intake.

### 4. ⚙️ Customize & Science
- **Goal Configuration**: Real-time adjustment sliders for daily target parameters.
- **Creatine Science Reference**: Built-in micro-guide breaking down standard dosage patterns (loading phase vs. maintenance phase), benefits, and common misconceptions.

---

## 🎨 Visual Identity & Architecture
- **Aesthetic**: Modern Cyber-dark mode with neon glows (Cyan: Creatine, Magenta: Gym/Weights, Green: Recovery, Amber: Settings).
- **State Management**: Performance-focused, lightweight `InheritedNotifier` architecture with `AppStateProvider` for instant updates and reactive UI rebuilds.
- **Persistence**: Powered by `shared_preferences` for fast local caching.

---

## 🚀 Quick Start

### Prerequisites
Make sure you have Flutter and Dart installed on your machine.
- **Flutter SDK**: `^3.0.0` or higher
- **Dart SDK**: `^3.0.0` or higher

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/MaherMir/KreaFlow.git
   cd KreaFlow
   ```

2. Get dependency packages:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   # Running on connected devices (Mobile/Web/Desktop)
   flutter run
   ```

4. Build production Web release:
   ```bash
   flutter build web --release
   ```

---

## 📦 Project Structure
```tree
lib/
├── main.dart             # Application bootstrap & Theme setup
├── models/
│   ├── creatine_log.dart  # Data model for creatine logs
│   ├── hydration_log.dart # Data model for hydration logs
│   ├── weight_log.dart    # Data model for weight history
│   └── workout_log.dart   # Data model for gym session tracking
├── state/
│   └── app_state.dart     # InheritedNotifier central state management
└── screens/
    ├── main_navigation.dart # Sleek bottom navigation bar & layout wrapper
    ├── dashboard_screen.dart # Interactive creatine ring and water logs
    ├── gym_screen.dart       # Interactive weight charts & session logger
    ├── history_screen.dart   # 21-Day consistency map & calendar logs
    └── settings_screen.dart  # Goal sliders & Science guide
```

---

## 🛠️ Tech Stack & Packages
- **Framework**: Flutter (Dart)
- **Charting**: `fl_chart`
- **Fonts**: `google_fonts` (Outfit & Inter)
- **Utility**: `intl`, `shared_preferences`
