//
//  SettingsView.swift
//  SufrShield
//
//  Created by Артур Кулик on 26.08.2025.
//

import SwiftUI

struct SettingsView: View {
    // State variables for settings
    @State private var isAdBlockerEnabled = true
    @State private var blockAds = true
    @State private var blockTrackers = true
    @State private var blockPopups = false
    @State private var enableWhitelist = false
    
    @State private var enableJavaScript = true
    @State private var enableCookies = true
    @State private var clearCacheOnExit = false
    @State private var enableDarkMode = true
    @State private var showNotifications = true
    
    // Statistics
    @State private var blockedAdsCount = 12847
    @State private var blockedTrackersCount = 3291
    @State private var dataSaved = "156.7 MB"
    
    var body: some View {
        content
    }
    
    var content: some View {
        ZStack {
            BackgroundGradient()
                .ignoresSafeArea(.all)

            ScrollView {
                LazyVStack(spacing: Layout.Padding.large) {
                    headerView
                    
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
                
                // Decorative element
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.tm.accent.opacity(0.3), .tm.accentSecondary.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.tm.accent)
                }
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
                    value: "\(blockedAdsCount.formatted())",
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
            accentColor: .tm.accent
        ) {
            VStack(spacing: Layout.Padding.medium) {
                ModernToggleRow(
                    title: "Ad Blocker Active",
                    subtitle: "Main protection from ads",
                    icon: "power",
                    isOn: $isAdBlockerEnabled,
                    accentColor: .tm.accent
                )
                
                Divider()
                    .background(Color.tm.subTitle.opacity(0.2))
                
                ModernToggleRow(
                    title: "Block Advertisements",
                    subtitle: "Hide advertising banners",
                    icon: "rectangle.slash",
                    isOn: $blockAds,
                    accentColor: .tm.accent,
                    isDisabled: !isAdBlockerEnabled
                )
                
                ModernToggleRow(
                    title: "Block Trackers",
                    subtitle: "Protection from tracking",
                    icon: "eye.slash",
                    isOn: $blockTrackers,
                    accentColor: .tm.accent,
                    isDisabled: !isAdBlockerEnabled
                )
                
                ModernToggleRow(
                    title: "Block Pop-ups",
                    subtitle: "Block popup windows",
                    icon: "square.stack.3d.down.right.fill",
                    isOn: $blockPopups,
                    accentColor: .tm.accent,
                    isDisabled: !isAdBlockerEnabled
                )
                
                ModernToggleRow(
                    title: "Whitelist",
                    subtitle: "Trusted websites",
                    icon: "checkmark.shield",
                    isOn: $enableWhitelist,
                    accentColor: .tm.success,
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
            accentColor: .tm.accentSecondary
        ) {
            VStack(spacing: Layout.Padding.medium) {
                ModernToggleRow(
                    title: "JavaScript",
                    subtitle: "Script execution",
                    icon: "curlybraces",
                    isOn: $enableJavaScript,
                    accentColor: .tm.accentSecondary
                )
                
                ModernToggleRow(
                    title: "Cookies",
                    subtitle: "Website data storage",
                    icon: "externaldrive.connected.to.line.below",
                    isOn: $enableCookies,
                    accentColor: .tm.accentSecondary
                )
                
                Divider()
                    .background(Color.tm.subTitle.opacity(0.2))
                
                ModernToggleRow(
                    title: "Auto-Clear Cache",
                    subtitle: "Clear cache on exit",
                    icon: "trash.circle",
                    isOn: $clearCacheOnExit,
                    accentColor: .tm.error
                )
                
                ModernToggleRow(
                    title: "Dark Theme",
                    subtitle: "Night mode interface",
                    icon: "moon.fill",
                    isOn: $enableDarkMode,
                    accentColor: .tm.accentTertiary
                )
                
                ModernToggleRow(
                    title: "Notifications",
                    subtitle: "Push notifications",
                    icon: "bell.fill",
                    isOn: $showNotifications,
                    accentColor: .tm.accentSecondary
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
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [accentColor.opacity(0.2), accentColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
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
                                Color.tm.container.opacity(0.4),
                                Color.tm.container.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 0.5
                            )
                    )
            )
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
        HStack(spacing: Layout.Padding.medium) {
            // Icon
            ZStack {
                Circle()
                    .fill(accentColor.opacity(isDisabled ? 0.1 : 0.15))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isDisabled ? .tm.subTitle.opacity(0.4) : accentColor)
            }
            
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
                    LinearGradient(
                        colors: [accentColor, accentColor.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(
                        colors: [Color.tm.subTitle.opacity(0.2), Color.tm.subTitle.opacity(0.15)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: 50, height: 30)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isOn && !isDisabled ? accentColor.opacity(0.3) : Color.tm.subTitle.opacity(0.1),
                            lineWidth: 1
                        )
                )
            
            // Thumb
            Circle()
                .fill(Color.white)
                .frame(width: 26, height: 26)
                .shadow(
                    color: Color.black.opacity(0.15),
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
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.2), color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
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
                .fill(
                    LinearGradient(
                        colors: [
                            Color.tm.container.opacity(0.3),
                            Color.tm.container.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
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
