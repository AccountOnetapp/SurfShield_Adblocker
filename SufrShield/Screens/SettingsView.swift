//
//  SettingsView.swift
//  SufrShield
//
//  Created by Артур Кулик on 26.08.2025.
//

import SwiftUI
import Combine

final class SettingsViewModel: ObservableObject {
    
    @Published var resourceStatistics: ResourceAnalysisData = .init()
    
    private var cancellables = Set<AnyCancellable>()
    let userDefaultsObserver = UserDefaultsObserver.shared
    
    init() {
        subscribe()
    }
    
    
    private func subscribe() {
        userDefaultsObserver.$webViewBlockedStatistics
            .receive(on: DispatchQueue.main)
            .assign(to: \.resourceStatistics, on: self)
            .store(in: &cancellables)
    }
}

struct SettingsView: View {
    
    @StateObject var viewModel = SettingsViewModel()
    // State variables for settings
    @State private var isAdBlockerEnabled = false
    @State private var basicBlock = false
    @State private var blockAds = false
    @State private var blockTrackers = false
    @State private var blockPopups = false
    @State private var enableWhitelist = false
    
    @State private var enableCookies = false
    @State private var clearCacheOnExit = false
    @State private var enableDarkMode = true
    @State private var showNotifications = false
    @State private var enableBrowserHistory = true
    @State private var startPage = "https://www.google.com"
    
    // Statistics
    @State private var blockedAdsCount = 12847
    @State private var blockedTrackersCount = 3291
    @State private var dataSaved = "156.7 MB"
    
