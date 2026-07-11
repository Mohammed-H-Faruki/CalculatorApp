import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("ESP32 Connection")) {
                    HStack {
                        Text("IP Address")
                        Spacer()
                        TextField("192.168.4.1", text: $settings.espIP)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Port")
                        Spacer()
                        TextField("80", text: $settings.espPort)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Data Collection"), footer: Text("How often the app requests new data from the sensor.")) {
                    HStack {
                        Text("Polling Interval (ms)")
                        Spacer()
                        TextField("1000", value: $settings.pollingInterval, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("Appearance")) {
                    Picker("Theme", selection: $settings.themeMode) {
                        Text("System Default").tag("system")
                        Text("Light Mode").tag("light")
                        Text("Dark Mode").tag("dark")
                    }
                }
                
                Section {
                    Button(action: {
                        settings.restoreDefaults()
                    }) {
                        Text("Restore Defaults")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
