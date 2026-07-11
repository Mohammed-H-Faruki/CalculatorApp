import SwiftUI

// MARK: - Main Tab View

struct MainTabView: View {
    var body: some Scene {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "drop.fill")
                }
            
            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.xyaxis.line")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.fill")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle.fill")
                }
        }
        .tint(AppTheme.accent)
    }
}