    var body: some View {
        NavigationView {
            content
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.large)
        }
    }
    
    var content: some View {
        ZStack {
            // Таинственный темный фон
            LinearGradient(
                colors: [
                    Color.black.opacity(0.3),
                    Color.tm.container.opacity(0.1),
                    Color.black.opacity(0.4)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(.all)
            
            BackgroundGradient()
                .ignoresSafeArea(.all)
                .opacity(0.7)

            ScrollView {
                LazyVStack(spacing: Layout.Padding.large) {
//                    headerView
                    
                    statisticsSection
                    
                    adBlockerSection
                    
                    browserSection
                    
                    aboutSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, Layout.Padding.mediumExt)
                .padding(.top, Layout.Padding.mediumExt)
            }
        }
    }
    
    var headerView: some View {
        VStack(spacing: Layout.Padding.regularExt) {
            HStack {
                VStack(alignment: .leading, spacing: Layout.Padding.smallExt) {
                    Text("Settings")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.tm.title)
                    
                    Text("Customize your experience")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.tm.subTitle.opacity(0.8))
                }
                
                Spacer()
            }
        }
        .padding(.bottom, Layout.Padding.regular)
    }
    
    var statisticsSection: some View {
        VStack(spacing: Layout.Padding.medium) {
            HStack {
                Text("Protection Stats")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.tm.title)
                
                Spacer()
                
                Button(action: {
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.tm.accent)
                }
            }
            .padding(.horizontal, Layout.Padding.smallExt)
            
            HStack(spacing: Layout.Padding.regularExt) {
                StatCard(
                    title: "Ads Blocked",
                    value: "\(viewModel.userDefaultsObserver.webViewBlockedStatistics.blockedCount.formatted())",
                    icon: "shield.slash",
                    color: .tm.accent
                )
                
                StatCard(
                    title: "Trackers Blocked",
                    value: "\(blockedTrackersCount.formatted())",
                    icon: "eye.slash",
                    color: .tm.accentSecondary
                )
                
                StatCard(
                    title: "Data Saved",
                    value: dataSaved,
                    icon: "arrow.down.circle",
                    color: .tm.success
                )
            }
        }
    }
    
    var adBlockerSection: some View {
        ModernSectionCard(
            title: "Protection & Blocking",
            subtitle: "Content blocking management",
            icon: "shield.checkered",
            accentColor: .calmSecondary
        ) {
            VStack(spacing: Layout.Padding.medium) {
                ModernToggleRow(
                    title: "Advanced Protection",
                    subtitle: "Enhanced security features",
                    icon: "shield.lefthalf.filled",
                    isOn: $isAdBlockerEnabled,
                    accentColor: .calmSecondary
                )
                
                Divider()
                    .background(Color.tm.subTitle.opacity(0.2))
                
                ModernToggleRow(
                    title: "Banner Blocking",
                    subtitle: "Remove advertising banners",
                    icon: "rectangle.slash",
                    isOn: $blockAds,
                    accentColor: .calmSecondary,
                    isDisabled: !isAdBlockerEnabled
                )
                
                ModernToggleRow(
                    title: "Basic Protection",
                    subtitle: "Essential security measures",
                    icon: "shield",
                    isOn: $basicBlock,
                    accentColor: .calmSecondary,
                    isDisabled: !isAdBlockerEnabled
                )
                
                ModernToggleRow(
                    title: "Privacy Guard",
                    subtitle: "Protect personal information",
                    icon: "hand.raised.fill",
                    isOn: $blockPopups,
                    accentColor: .calmSecondary,
                    isDisabled: !isAdBlockerEnabled
                )
                
                ModernToggleRow(
                    title: "Security Shield",
                    subtitle: "Advanced threat protection",
                    icon: "lock.shield",
                    isOn: $enableWhitelist,
                    accentColor: .calmSecondary,
                    isDisabled: !isAdBlockerEnabled
                )
                
                ModernToggleRow(
                    title: "Tracker Blocker",
                    subtitle: "Block tracking scripts",
                    icon: "eye.slash",
                    isOn: $blockTrackers,
                    accentColor: .calmSecondary,
                    isDisabled: !isAdBlockerEnabled
                )
            }
        }
    }
    
    var browserSection: some View {
        ModernSectionCard(
            title: "Browser & Interface",
            subtitle: "Application behavior settings",
            icon: "safari",
            accentColor: .calm
        ) {
            VStack(spacing: Layout.Padding.medium) {
//                ModernToggleRow(
//                    title: "JavaScript",
//                    subtitle: "Script execution",
//                    icon: "curlybraces",
//                    isOn: $enableJavaScript,
//                    accentColor: .calm
//                )
                
                ModernToggleRow(
                    title: "Browser History",
                    subtitle: "Save previous session",
                    icon: "clock.arrow.circlepath",
                    isOn: $enableBrowserHistory,
                    accentColor: .calm
                )
                
                // Start page input - показывается только если история выключена
                if !enableBrowserHistory {
                    VStack(alignment: .leading, spacing: Layout.Padding.small) {
                        HStack {
                            Image(systemName: "house.fill")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.calm)
                                .frame(width: 20)
                            
                            Text("Start Page")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.tm.title)
                            
                            Spacer()
                        }
                        
                        TextField("Enter start page URL", text: $startPage)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.system(size: 14))
                            .padding(.leading, 24)
                    }
                    .padding(.vertical, Layout.Padding.small)
                    .padding(.horizontal, Layout.Padding.medium)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.tm.container.opacity(0.3))
                    )
                }
                
                ModernToggleRow(
                    title: "Cookies",
                    subtitle: "Website data storage",
                    icon: "externaldrive.connected.to.line.below",
                    isOn: $enableCookies,
                    accentColor: .calm
                )
                
                Divider()
                    .background(Color.tm.subTitle.opacity(0.2))
                
                ModernToggleRow(
                    title: "Auto-Clear Cache",
                    subtitle: "Clear cache on exit",
                    icon: "trash.circle",
                    isOn: $clearCacheOnExit,
                    accentColor: .calm
                )
                
                ModernToggleRow(
                    title: "Dark Theme",
                    subtitle: "Night mode interface",
                    icon: "moon.fill",
                    isOn: $enableDarkMode,
                    accentColor: .calm
                )
                
                ModernToggleRow(
                    title: "Notifications",
                    subtitle: "Push notifications",
                    icon: "bell.fill",
                    isOn: $showNotifications,
                    accentColor: .calm
                )
            }
        }
    }
    
    var aboutSection: some View {
        ModernSectionCard(
            title: "About & Support",
            subtitle: "App information and help",
            icon: "info.circle",
            accentColor: .tm.accentTertiary
        ) {
            VStack(spacing: Layout.Padding.medium) {
                ActionRow(
                    title: "Rate App",
                    subtitle: "Share your experience",
                    icon: "star.fill",
                    accentColor: .tm.success
                ) {
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
                
                ActionRow(
                    title: "Contact Support",
                    subtitle: "Get help and assistance",
                    icon: "envelope.fill",
                    accentColor: .tm.accent
                ) {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
                
                Divider()
                    .background(Color.tm.subTitle.opacity(0.2))
                
                ActionRow(
                    title: "Privacy Policy",
                    subtitle: "How we protect your data",
                    icon: "hand.raised.fill",
                    accentColor: .tm.accentSecondary
                ) {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: Layout.Padding.small) {
                        Text("Version 1.0.0")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.tm.title.opacity(0.8))
                        
                        Text("Build 2025.1")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.tm.subTitle.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Text("🛡️")
                        .font(.system(size: 20))
                }
                .padding(.top, Layout.Padding.regular)
            }
        }
    }
}

