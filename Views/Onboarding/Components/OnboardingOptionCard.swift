//
//  OnboardingOptionCard.swift
//  FUUD
//
//  Lifesum風 選択肢カード
//

import SwiftUI

struct OnboardingOptionCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    private let selectedColor = Color(hex: "4CD964")
    private let unselectedBorderColor = Color(hex: "E8E8E8")

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(isSelected ? selectedColor : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.clear : unselectedBorderColor, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Preview

#if DEBUG
struct OnboardingOptionCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            OnboardingOptionCard(title: "体重を減らす", isSelected: false) {}
            OnboardingOptionCard(title: "体重を維持する", isSelected: true) {}
            OnboardingOptionCard(title: "体重を増やす", isSelected: false) {}
        }
        .padding()
        .background(Color(hex: "F5F0E8"))
    }
}
#endif
