import SwiftUI

@main
struct PawTrackApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appState)
                .environmentObject(DashboardViewModel(appState: appState))
                .environmentObject(NutritionViewModel(appState: appState))
                .environmentObject(ActivityViewModel(appState: appState))
                .environmentObject(AnalyticsViewModel(appState: appState))
                .preferredColorScheme(appState.themeMode == .system ? nil : (appState.themeMode == .dark ? .dark : .light))
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    appState.saveToDisk()
                }
                .task {
                    NotificationManager.shared.requestPermission()
                }
                .fullScreenCover(isPresented: Binding<Bool>(
                    get: { !appState.isOnboardingComplete },
                    set: { appState.isOnboardingComplete = !$0 }
                )) {
                    OnboardingView()
                        .environmentObject(appState)
                        .preferredColorScheme(appState.themeMode == .system ? nil : (appState.themeMode == .dark ? .dark : .light))
                        .interactiveDismissDisabled()
                }
        }
    }
}

