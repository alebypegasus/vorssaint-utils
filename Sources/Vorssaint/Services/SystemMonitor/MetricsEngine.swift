import Foundation

class MetricsEngine {
    static func getPowermetrics() -> String {
        // Warning: Requires sudo
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
        process.arguments = ["powermetrics", "-n", "1", "--samplers", "cpu_power,gpu_power,thermal"]
        let pipe = Pipe()
        process.standardOutput = pipe
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                return output
            }
        } catch {}
        return "Requires sudo to read powermetrics."
    }

    static func getTopAppsInGPU() -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/sudo")
        process.arguments = ["powermetrics", "-n", "1", "--samplers", "tasks"]
        let pipe = Pipe()
        process.standardOutput = pipe
        do {
            try process.run()
            process.waitUntilExit()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                let lines = output.components(separatedBy: .newlines)
                return lines.prefix(50).joined(separator: "\n")
            }
        } catch {}
        return "Requires sudo."
    }
}
