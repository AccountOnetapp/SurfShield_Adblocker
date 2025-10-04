//
//  EnableBlockerInstructionView.swift
//  SurfShield
//
//  Created by Артур Кулик on 04.10.2025.
//

import SwiftUI

struct SheetContentView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var scrollOffset: CGPoint = .zero
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок (фиксированный)
            Text("Тестовый Sheet")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.tm.title)
                .padding(.top, 20)
                .padding(.bottom, 16)
            
            ScrollView {
                ForEach(0..<50, id: \.self) { index in
                    Text("Text")
                }
                .scrollToOffset(contentOffset: $scrollOffset)
            }
            .frame(maxWidth: .infinity)
            // Кнопка закрытия (фиксированная)
            Button("Закрыть") {
                scrollOffset = .init(x: 0, y: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(.tm.accentSecondary)
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
        }
        .background(.tm.container)
        .onAppear {
            startAutoScroll()
        }
    }
    
    private func startAutoScroll() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.linear(duration: 0.1)) {
                scrollOffset.y += 3
            }
        }
    }
    
    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
}
