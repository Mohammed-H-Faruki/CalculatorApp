import SwiftUI

struct ContentView: View {
    @State private var display = "0"
    @State private var firstValue: Double = 0
    @State private var pendingOp: String?

    let buttons = [
        ["7","8","9","÷"],
        ["4","5","6","×"],
        ["1","2","3","−"],
        ["C","0","=","+"]
    ]

    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Text(display)
                .font(.system(size: 60))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { key in
                        Button(key) { tap(key) }
                            .frame(width: 70, height: 70)
                            .background(Color.gray.opacity(0.3))
                            .font(.title)
                            .cornerRadius(35)
                    }
                }
            }
        }
        .padding()
    }

    func tap(_ key: String) {
        switch key {
        case "C": display = "0"; firstValue = 0; pendingOp = nil
        case "+", "−", "×", "÷":
            firstValue = Double(display) ?? 0
            pendingOp = key
            display = "0"
        case "=":
            let second = Double(display) ?? 0
            switch pendingOp {
            case "+": display = String(firstValue + second)
            case "−": display = String(firstValue - second)
            case "×": display = String(firstValue * second)
            case "÷": display = second != 0 ? String(firstValue / second) : "Error"
            default: break
            }
            pendingOp = nil
        default:
            display = display == "0" ? key : display + key
        }
    }
}
