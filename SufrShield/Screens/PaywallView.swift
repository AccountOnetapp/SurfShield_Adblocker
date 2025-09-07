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
            VStack(alignment: .leading, spacing: Layout.Padding.small) {
                HStack {
                    Text(plan.title)
                        .font(.headline)
                        .foregroundColor(.tm.title)
                    
                    if plan.isPopular {
                        Text("Популярно")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, Layout.Padding.regular)
                            .padding(.vertical, Layout.Padding.small)
                            .background(.tm.accent)
                            .clipShape(Capsule())
                    }
                }
            }
            
            Spacer()
            
            // Price
            VStack(alignment: .trailing, spacing: Layout.Padding.small) {
                HStack(alignment: .bottom) {
                    Text(plan.price)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.tm.title)
                    
                    Text(plan.period)
                        .font(.caption)
                        .foregroundColor(.tm.subTitle)
                }
                
                if let discount = plan.discount {
                    Text(discount)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.tm.success)
                        .padding(.horizontal, Layout.Padding.regular)
                        .padding(.vertical, Layout.Padding.small)
                        .background(.tm.success.opacity(0.1))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(Layout.Padding.medium)
        .background(
            RoundedRectangle(cornerRadius: Layout.Radius.regular)
                .fill(.tm.container)
                .overlay(
                    RoundedRectangle(cornerRadius: Layout.Radius.regular)
                        .stroke(isSelected ? .tm.accent : .clear, lineWidth: 2)
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
        VStack(spacing: Layout.Padding.regular) {
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
            VStack(spacing: Layout.Padding.medium) {
                // Header
                VStack(spacing: Layout.Padding.regular) {
                    Text("SufrShield Premium")
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
                            .foregroundColor(.tm.subTitle)
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
                        .background(.tm.accent)
                        .clipShape(RoundedRectangle(cornerRadius: Layout.Radius.regular))
                }
                .padding(.horizontal, Layout.Padding.medium)
                
                // Terms
                VStack(spacing: Layout.Padding.small) {
                    Text("Подписка продлевается автоматически")
                        .font(.caption2)
                        .foregroundColor(.tm.subTitle)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: Layout.Padding.small) {
                        Button("Условия") {
                            // Handle terms
                        }
                        .font(.caption2)
                        .foregroundColor(.tm.accent)
                        
                        Text("•")
                            .font(.caption2)
                            .foregroundColor(.tm.subTitle)
                        
                        Button("Конфиденциальность") {
                            // Handle privacy
                        }
                        .font(.caption2)
                        .foregroundColor(.tm.accent)
                    }
                }
                .padding(.bottom, Layout.Padding.medium)
            }
            .padding(.horizontal, Layout.Padding.medium)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .tm.accent,
                        .tm.accentSecondary,
                        .tm.accentTertiary
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
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