import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView(selection: $appState.selectedTab) {
            DashboardView()
                .tabItem { Label("Dashboard", systemImage: "square.grid.2x2.fill") }
                .tag(AppTab.dashboard)
            
            NutritionView()
                .tabItem { Label("Nutrition", systemImage: "fork.knife") }
                .tag(AppTab.nutrition)
            
            ActivityView()
                .tabItem { Label("Activity", systemImage: "pawprint.fill") }
                .tag(AppTab.activity)
            
            EmergencyCareView()
                .tabItem { Label("Emergency", systemImage: "cross.case.fill") }
                .tag(AppTab.emergency)
            
            PetHealthChatView()
                .tabItem { Label("Petora", systemImage: "brain.head.profile") }
                .tag(AppTab.ai)
            
            SoundsView(isFullScreen: false)
                .tabItem { Label("Calm", systemImage: "moon.stars.fill") }
                .tag(AppTab.sounds)
            
            RecordsView()
                .tabItem { Label("Records", systemImage: "folder.fill") }
                .tag(AppTab.records)
            
            AnalyticsView()
                .tabItem { Label("Analytics", systemImage: "chart.xyaxis.line") }
                .tag(AppTab.analytics)
        }
        .tint(Theme.primary)
        .fullScreenCover(isPresented: $appState.showingCalmMode) {
            SoundsView(isFullScreen: true)
        }
        .sheet(isPresented: $appState.showingAddPetSheet) {
            AddPetSheet(isFirstPet: appState.pets.isEmpty)
        }
    }
}
