import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var selectedPeriod: TimePeriod = .lastHour
    
    var filteredReadings: [Reading] {
        let now = Date()
        return dataStore.readings.filter { reading in
            switch selectedPeriod {
            case .lastHour:
                return now.timeIntervalSince(reading.date) <= 3600
            case .today:
                return Calendar.current.isDateInToday(reading.date)
            case .thisWeek:
                // Simple 7 day lookback
                return now.timeIntervalSince(reading.date) <= (7 * 24 * 3600)
            }
        }.sorted { $0.date < $1.date }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Time Period Picker
                    Picker("Time Period", selection: $selectedPeriod) {
                        ForEach(TimePeriod.allCases, id: \.self) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    if filteredReadings.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "chart.xyaxis.line")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary.opacity(0.5))
                            Text("No data available for \(selectedPeriod.rawValue.lowercased())")
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .glassCard()
                        .padding(.horizontal)
                    } else {
                        // pH Chart
                        ChartCard(
                            title: "pH History",
                            data: filteredReadings,
                            valueKeyPath: \.ph,
                            color: AppTheme.accent,
                            yAxisDomain: 0...14
                        )
                        
                        // Turbidity Chart
                        ChartCard(
                            title: "Turbidity History (NTU)",
                            data: filteredReadings,
                            valueKeyPath: \.turbidity,
                            color: AppTheme.accentSecondary,
                            yAxisDomain: nil
                        )
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
            .navigationTitle("Analytics")
            .background(Color(.systemGroupedBackground))
        }
    }
}

// MARK: - Chart Card

struct ChartCard<T: Plottable & Numeric & Comparable>: View {
    let title: String
    let data: [Reading]
    let valueKeyPath: KeyPath<Reading, T>
    let color: Color
    let yAxisDomain: ClosedRange<T>?
    
    var minVal: T? { data.map { $0[keyPath: valueKeyPath] }.min() }
    var maxVal: T? { data.map { $0[keyPath: valueKeyPath] }.max() }
    var latestVal: T? { data.last?[keyPath: valueKeyPath] }
    
    // Calculate average safely
    var avgVal: Double? {
        guard !data.isEmpty else { return nil }
        let sum = data.reduce(0.0) { result, reading in
            let val = reading[keyPath: valueKeyPath]
            if let d = val as? Double { return result + d }
            if let i = val as? Int { return result + Double(i) }
            return result
        }
        return sum / Double(data.count)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
            
            // Stats Row
            HStack(spacing: 12) {
                StatItem(label: "Min", value: format(minVal))
                StatItem(label: "Max", value: format(maxVal))
                StatItem(label: "Avg", value: String(format: "%.1f", avgVal ?? 0.0))
                StatItem(label: "Latest", value: format(latestVal))
            }
            
            // The Chart
            Group {
                if let domain = yAxisDomain {
                    chartView.chartYScale(domain: domain)
                } else {
                    chartView
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .glassCard()
        .padding(.horizontal)
    }
    
    private var chartView: some View {
        Chart {
            ForEach(data) { reading in
                LineMark(
                    x: .value("Time", reading.date),
                    y: .value("Value", reading[keyPath: valueKeyPath])
                )
                .foregroundStyle(color.gradient)
                .interpolationMethod(.monotone)
                
                AreaMark(
                    x: .value("Time", reading.date),
                    y: .value("Value", reading[keyPath: valueKeyPath])
                )
                .foregroundStyle(color.opacity(0.1).gradient)
                .interpolationMethod(.monotone)
            }
        }
        .frame(height: 200)
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4))
        }
    }
    
    private func format(_ value: T?) -> String {
        guard let value = value else { return "--" }
        if let d = value as? Double {
            return String(format: "%.1f", d)
        }
        return "\(value)"
    }
}

struct StatItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline.bold())
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
