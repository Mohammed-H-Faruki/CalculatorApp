import Foundation
import Combine

// MARK: - Data Store

class DataStore: ObservableObject {
    @Published var readings: [Reading] = []
    
    private let maxReadings = 1000
    private let saveKey = "saved_readings"
    
    init() {
        loadData()
    }
    
    func addReading(_ data: SensorData) {
        let newReading = Reading(from: data)
        
        DispatchQueue.main.async {
            self.readings.insert(newReading, at: 0)
            
            if self.readings.count > self.maxReadings {
                self.readings = Array(self.readings.prefix(self.maxReadings))
            }
            
            self.saveData()
        }
    }
    
    func clearHistory() {
        DispatchQueue.main.async {
            self.readings.removeAll()
            self.saveData()
        }
    }
    
    private func saveData() {
        DispatchQueue.global(qos: .background).async {
            if let encoded = try? JSONEncoder().encode(self.readings) {
                UserDefaults.standard.set(encoded, forKey: self.saveKey)
            }
        }
    }
    
    private func loadData() {
        if let savedData = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Reading].self, from: savedData) {
            self.readings = decoded
        }
    }
}
