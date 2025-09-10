//
//  PayWallView.swift
//  SurfShield
//
//  Created by Артур Кулик on 10.09.2025.
//

import SwiftUI

struct PaywallView: View {
    
    
    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .background(
                backgroundGradient
            )
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
                .padding(.bottom, 34)
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
                text: "Remove advertising",
                padding: .smallExt
            )
            VerticalLabelView(
                imageResource: .mining,
                text: "Remove advertising",
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
        Text("Try 3 days free, after $8.99/week\n Cancel anytime")
            .font(.sfProText(size: 15, weight: .medium))
            .multilineTextAlignment(.center)
            .foregroundStyle(.tm.subTitleSecondary)
    }
    
    var continueButton: some View {
        MainButton(title: "Continue") {
            //TODO: make purchase logic
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
//                .frame(maxWidth: 100, maxHeight: 100)
                .frame(width: 80, height: 80)
            
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
