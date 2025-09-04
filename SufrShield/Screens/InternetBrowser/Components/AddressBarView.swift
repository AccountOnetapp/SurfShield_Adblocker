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
        HStack {
            Image(systemName: "lock.fill")
                .font(.system(size: 12))
                .foregroundColor(.green)
            
            TextField("Введите адрес сайта", text: $urlText)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 16))
                .textInputAutocapitalization(.never)
                .onSubmit {
                    onGoAction()
                }
            
            if !urlText.isEmpty {
                Button(action: {
                    urlText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
        .cornerRadius(20)
    }
}
