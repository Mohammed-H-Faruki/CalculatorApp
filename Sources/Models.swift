import Foundation

// MARK: - ESP32 Sensor Response

struct SensorData: Codable {
    let deviceName: String
    let version: String
    let ph: Double
    let phRaw: Int
    let phVoltage: Double
    let turbidity: Int
    let status: String
    let safe: Bool
    let timestamp: Int
}

// MARK: - Stored Reading

struct Reading: Codable, Identifiable {
    let id: UUID
    let date: Date
    let ph: Double
    let turbidity: Int
    let status: String

    init(from sensorData: SensorData) {
        self.id = UUID()
        self.date = Date()
        self.ph = sensorData.ph
        self.turbidity = sensorData.turbidity
        self.status = sensorData.status
    }

    init(id: UUID = UUID(), date: Date = Date(), ph: Double, turbidity: Int, status: String) {
        self.id = id
        self.date = date
        self.ph = ph
        self.turbidity = turbidity
        self.status = status
    }
}

// MARK: - Time Period for Analytics

enum TimePeriod: String, CaseIterable {
    case lastHour = "Last Hour"
    case today = "Today"
    case thisWeek = "This Week"
}
