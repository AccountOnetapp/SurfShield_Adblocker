//
//  AddressBar.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import SwiftUI

struct AddressBar: View {
    @Binding var url: String
    let onGo: () -> Void
    let onRefresh: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Поле ввода URL
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16))
                
                TextField("Введите адрес сайта", text: $url)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 16))
                    .onSubmit {
                        onGo()
                    }
                
                if !url.isEmpty {
                    Button(action: {
                        url = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
            )
            
            // Кнопка обновления
            Button(action: onRefresh) {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.blue)
            }
            .frame(width: 36, height: 36)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
            )
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }
}

#Preview {
    @State var url = "https://apple.com"
    
    return AddressBar(
        url: $url,
        onGo: { print("Go to: \(url)") },
        onRefresh: { print("Refresh") }
    )
}
