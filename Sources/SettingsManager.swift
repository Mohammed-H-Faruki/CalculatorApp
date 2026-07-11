import SwiftUI
import Combine

// MARK: - Settings Manager

class SettingsManager: ObservableObject {
    @Published var espIP: String = "192.168.4.1"
    @Published var espPort: String = "80"
    @Published var pollingInterval: Double = 1000
    @Published var themeMode: String = "system"

    private var cancellables = Set<AnyCancellable>()

    var baseURL: String { "http://\(espIP):\(espPort)" }
    var dataURL: String { "\(baseURL)/data" }
    var pollingSeconds: TimeInterval { pollingInterval / 1000.0 }

    var colorScheme: ColorScheme? {
        switch themeMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

    init() {
        loadSettings()
        setupAutoSave()
    }

    private func loadSettings() {
        let d = UserDefaults.standard
        if let ip = d.string(forKey: "esp32_ip") { espIP = ip }
        if let port = d.string(forKey: "esp32_port") { espPort = port }
        if d.object(forKey: "polling_interval") != nil {
            pollingInterval = d.double(forKey: "polling_interval")
        }
        if let theme = d.string(forKey: "theme_mode") { themeMode = theme }
    }

    private func setupAutoSave() {
        let d = UserDefaults.standard
        $espIP.dropFirst().sink { d.set($0, forKey: "esp32_ip") }.store(in: &cancellables)
        $espPort.dropFirst().sink { d.set($0, forKey: "esp32_port") }.store(in: &cancellables)
        $pollingInterval.dropFirst().sink { d.set($0, forKey: "polling_interval") }.store(in: &cancellables)
        $themeMode.dropFirst().sink { d.set($0, forKey: "theme_mode") }.store(in: &cancellables)
    }

    func restoreDefaults() {
        espIP = "192.168.4.1"
        espPort = "80"
        pollingInterval = 1000
        themeMode = "system"
    }
}
