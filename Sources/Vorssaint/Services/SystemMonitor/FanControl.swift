import Foundation

class FanControl {
    static var smcPath: String {
        let toolsPath = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Tools/smc_cli").path
        if FileManager.default.fileExists(atPath: toolsPath) {
            return toolsPath
        }
        return URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("smc_cli").path
    }
    
    static func getStatus() -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: smcPath)
        process.arguments = ["-f"]
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
        return "Could not read fan status. Make sure smc_cli is compiled and present."
    }

    static func setMode(_ mode: String) -> String {
        var rpm = 0
        switch mode.lowercased() {
        case "auto", "automatico":
            return setAuto()
        case "max", "maximo":
            rpm = 6500
        case "medio", "medium":
            rpm = 5000
        case "frio", "cold":
            rpm = 5600
        default:
            if let manualRPM = Int(mode) {
                rpm = manualRPM
            } else {
                return "Invalid mode. Use: auto, max, medio, frio, or an exact RPM number (e.g. 4000)."
            }
        }
        
        let smcValue = String(format: "%04x", rpm << 2)
        let cmds = [
            "\"\(smcPath)\" -k \"FS! \" -w 0001",
            "\"\(smcPath)\" -k F0Mn -w \(smcValue)"
        ]
        return runSudoAppleScript(commands: cmds)
    }

    static func setAuto() -> String {
        return runSudoAppleScript(commands: ["\"\(smcPath)\" -k \"FS! \" -w 0000"])
    }

    private static func runSudoAppleScript(commands: [String]) -> String {
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
