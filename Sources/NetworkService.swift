import Foundation
import Combine

// MARK: - Network Service

class NetworkService: ObservableObject {
    @Published var currentData: SensorData?
    @Published var isOnline: Bool = false
    @Published var lastUpdated: Date?
    
    private var settingsManager: SettingsManager?
    private var timer: Timer?
    
    func configure(settings: SettingsManager) {
        self.settingsManager = settings
        
        // Listen for setting changes to restart polling if interval changes
        settings.$pollingInterval
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.restartTimer()
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var dataStore: DataStore?
    
    func startPolling(dataStore: DataStore) {
        self.dataStore = dataStore
        restartTimer()
        fetchData() // Initial fetch
    }
    
    func stopPolling() {
        timer?.invalidate()
        timer = nil
    }
    
    private func restartTimer() {
        stopPolling()
        guard let settings = settingsManager else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: settings.pollingSeconds, repeats: true) { [weak self] _ in
            self?.fetchData()
        }
    }
    
    func fetchData() {
        guard let settings = settingsManager,
              let url = URL(string: settings.dataURL) else { return }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = max(1.0, settings.pollingSeconds - 0.2) // Give it time to fail before next poll
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Network error
                    self?.isOnline = false
                    print("Network error: \(error.localizedDescription)")
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode),
                      let data = data else {
                    // Server error
                    self?.isOnline = false
                    return
                }
                
                do {
                    let decodedData = try JSONDecoder().decode(SensorData.self, from: data)
                    self?.currentData = decodedData
                    self?.isOnline = true
                    self?.lastUpdated = Date()
                    self?.dataStore?.addReading(decodedData)
                } catch {
                    // Parse error
                    self?.isOnline = false
                    print("JSON Parse error: \(error)")
                }
            }
        }.resume()
    }
}
