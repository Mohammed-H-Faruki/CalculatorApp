import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var networkService: NetworkService
    @EnvironmentObject var settingsManager: SettingsManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Status Header
                    statusHeader
                    
                    // Main Data Cards
                    HStack(spacing: 16) {
                        DataCard(
                            title: "pH Level",
                            value: networkService.isOnline ? String(format: "%.2f", networkService.currentData?.ph ?? 0) : "--",
                            unit: "",
                            icon: "testtube.2",
                            color: networkService.isOnline ? AppTheme.statusColor(for: networkService.currentData?.status ?? "") : AppTheme.offlineColor
                        )
                        
                        DataCard(
                            title: "Turbidity",
                            value: networkService.isOnline ? "\(networkService.currentData?.turbidity ?? 0)" : "--",
                            unit: "NTU",
                            icon: "aqi.medium",
                            color: networkService.isOnline ? AppTheme.statusColor(for: networkService.currentData?.status ?? "") : AppTheme.offlineColor
                        )
                    }
                    .padding(.horizontal)
                    
                    // Detailed Info Card
                    if networkService.isOnline, let data = networkService.currentData {
                        VStack(spacing: 12) {
                            DetailRow(title: "Status", value: data.status, valueColor: AppTheme.statusColor(for: data.status))
                            Divider()
                            DetailRow(title: "Raw pH", value: "\(data.phRaw)")
                            Divider()
                            DetailRow(title: "pH Voltage", value: String(format: "%.3f V", data.phVoltage))
                        }
                        .padding()
                        .glassCard()
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
            .navigationTitle("Dashboard")
            .background(Color(.systemGroupedBackground))
            .refreshable {
                networkService.fetchData()
            }
        }
    }
    
    @ViewBuilder
    private var statusHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Circle()
                    .fill(networkService.isOnline ? Color.green : Color.red)
                    .frame(width: 12, height: 12)
                    .shadow(color: networkService.isOnline ? .green : .red, radius: 4)
                
                Text(networkService.isOnline ? "Connected" : "Device Offline")
                    .font(.headline)
                    .foregroundColor(networkService.isOnline ? .primary : .red)
            }
            
            if !networkService.isOnline {
                Button(action: {
                    networkService.fetchData()
                }) {
                    Text("Reconnect")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(AppTheme.accent)
                        .clipShape(Capsule())
                }
                .padding(.top, 4)
            } else if let lastUpdated = networkService.lastUpdated {
                Text("Last updated: \(lastUpdated.formatted(date: .omitted, time: .standard))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .glassCard()
        .padding(.horizontal)
    }
}

// MARK: - Helper Views

struct DataCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(value)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(color)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    
                    if !unit.isEmpty {
                        Text(unit)
                            .font(.callout.bold())
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .glassCard()
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
                .foregroundColor(valueColor)
        }
        .font(.subheadline)
    }
}
