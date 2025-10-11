//
//  InfoAlertModifier.swift
//  SurfShield
//
//  Created by Артур Кулик on 11.10.2025.
//

import SwiftUI

struct InfoAlert {
    var title: String
    var text: String
}

struct InfoAlertModifier: ViewModifier {
    @Binding var infoAlert: InfoAlert?
    var onDismiss: (() -> Void)?
    
    func body(content: Content) -> some View {
        content
            .alert(
                infoAlert?.title ?? "",
                isPresented: .constant(infoAlert != nil),
                presenting: infoAlert
            ) { _ in
                Button("OK", role: .cancel) {
                    onDismiss?()
                    infoAlert = nil
                }
            } message: { alert in
                Text(alert.text)
            }
    }
}

extension View {
    /// Show info alert with custom title and message
    func infoAlert(
        alert: Binding<InfoAlert?>,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        modifier(InfoAlertModifier(infoAlert: alert, onDismiss: onDismiss))
    }
}
