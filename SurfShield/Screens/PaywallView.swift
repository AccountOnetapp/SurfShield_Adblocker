//
//  PaywallView.swift
//  SufrShield
//
//  Created by Артур Кулик on 07.09.2025.
//

import SwiftUI

// MARK: - Models
struct SubscriptionPlan {
    let id: String
    let title: String
    let description: String
    let price: String
    let period: String
    let isPopular: Bool
    let features: [String]
    let discount: String?
}

// MARK: - Mock Data
extension SubscriptionPlan {
    static let mockPlans: [SubscriptionPlan] = [
        SubscriptionPlan(
            id: "monthly",
            title: "Месячная",
            description: "Базовый план",
            price: "₽299",
            period: "/мес",
            isPopular: false,
            features: [
                "Умная блокировка рекламы",
                "Защита от трекеров",
                "Быстрый браузер"
            ],
            discount: nil
        ),
        SubscriptionPlan(
            id: "yearly",
            title: "Годовая",
            description: "Популярный",
            price: "₽1,999",
            period: "/год",
            isPopular: true,
            features: [
                "Продвинутая блокировка рекламы",
                "Защита от трекеров",
                "Быстрый браузер",
                "Синхронизация"
            ],
            discount: "Экономия 44%"
        ),
        SubscriptionPlan(
            id: "lifetime",
            title: "Навсегда",
            description: "Лучшая цена",
            price: "₽4,999",
            period: "одноразово",
            isPopular: false,
            features: [
                "Максимальная блокировка рекламы",
                "Защита от трекеров",
                "Быстрый браузер",
                "Синхронизация",
                "Все обновления"
            ],
            discount: "Лучшая цена"
        )
    ]
}

// MARK: - Components
struct SubscriptionCard: View {
    let plan: SubscriptionPlan
    @Binding var selectedPlan: String
    
    var isSelected: Bool {
        plan.id == selectedPlan
    }
    
    var body: some View {
        HStack {
            // Header
//            VStack(alignment: .leading, spacing: Layout.Padding.small) {
                Text(plan.title)
                    .font(.headline)
                    .foregroundColor(.tm.title)
//            }
            
            Spacer()
            
            // Price
            HStack(alignment: .center, spacing: .smallExt) {
                    Text(plan.price)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.tm.title)
                    
                    Text(plan.period)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.tm.title.opacity(0.5))
                }
        }
        .padding(Layout.Padding.medium)
        .background(
            RoundedRectangle(cornerRadius: Layout.Radius.medium)
                .fill(.tm.title.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.Radius.medium)
                        .stroke(
                            isSelected ? 
                            LinearGradient(
                                gradient: Gradient(colors: [.tm.accentSecondary, .tm.success]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) : 
                            LinearGradient(
                                gradient: Gradient(colors: [.clear]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .onTapGesture {
            selectedPlan = plan.id
        }
    }
}


struct PricingView: View {
    @Binding var selectedPlan: String
    let plans: [SubscriptionPlan]
    
    var body: some View {
        VStack(spacing: .medium) {
            ForEach(plans, id: \.id) { plan in
                SubscriptionCard(plan: plan, selectedPlan: $selectedPlan)
            }
        }
    }
}

// MARK: - Main PaywallView
struct PaywallView: View {
    @State private var selectedPlan: String = "yearly"
    @Environment(\.dismiss) private var dismiss
    
    private let plans = SubscriptionPlan.mockPlans
    
    var body: some View {
        NavigationView {
            VStack(spacing: .medium) {
                // Header
                VStack(spacing: Layout.Padding.regular) {
                    Text("SurfShield Premium")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.tm.title)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: Layout.Padding.small) {
                        Text("Максимальная защита от рекламы")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.tm.title)
                            .multilineTextAlignment(.center)
                        
                        Text("Интеллектуальная блокировка рекламы, защита от трекеров и ускорение загрузки страниц")
                            .font(.subheadline)
                            .foregroundColor(.tm.title)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                    }
                }
                .padding(.top, Layout.Padding.large)
                
                // Pricing
                PricingView(selectedPlan: $selectedPlan, plans: plans)
                
                Spacer()
                
                // Subscribe Button
                Button(action: subscribeAction) {
                    Text("Подписаться")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Layout.Padding.medium)
                        .background(.tm.accentSecondary.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: Layout.Radius.regular))
                }
                .padding(.horizontal, Layout.Padding.medium)
                
                // Terms
                VStack(spacing: Layout.Padding.small) {
                    Text("Подписка продлевается автоматически")
                        .font(.callout)
                        .foregroundColor(.tm.title.opacity(0.6))
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: Layout.Padding.small) {
                        Button("Условия") {
                            // Handle terms
                        }
                        .font(.callout)
                        .foregroundColor(.tm.accent)
                        
                        Text("•")
                            .font(.callout)
                            .foregroundColor(.tm.subTitle)
                        
                        Button("Конфиденциальность") {
                            // Handle privacy
                        }
                        .font(.callout)
                        .foregroundColor(.tm.accent)
                    }
                }
                .padding(.bottom, Layout.Padding.medium)
            }
            .padding(.horizontal, Layout.Padding.medium)
            .background(
                ZStack {
                    // Первый радиальный градиент - верхний левый
                    RadialGradient(
                        gradient: Gradient(colors: [
                            .tm.accentSecondary.opacity(0.6),
                            .tm.accentSecondary.opacity(0.3),
                            .tm.accentSecondary.opacity(0.1)
                        ]),
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: 600
                    )
                    
                    // Второй радиальный градиент - нижний правый
                    RadialGradient(
                        gradient: Gradient(colors: [
                            .tm.success.opacity(0.5),
                            .tm.success.opacity(0.25),
                            .tm.success.opacity(0.08)
                        ]),
                        center: .bottomTrailing,
                        startRadius: 0,
                        endRadius: 700
                    )
                    
                    // Третий радиальный градиент - центр
                    RadialGradient(
                        gradient: Gradient(colors: [
                            .tm.accentSecondary.opacity(0.4),
                            .tm.success.opacity(0.3),
                            .tm.accentSecondary.opacity(0.15)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 500
                    )
                    
                    // Базовый цвет фона - более светлый
                    Color.tm.background.opacity(0.1)
                }
                    .ignoresSafeArea(.all)
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                    .foregroundColor(.tm.accent)
                }
            }
        }
    }
    
    private func subscribeAction() {
        // Handle subscription logic
        print("Подписка на план: \(selectedPlan)")
    }
}

#Preview {
    PaywallView()
}
