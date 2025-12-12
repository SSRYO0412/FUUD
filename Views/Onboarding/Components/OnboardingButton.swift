//
//  OnboardingButton.swift
//  FUUD
//
//  Lifesum風 ボタンコンポーネント
//

import SwiftUI

struct OnboardingPrimaryButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    init(_ title: String, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.title = title
        self.isEnabled = isEnabled
        self.action = action
    }

    private let activeColor = Color(hex: "4CD964")
    private let disabledColor = Color(hex: "D1D1D1")

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isEnabled ? activeColor : disabledColor)
                .cornerRadius(12)
        }
        .disabled(!isEnabled)
    }
}

struct OnboardingSecondaryButton: View {
    let title: String
    let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "6B7280"))
        }
    }
}

struct OnboardingBackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 40, height: 40)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct OnboardingButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            OnboardingPrimaryButton("NEXT", isEnabled: true) {}
            OnboardingPrimaryButton("NEXT", isEnabled: false) {}
            OnboardingSecondaryButton("Skip") {}
            OnboardingBackButton {}
        }
        .padding()
        .background(Color(hex: "F5F0E8"))
    }
}
#endif