// MARK: - Modern Components

struct ModernSectionCard<Content: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let content: Content
    
    init(
        title: String,
        subtitle: String,
        icon: String,
        accentColor: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.accentColor = accentColor
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: Layout.Padding.regularExt) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            accentColor.opacity(0.15)
                        )
                        .frame(width: 56, height: 56)
                        .shadow(
                            color: accentColor.opacity(0.3),
                            radius: 12,
                            x: 0,
                            y: 6
                        )
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(accentColor)
                }
                
                VStack(alignment: .leading, spacing: Layout.Padding.small) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.tm.title)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.tm.subTitle.opacity(0.7))
                }
                
                Spacer()
            }
            .padding(.bottom, Layout.Padding.mediumExt)
            
            // Content
            VStack(spacing: 0) {
                content
            }
            .padding(Layout.Padding.mediumExt)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.tm.container.opacity(1.0),
                                Color.tm.container.opacity(0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(
                        color: Color.black.opacity(0.5),
                        radius: 35,
                        x: 0,
                        y: 18
                    )
                    .shadow(
                        color: accentColor.opacity(0.1),
                        radius: 45,
                        x: 0,
                        y: 25
                    )
            )
            .opacity(0.8)
        }
        .padding(.horizontal, Layout.Padding.smallExt)
    }
}

struct ModernToggleRow: View {
    let title: String
    let subtitle: String
    let icon: String
    @Binding var isOn: Bool
    let accentColor: Color
    let isDisabled: Bool
    
    init(
        title: String,
        subtitle: String,
        icon: String,
        isOn: Binding<Bool>,
        accentColor: Color,
        isDisabled: Bool = false
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self._isOn = isOn
        self.accentColor = accentColor
        self.isDisabled = isDisabled
    }
    
    var body: some View {
//        HStack(spacing: Layout.Padding.medium) {
        HStack(spacing: .zero) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        .white.opacity(0.1)
                    )
                    .frame(width: 46, height: 46)
                    .shadow(
                        color: accentColor.opacity(isDisabled ? 0.1 : 0.3),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(isDisabled ? .tm.subTitle.opacity(0.4) : accentColor)
            }
            .padding(.trailing, .medium)
            
            // Text content
            VStack(alignment: .leading, spacing: Layout.Padding.small) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isDisabled ? .tm.title.opacity(0.5) : .tm.title)
                
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(isDisabled ? .tm.subTitle.opacity(0.4) : .tm.subTitle.opacity(0.7))
            }
            
            Spacer()
            
            // Custom Toggle
            ModernToggle(isOn: $isOn, accentColor: accentColor, isDisabled: isDisabled)
        }
        .padding(.vertical, Layout.Padding.smallExt)
        .contentShape(Rectangle())
                        .onTapGesture {
            if !isDisabled {
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isOn.toggle()
                }
            }
        }
        .opacity(isDisabled ? 0.6 : 1.0)
    }
}

struct ModernToggle: View {
    @Binding var isOn: Bool
    let accentColor: Color
    let isDisabled: Bool
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    isOn && !isDisabled ?
                    accentColor.opacity(0.8) :
                            .title.opacity(0.2)
                )
                .frame(width: 50, height: 30)
                .shadow(
                    color: Color.black.opacity(0.2),
                    radius: 8,
                    x: 0,
                    y: 4
                )
            
            // Thumb
            Circle()
                .fill(Color.white)
                .frame(width: 26, height: 26)
                .shadow(
                    color: Color.black.opacity(0.2),
                    radius: 4,
                    x: 0,
                    y: 2
                )
                .offset(x: isOn ? 10 : -10)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn)
        }
        .disabled(isDisabled)
    }
}

// MARK: - Additional Components

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: Layout.Padding.regular) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .shadow(
                        color: color.opacity(0.3),
                        radius: 12,
                        x: 0,
                        y: 6
                    )
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(color)
            }
            
            VStack(spacing: Layout.Padding.small) {
                Text(value)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.tm.title)
                
                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.tm.subTitle.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Layout.Padding.medium)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.tm.container.opacity(0.8))
                .shadow(
                    color: Color.black.opacity(0.3),
                    radius: 20,
                    x: 0,
                    y: 10
                )
        )
    }
}

struct ActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Layout.Padding.medium) {
                // Icon
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(accentColor)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: Layout.Padding.small) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.tm.title)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.tm.subTitle.opacity(0.7))
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.tm.subTitle.opacity(0.5))
            }
            .padding(.vertical, Layout.Padding.smallExt)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
}
