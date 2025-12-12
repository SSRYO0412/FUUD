//
//  NewOnboardingView.swift
//  FUUD
//
//  Lifesum風オンボーディング メインコンテナ
//

import SwiftUI

struct NewOnboardingView: View {
    @StateObject private var viewModel = OnboardingViewModel()
    @EnvironmentObject var cognitoService: SimpleCognitoService

    var onComplete: (() -> Void)?

    private let backgroundColor = Color(hex: "F5F0E8")

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Progress bar (表示するステップのみ)
                if viewModel.showProgressBar {
                    OnboardingProgressBar(
                        currentStep: viewModel.currentStep.progressIndex ?? 0,
                        totalSteps: OnboardingStep.progressStepCount
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                }

                // Content
                contentView
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentStep)
        .onAppear {
            viewModel.onComplete = onComplete
        }
        .onChange(of: cognitoService.isSignedIn) { isSignedIn in
            if isSignedIn && viewModel.currentStep == .auth {
                viewModel.handleAuthSuccess()
            }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.currentStep {
        case .welcome:
            OnboardingWelcomeView(viewModel: viewModel)
        case .goal:
            OnboardingGoalView(viewModel: viewModel)
        case .gender:
            OnboardingGenderView(viewModel: viewModel)
        case .birthdate:
            OnboardingBirthdateView(viewModel: viewModel)
        case .height:
            OnboardingHeightView(viewModel: viewModel)
        case .weight:
            OnboardingWeightView(viewModel: viewModel)
        case .targetWeight:
            OnboardingTargetWeightView(viewModel: viewModel)
        case .auth:
            OnboardingAuthView(viewModel: viewModel)
                .environmentObject(cognitoService)
        case .loading:
            OnboardingLoadingView(viewModel: viewModel)
        case .planReady:
            OnboardingPlanReadyView(viewModel: viewModel)
        case .premium:
            OnboardingPremiumView(viewModel: viewModel)
        case .complete:
            OnboardingCompleteView(viewModel: viewModel)
        case .notification:
            OnboardingNotificationView(viewModel: viewModel)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct NewOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        NewOnboardingView()
            .environmentObject(SimpleCognitoService.shared)
    }
}
#endif
