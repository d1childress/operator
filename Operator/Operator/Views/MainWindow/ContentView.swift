//
//  ContentView.swift
//  Operator
//
//  Main tabbed interface for the application.
//

import SwiftUI
import AppKit

struct ContentView: View {
    @EnvironmentObject var systemMonitor: SystemMonitor
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            // Liquid Glass background
            VisualEffectBackground()

            // Subtle aurora-inspired gradient glow
            AuroraBackground()

            VStack(spacing: 0) {
                // Custom tab bar
                TabBarView(selectedTab: $selectedTab)

                // Tab content
                TabView(selection: $selectedTab) {
                    OverviewView()
                        .tag(0)

                    CPUView()
                        .tag(1)

                    MemoryView()
                        .tag(2)

                    NetworkView()
                        .tag(3)

                    NetworkDiagnosticsView()
                        .tag(4)

                    ProcessesView()
                        .tag(5)

                    BatteryView()
                        .tag(6)

                    HistoryView()
                        .tag(7)
                }
                .tabViewStyle(.automatic)
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .onReceive(NotificationCenter.default.publisher(for: .switchTab)) { notification in
            if let tab = notification.object as? Int {
                withAnimation {
                    selectedTab = tab
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ForceRefresh"))) { _ in
            systemMonitor.forceRefresh()
        }
    }
}

// MARK: - Tab Bar

struct TabBarView: View {
    @Binding var selectedTab: Int
    @Namespace private var selectionAnimation

    private let tabs: [(icon: String, label: String)] = [
        ("square.grid.2x2", "Overview"),
        ("cpu", "CPU"),
        ("memorychip", "Memory"),
        ("network", "Network"),
        ("stethoscope", "Diagnostics"),
        ("list.bullet.rectangle", "Processes"),
        ("battery.100", "Battery"),
        ("clock.arrow.circlepath", "History")
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                TabButton(
                    icon: tab.icon,
                    label: tab.label,
                    isSelected: selectedTab == index,
                    namespace: selectionAnimation
                ) {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                        selectedTab = index
                    }
                }
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.06),
                            Color.black.opacity(0.08)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.16), radius: 10, x: 0, y: 6)
        )
        .padding(.horizontal, 18)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }
}

struct TabButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    var namespace: Namespace.ID
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.accentColor.opacity(0.18),
                                    Color.purple.opacity(0.18)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                        )
                        .shadow(color: Color.accentColor.opacity(0.18), radius: 10, x: 0, y: 6)
                        .matchedGeometryEffect(id: "tabSelection", in: namespace)
                }

                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 13, weight: .semibold))
                    Text(label)
                        .font(.system(size: 11, weight: .medium))
                }
                .frame(maxWidth: .infinity, minHeight: 32)
                .padding(.horizontal, 8)
                .foregroundColor(isSelected ? .white : .secondary)
            }
        }
        .buttonStyle(.borderless)
        .allowsHitTesting(true)
    }
}

// MARK: - Visual Effect Background

struct VisualEffectBackground: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.blendingMode = .behindWindow
        view.state = .active
        view.material = .hudWindow
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}

// MARK: - Aurora Background

struct AuroraBackground: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                RadialGradient(
                    colors: [
                        Color.black.opacity(0.45),
                        Color(.sRGB, red: 0.08, green: 0.1, blue: 0.15, opacity: 0.9)
                    ],
                    center: .topLeading,
                    startRadius: 80,
                    endRadius: geometry.size.width * 1.4
                )

                Circle()
                    .fill(Color.blue.opacity(0.16))
                    .frame(width: geometry.size.width * 0.65)
                    .offset(x: -geometry.size.width * 0.25, y: -geometry.size.height * 0.35)
                    .blur(radius: 120)

                Circle()
                    .fill(Color.purple.opacity(0.14))
                    .frame(width: geometry.size.width * 0.4)
                    .offset(x: geometry.size.width * 0.32, y: -geometry.size.height * 0.08)
                    .blur(radius: 110)

                RoundedRectangle(cornerRadius: 80)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.05),
                                Color.black.opacity(0.2)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: geometry.size.width * 0.92, height: geometry.size.height * 0.62)
                    .offset(y: geometry.size.height * 0.36)
                    .blur(radius: 80)
            }
            .ignoresSafeArea()
        }
        .allowsHitTesting(false)
        .compositingGroup()
        .opacity(0.9)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(SystemMonitor())
}
