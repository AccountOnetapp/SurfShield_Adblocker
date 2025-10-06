//
//  BorderedButton.swift
//  SurfShield
//
//  Created by Артур Кулик on 05.10.2025.
//

import SwiftUI

struct SafariSettingsButton: View {
    var body: some View {
        
        Button(action: {
            // Open Safari settings
            if let settingsUrl = URL(string: "App-Prefs:Safari&path=WEB_EXTENSIONS") {
                UIApplication.shared.open(settingsUrl)
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "gear")
                    .font(.system(size: 16, weight: .medium))
                Text("Go to Safari Settings")
                    .font(.system(size: 16, weight: .medium))
                Spacer()
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundColor(.tm.accentSecondary)
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.tm.accentSecondary.opacity(0.3), lineWidth: 1)
                    .background(Color.tm.accentSecondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: Color.tm.accentSecondary.opacity(0.3), radius: 15)
            )
        }
    }
}
