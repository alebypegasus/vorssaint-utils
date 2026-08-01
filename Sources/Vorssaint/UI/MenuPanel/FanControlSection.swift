// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright (C) 2026 Vorssaint

import SwiftUI

struct FanControlSection: View {
    @ObservedObject private var l10n = L10n.shared
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var service = FanControlService(smc: SMCClient())
    var collapsible = true

    var body: some View {
        PanelSection(.fanControl, title: l10n.s.fanControlBetaSection, collapsible: collapsible) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "fanblades.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(PanelMetricColor.cyan(for: colorScheme))
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 6) {
                            Text(l10n.s.fanControlBetaTitle)
                                .font(.system(size: 12, weight: .semibold))
                            Text(l10n.s.betaBadge)
                                .font(.system(size: 8, weight: .bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(PanelMetricColor.cyan(for: colorScheme).opacity(0.16)))
                                .foregroundStyle(PanelMetricColor.cyan(for: colorScheme))
                        }
                        Text(l10n.s.fanControlBetaStatus)
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }

                if service.fans.isEmpty {
                    Text("No fans detected or lacking SMC permission.")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                        .padding(.top, 4)
                } else {
                    ForEach($service.fans) { $fan in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(fan.name).font(.system(size: 11, weight: .medium))
                                Spacer()
                                Text("\(Int(fan.actualSpeed)) RPM").font(.system(size: 11)).monospacedDigit()
                            }
                            Picker("", selection: Binding(
                                get: { fan.isManual ? "manual" : "automatic" },
                                set: { mode in
                                    service.setManualMode(for: fan.id, manual: mode == "manual")
                                }
                            )) {
                                Text(l10n.s.fanControlModeAutomatic).tag("automatic")
                                Text(l10n.s.fanControlModeManual).tag("manual")
                            }
                            .pickerStyle(.segmented)
                            
                            if fan.isManual {
                                Slider(
                                    value: Binding(
                                        get: { fan.targetSpeed },
                                        set: { speed in
                                            service.setTargetSpeed(for: fan.id, speed: speed)
                                        }
                                    ),
                                    in: fan.minSpeed...fan.maxSpeed,
                                    step: 10
                                )
                                HStack {
                                    Text("\(Int(fan.minSpeed))").font(.system(size: 9)).foregroundStyle(.tertiary)
                                    Spacer()
                                    Text("\(Int(fan.maxSpeed))").font(.system(size: 9)).foregroundStyle(.tertiary)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                }
            }
            .panelCard()
            .onAppear {
                service.refresh()
            }
        }
    }
}
