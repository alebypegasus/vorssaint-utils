// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import AppKit

Defaults.register()

if CommandLine.arguments.contains("--selftest") {
    SelfTest.runAndExit()
}
if CommandLine.arguments.contains("--sensors") {
    SensorDump.runAndExit()
}
if CommandLine.arguments.contains("--uninstall") {
    Uninstaller.runAndExit()
}

func printHeader(_ title: String) {
    print("\n========================================")
    print(" \(title)")
    print("========================================\n")
}

let args = CommandLine.arguments
if let fanIndex = args.firstIndex(of: "--fan"), fanIndex + 1 < args.count {
    let mode = args[fanIndex + 1]
    printHeader("Setting Fan Mode: \(mode)")
    print(FanControl.setMode(mode))
    print("\n" + FanControl.getStatus())
    exit(0)
}

if CommandLine.arguments.contains("--monitor") {
    printHeader("MacSysMonitor - Detailed Hardware Info")
    printHeader("Uptime")
    print(HardwareInfo.getUptime())
    printHeader("Memory Info")
    print(HardwareInfo.getMemoryInfo())
    printHeader("Storage Info")
    print(HardwareInfo.getStorageInfo())
    printHeader("Battery Info")
    print(HardwareInfo.getBatteryInfo())
    printHeader("Network Info")
    print(HardwareInfo.getNetworkInfo())
    printHeader("CPU & GPU Metrics (Requires Sudo)")
    print(MetricsEngine.getPowermetrics())
    printHeader("Top Apps using GPU/Tasks (Requires Sudo)")
    print(MetricsEngine.getTopAppsInGPU())
    printHeader("Fan Control Status")
    print(FanControl.getStatus())
    exit(0)
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
