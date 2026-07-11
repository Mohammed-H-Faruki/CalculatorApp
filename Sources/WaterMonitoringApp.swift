import SwiftUI

@main
struct WaterMonitoringApp: App {
    @StateObject private var networkService = NetworkService()
    @StateObject private var settingsManager = SettingsManager()
    @StateObject private var dataStore = DataStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(networkService)
                .environmentObject(settingsManager)
                .environmentObject(dataStore)
                .preferredColorScheme(settingsManager.colorScheme)
                .onAppear {
                    networkService.configure(settings: settingsManager)
                    networkService.startPolling(dataStore: dataStore)
                }
        }
    }
}
