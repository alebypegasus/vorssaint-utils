// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import Foundation

struct FanStatus: Identifiable {
    var id: Int
    var name: String
    var actualSpeed: Double
    var minSpeed: Double
    var maxSpeed: Double
    var targetSpeed: Double
    var isManual: Bool
}

final class FanControlService: ObservableObject {
    @Published var fans: [FanStatus] = []
    
    private let smc: SMCClient?
    
    init(smc: SMCClient?) {
        self.smc = smc
        refresh()
    }
    
    func refresh() {
        let output = FanControl.getStatus()
        if output.contains("No fans detected") || output.contains("Could not read") || output.contains("Total fans in system: 0") {
            DispatchQueue.main.async { self.fans = [] }
            return
        }
        
        var currentFans: [FanStatus] = []
        var currentFan: FanStatus?
        
        for line in output.components(separatedBy: .newlines) {
            let l = line.trimmingCharacters(in: .whitespaces)
            if l.hasPrefix("Fan #") {
                if let f = currentFan { currentFans.append(f) }
                let idStr = l.replacingOccurrences(of: "Fan #", with: "").replacingOccurrences(of: ":", with: "")
                currentFan = FanStatus(id: Int(idStr) ?? 0, name: "Fan \(idStr)", actualSpeed: 0, minSpeed: 0, maxSpeed: 0, targetSpeed: 0, isManual: false)
            } else if l.hasPrefix("Fan ID") {
                let parts = l.components(separatedBy: ":")
                if parts.count > 1, currentFan != nil { currentFan?.name = parts[1].trimmingCharacters(in: .whitespaces) }
            } else if l.hasPrefix("Current speed") {
                let parts = l.components(separatedBy: ":")
                if parts.count > 1, currentFan != nil { currentFan?.actualSpeed = Double(parts[1].trimmingCharacters(in: .whitespaces)) ?? 0 }
            } else if l.hasPrefix("Minimum speed") {
                let parts = l.components(separatedBy: ":")
                if parts.count > 1, currentFan != nil { currentFan?.minSpeed = Double(parts[1].trimmingCharacters(in: .whitespaces)) ?? 0 }
            } else if l.hasPrefix("Maximum speed") {
                let parts = l.components(separatedBy: ":")
                if parts.count > 1, currentFan != nil { currentFan?.maxSpeed = Double(parts[1].trimmingCharacters(in: .whitespaces)) ?? 0 }
            } else if l.hasPrefix("Target speed") {
                let parts = l.components(separatedBy: ":")
                if parts.count > 1, currentFan != nil { currentFan?.targetSpeed = Double(parts[1].trimmingCharacters(in: .whitespaces)) ?? 0 }
            } else if l.hasPrefix("Mode") {
                let parts = l.components(separatedBy: ":")
                if parts.count > 1, currentFan != nil { currentFan?.isManual = parts[1].trimmingCharacters(in: .whitespaces).lowercased() == "forced" }
            }
        }
        if let f = currentFan { currentFans.append(f) }
        
        DispatchQueue.main.async {
            self.fans = currentFans
        }
    }
    
    func setManualMode(for fanId: Int, manual: Bool) {
        if manual {
            _ = FanControl.setMode("maximo")
        } else {
            _ = FanControl.setMode("auto")
        }
        refresh()
    }
    
    func setTargetSpeed(for fanId: Int, speed: Double) {
        _ = FanControl.setMode(String(Int(speed)))
        refresh()
    }
}
