//
//  OnboardingGenderView.swift
//  FUUD
//
//  Lifesum風 性別選択画面
//

import SwiftUI

struct OnboardingGenderView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            HStack {
                OnboardingBackButton {
                    viewModel.previousStep()
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer().frame(height: 40)

            // Encouragement message
            if !viewModel.currentStep.encouragementMessage.isEmpty {
                Text(viewModel.currentStep.encouragementMessage)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "6B7280"))
                    .padding(.bottom, 8)
            }

            // Title
            Text("性別を教えてください")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 40)

            // Options
            VStack(spacing: 12) {
                ForEach(Gender.allCases, id: \.self) { gender in
                    OnboardingOptionCard(
                        title: gender.displayName,
                        isSelected: viewModel.userData.gender == gender
                    ) {
                        viewModel.userData.gender = gender
                    }
                }
            }
            .padding(.horizontal, 24)

            Spacer()

            // Next button
            OnboardingPrimaryButton("NEXT", isEnabled: viewModel.canProceed) {
                viewModel.nextStep()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct OnboardingGenderView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingGenderView(viewModel: OnboardingViewModel())
            .background(Color(hex: "F5F0E8"))
    }
}
#endif
