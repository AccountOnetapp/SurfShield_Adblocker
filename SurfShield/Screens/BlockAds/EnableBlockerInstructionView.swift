//
//  EnableBlockerInstructionView.swift
//  SurfShield
//
//  Created by Артур Кулик on 04.10.2025.
//

import SwiftUI

struct EnableBlockerInstructionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var scrollOffset: CGPoint = .zero
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header and subtitle
            VStack(spacing: 8) {
                Text("Enable Extensions")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.tm.title)
                
                Text("To activate the blocker, you need to enable extensions in Safari settings")
                    .font(.subheadline)
                    .foregroundColor(.tm.subTitle)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            Form(content: {
                ForEach(Array(settingsItems.enumerated()), id: \.element.id) { index, item in
                    HStack {
                        Label(title: { Text(item.title) }, icon: {
                            Image("Onboarding0AppIcon")
                                .resizable()
                                .frame(width: 24, height: 24)
                        })
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("Disable.")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.gray)
                                .opacity(0.8)
                        }
                    }
                }
            })
            .scrollDisabled(true)
            // Close button (fixed)
            Text("Go to Safari settings")
                .onTapGesture(perform: {
                    
                })
                .padding(.horizontal)
        }}
}


// MARK: - Settings Data
private var settingsItems: [SettingsItem] {
    [
        SettingsItem(
            id: "adblock",
            title: "SurfShield - AdBlock"
        ),
        SettingsItem(
            id: "privacy",
            title: "SurfShield - Advanced"
        ),
        SettingsItem(
            id: "trackers",
            title: "SurfShield - Banners"
        ),
        SettingsItem(
            id: "popups",
            title: "SurfShield - Basic"
        ),
        SettingsItem(
            id: "malware",
            title: "SurfShield - Privacy"
        ),
        SettingsItem(
            id: "advanced",
            title: "SurfShield - Security"
        ),
        SettingsItem(
            id: "premium",
            title: "SurfShield - Trackers"
        )
    ]
    
}

// MARK: - Settings Item Model
struct SettingsItem {
    let id: String
    let title: String
}

// MARK: - Settings Row View
struct SettingsRowView: View {
    let item: SettingsItem
    let isLast: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: .zero) {
                // Иконка приложения
                Image("Onboarding0AppIcon")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 12)
                // Контент
                Text(item.title)
                    .font(.system(size: 16, weight: .regular))
                //                    .foregroundColor(.black)
                
                Spacer()
                
                Text("Disable.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
                    .opacity(0.8)
            }
        }
    }
}

#Preview {
    EnableBlockerInstructionView()
}
