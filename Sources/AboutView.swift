import SwiftUI

struct AboutView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    
                    // App Icon / Logo Area
                    ZStack {
                        Circle()
                            .fill(AppTheme.primaryGradient)
                            .frame(width: 120, height: 120)
                            .shadow(color: AppTheme.accent.opacity(0.5), radius: 20, y: 10)
                        
                        Image(systemName: "drop.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 40)
                    
                    // Title
                    VStack(spacing: 8) {
                        Text("Water Monitoring System")
                            .font(.title2.bold())
                        
                        Text("Science Project")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Description
                    Text("This project monitors irrigation water quality using an ESP32 connected to a pH sensor and a turbidity sensor. It provides real-time data to ensure water safety for agricultural use.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 32)
                        .lineSpacing(4)
                    
                    // Credits Card
                    VStack(spacing: 16) {
                        Text("Made by")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Mukarram Farooqi")
                            .font(.title3.bold())
                        
                        Text("Grade 7A")
                            .font(.headline)
                            .foregroundColor(AppTheme.accent)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(AppTheme.accent.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    .padding(32)
                    .frame(maxWidth: .infinity)
                    .glassCard()
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
            }
            .navigationTitle("About")
            .background(Color(.systemGroupedBackground))
        }
    }
}
