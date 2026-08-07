import SwiftUI

struct DeepMetricsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var loading = true
    @State private var metricsData = ""

    var body: some View {
        VStack {
            HStack {
                Text("Relatório Profundo (Hardware & Powermetrics)")
                    .font(.headline)
                Spacer()
                Button("Fechar") {
                    dismiss()
                }
            }
            .padding()

            if loading {
                ProgressView("Coletando métricas profundas e autenticando (TouchID)...")
                    .padding()
            } else {
                ScrollView {
                    Text(metricsData)
                        .font(.system(size: 10, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }
        }
        .frame(width: 600, height: 500)
        .onAppear {
            DispatchQueue.global().async {
                let cpuGpu = runSudoAppleScript(commands: ["/usr/bin/powermetrics -n 1 --samplers cpu_power,gpu_power,thermal,tasks"])
                let battery = HardwareInfo.getBatteryInfo()
                let storage = HardwareInfo.getStorageInfo()
                let network = HardwareInfo.getNetworkInfo()
                
                let result = """
                ================ BATERIA E ENERGIA ================
                \(battery)
                
                ================ ARMAZENAMENTO ================
                \(storage)
                
                ================ REDE ================
                \(network)
                
                ================ CPU/GPU (Sudo) ================
                \(cpuGpu)
                """
                
                DispatchQueue.main.async {
                    self.metricsData = result
                    self.loading = false
                }
            }
        }
    }
    
    private func runSudoAppleScript(commands: [String]) -> String {
        let script = "do shell script \"\(commands.joined(separator: " && "))\" with administrator privileges"
        var error: NSDictionary?
        if let appleScript = NSAppleScript(source: script) {
            let output = appleScript.executeAndReturnError(&error)
            if let err = error {
                return "Error: \(err)"
            }
            return output.stringValue ?? "Success"
        }
        return "AppleScript initialization failed."
    }
}
