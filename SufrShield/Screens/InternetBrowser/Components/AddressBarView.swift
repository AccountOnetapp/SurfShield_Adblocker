//
//  AddressBarView.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import SwiftUI

struct AddressBarView: View {
    @Binding var urlText: String
    let onGoAction: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Иконка безопасности с тенью
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 20, height: 20)
                    .shadow(
                        color: .green.opacity(0.3),
                        radius: 3,
                        x: 0,
                        y: 1
                    )
                
                Image(systemName: "lock.fill")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Поле ввода
            TextField("Введите адрес сайта", text: $urlText)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 16))
                .textInputAutocapitalization(.never)
                .onSubmit {
                    onGoAction()
                }
            
            // Кнопка очистки с тенью
            if !urlText.isEmpty {
                Button(action: {
                    urlText = ""
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray4))
                            .frame(width: 18, height: 18)
                            .shadow(
                                color: .black.opacity(0.1),
                                radius: 2,
                                x: 0,
                                y: 1
                            )
                        
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(.systemBackground))
                .shadow(
                    color: .black.opacity(0.08),
                    radius: 4,
                    x: 0,
                    y: 2
                )
                .shadow(
                    color: .black.opacity(0.04),
                    radius: 1,
                    x: 0,
                    y: 0
                )
        )
    }
}

#Preview {
    AddressBarView(urlText: .constant("https://google.com"), onGoAction: {})
}
