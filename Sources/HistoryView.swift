import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var searchText = ""
    @State private var sortAscending = false
    @State private var showingClearConfirm = false
    
    var filteredReadings: [Reading] {
        var result = dataStore.readings
        
        if !searchText.isEmpty {
            result = result.filter { reading in
                reading.status.localizedCaseInsensitiveContains(searchText) ||
                String(format: "%.2f", reading.ph).contains(searchText) ||
                "\(reading.turbidity)".contains(searchText)
            }
        }
        
        if sortAscending {
            result.sort { $0.date < $1.date }
        } else {
            result.sort { $0.date > $1.date } // Default: newest first
        }
        
        return result
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredReadings) { reading in
                    HistoryRow(reading: reading)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .padding(.vertical, 4)
                }
            }
            .listStyle(.plain)
            .background(Color(.systemGroupedBackground))
            .searchable(text: $searchText, prompt: "Search status, pH, or turbidity")
            .navigationTitle("History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            sortAscending.toggle()
                        } label: {
                            Label(sortAscending ? "Sort Newest First" : "Sort Oldest First", systemImage: "arrow.up.arrow.down")
                        }
                        
                        Button(role: .destructive) {
                            showingClearConfirm = true
                        } label: {
                            Label("Clear History", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert("Clear History", isPresented: $showingClearConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    dataStore.clearHistory()
                }
            } message: {
                Text("Are you sure you want to delete all stored readings? This cannot be undone.")
            }
        }
    }
}

struct HistoryRow: View {
    let reading: Reading
    
    var body: some View {
        HStack(spacing: 16) {
            // Status Indicator
            Circle()
                .fill(AppTheme.statusColor(for: reading.status))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(reading.date.formatted(date: .abbreviated, time: .standard))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 16) {
                    Label(String(format: "%.2f", reading.ph), systemImage: "testtube.2")
                    Label("\(reading.turbidity) NTU", systemImage: "aqi.medium")
                }
                .font(.subheadline.bold())
            }
            
            Spacer()
            
            Text(reading.status)
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.statusColor(for: reading.status).opacity(0.1))
                .foregroundColor(AppTheme.statusColor(for: reading.status))
                .clipShape(Capsule())
        }
        .padding()
        .glassCard()
    }
}
