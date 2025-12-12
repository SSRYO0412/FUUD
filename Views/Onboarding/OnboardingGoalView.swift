//
//  OnboardingGoalView.swift
//  FUUD
//
//  Lifesum風 目標選択画面
//

import SwiftUI

struct OnboardingGoalView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    private let backgroundColor = Color(hex: "F5F0E8")

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
            Text("あなたの目標は？")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 40)

            // Options
            VStack(spacing: 12) {
                ForEach(OnboardingGoal.allCases, id: \.self) { goal in
                    OnboardingOptionCard(
                        title: goal.displayName,
                        isSelected: viewModel.userData.goal == goal
                    ) {
                        viewModel.userData.goal = goal
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
struct OnboardingGoalView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingGoalView(viewModel: OnboardingViewModel())
            .background(Color(hex: "F5F0E8"))
    }
}
#endif
