//
//  OnboardingProgressBar.swift
//  FUUD
//
//  Lifesum風 セグメントプログレスバー
//

import SwiftUI

struct OnboardingProgressBar: View {
    let currentStep: Int
    let totalSteps: Int

    private let activeColor = Color(hex: "4CD964")
    private let inactiveColor = Color(hex: "E8E8E8")
    private let segmentSpacing: CGFloat = 4

    var body: some View {
        HStack(spacing: segmentSpacing) {
            ForEach(0..<totalSteps, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(index <= currentStep ? activeColor : inactiveColor)
                    .frame(height: 4)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: currentStep)
    }
}

// MARK: - Preview

#if DEBUG
struct OnboardingProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            OnboardingProgressBar(currentStep: 0, totalSteps: 6)
            OnboardingProgressBar(currentStep: 2, totalSteps: 6)
            OnboardingProgressBar(currentStep: 5, totalSteps: 6)
        }
        .padding()
        .background(Color(hex: "F5F0E8"))
    }
}
#endif
