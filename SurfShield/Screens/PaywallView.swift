//
//  PayWallView.swift
//  SurfShield
//
//  Created by Артур Кулик on 10.09.2025.
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel = PaywallViewModel()
    
    var body: some View {
        NavigationView {
            content
                .background(
                    backgroundGradient
                )
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(.subtitleSecondary)
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            viewModel.restore()
                        }) {
                            Text("Restore")
                                .font(.system(size: 20, weight: .regular))
                                .foregroundStyle(.subtitleSecondary)
                        }
                    }
                }
                .errorAlert(error: $viewModel.error) {
                    dismiss()
                }
                .infoAlert(alert: $viewModel.infoAlert) {
                    // При успешном восстановлении закрываем paywall
                    if viewModel.infoAlert?.title == "Success" {
                        dismiss()
                    }
                }
                .loader(isLoading: $viewModel.isLoading, message: "Processing...")
        }
    }
    
    var content: some View {
        VStack(spacing: .zero) {
            title
                .padding(.bottom, 38)
            imagesContainer
            .padding(.horizontal, 36)
            .padding(.bottom, 28)
            checkMarkContainer
                .padding(.horizontal, .large)
                .padding(.bottom, .large)
            guaranteesTextContainer
                .padding(.bottom, .large)
            proposedText
            Spacer(minLength: .zero)
            continueButton
                .padding(.horizontal, .medium)
                .padding(.bottom, 22)
            
            privacySection
                .padding(.horizontal, .medium)
        }
    }
    
    var imagesContainer: some View {
        HStack(spacing: 30) {
//                Spacer()
            VerticalLabelView(
                imageResource: .privacy,
                text: "Remove advertising",
                padding: .smallExt
            )
            VerticalLabelView(
                imageResource: .ads,
                text: "Block tracking",
                padding: .smallExt
            )
            VerticalLabelView(
                imageResource: .mining,
                text: "Stop \nmining",
                padding: .smallExt
            )
        }
    }
    
    var backgroundGradient: some View {
        RadialGradient(
            gradient: Gradient(colors: [Color.tm.backgroundSecondary, Color.tm.background]),
            center: UnitPoint(x: 1.0, y: 1.0),
            startRadius: 0,
            endRadius: 700
        )
        .ignoresSafeArea()
    }
    
    var title: some View {
        Text("Premium Free\nfor 3 days".attributed(phrases: ["Premium Free"], color: .calmAccent, font: .sfProText(size: 38, weight: .bold)))
            .kerning(2.2)
            .multilineTextAlignment(.center)
    }
    
    var checkMarkContainer: some View {
        VStack(spacing: .medium) {
            makeCheckmarkRow(text: "Enjoy a fast and safe Internet experience")
            makeCheckmarkRow(text: "Get rid of intrusive floating videos, pop-up newsletters, and other distracting ads")
            makeCheckmarkRow(text: "Don't let advertisers track you online")
            makeCheckmarkRow(text: "Speed up image loading and reduce mobile data transfer expenses")
        }
    }
    
    var guaranteesTextContainer: some View {
        VStack(spacing: .regular) {
            Text("100% free for 3 days".uppercased())
            Text("Zero fee with risk free".uppercased())
                .opacity(0.8)
            Text("No extra cost".uppercased())
                .opacity(0.6)
        }
        .font(.sfProRoundedBold(size: 24))
        .kerning(1)
        .foregroundStyle(.calmAccent)
    }
    
    var proposedText: some View {
        Text("Try 3 days free, after \(viewModel.price)/week\n Cancel anytime")
            .font(.sfProText(size: 15, weight: .medium))
            .multilineTextAlignment(.center)
            .foregroundStyle(.tm.subTitleSecondary)
    }
    
    var continueButton: some View {
        MainButton(title: "Continue") {
            viewModel.purchase { isSuccess in
                if isSuccess {
                    dismiss()
                }
            }
        }
    }
    
    var privacySection: some View {
        HStack(spacing: 20) {
            Button(action: {
                if let url = URL(string: Constants.privacyPolicyURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Privacy Policy")
                    .font(.sfProText(size: 13, weight: .medium))
                    .foregroundStyle(.tm.subTitleSecondary)
            }
            
            Text("•")
                .font(.sfProText(size: 13, weight: .medium))
                .foregroundStyle(.tm.subTitleSecondary)
            
            Button(action: {
                if let url = URL(string: Constants.termsOfUseURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Terms of Use")
                    .font(.sfProText(size: 13, weight: .medium))
                    .foregroundStyle(.tm.subTitleSecondary)
            }
        }
    }
    
    func makeCheckmarkRow(text: String) -> some View {
        HStack(spacing: .medium) {
            Text(text)
                .font(.sfProText(size: 13, weight: .bold))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .kerning(0.3)
            Spacer(minLength: .zero)
            Image(systemName: "checkmark")
                .fontWeight(.bold)
                .foregroundStyle(.calmAccent)
        }
    }
    
}

struct VerticalLabelView: View {
    let imageResource: ImageResource
    let text: String
    let padding: Layout.Padding
    
    var body: some View {
        VStack(spacing: padding) {
            Image(imageResource)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(minWidth: 50, maxWidth: 80, minHeight: 50, maxHeight: 80)
//                .frame(width: 80, height: 80)
            
            Text(text)
                .font(.sfProText(size: 12, weight: .medium))
                .kerning(0.4)
                .foregroundColor(.tm.title)
                .multilineTextAlignment(.center)
                .frame(height: 30)
                .lineLimit(4)
                
        }
        .padding(padding)
    }
}

#Preview {
    PaywallView()
}
