//
//  ErrorOverlay.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import SwiftUI

struct ErrorOverlay: View {
    let errorMessage: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.red)
            
            Text("Ошибка загрузки")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            Text(errorMessage)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button("Попробовать снова") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    ErrorOverlay(
        errorMessage: "Не удалось подключиться к серверу"
    ) {
        print("Retry tapped")
    }
}
