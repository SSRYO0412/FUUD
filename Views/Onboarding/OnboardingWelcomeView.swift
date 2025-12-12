//
//  OnboardingWelcomeView.swift
//  FUUD
//
//  Lifesum風 ウェルカム画面
//

import SwiftUI

struct OnboardingWelcomeView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background image (プレースホルダー)
                backgroundImage(geometry: geometry)

                // Content overlay
                VStack(spacing: 0) {
                    Spacer()

                    // Bottom content
                    VStack(spacing: 24) {
                        // Logo
                        Text("FUUD")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)

                        // Tagline
                        Text("健康的な食事をシンプルに")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))

                        Spacer().frame(height: 40)

                        // Get started button
                        OnboardingPrimaryButton("はじめる") {
                            viewModel.nextStep()
                        }

                        // Login link
                        Button(action: {
                            viewModel.goToLogin()
                        }) {
                            Text("アカウントをお持ちの方は")
                                .foregroundColor(.white.opacity(0.8))
                            + Text("ログイン")
                                .foregroundColor(.white)
                                .underline()
                        }
                        .font(.system(size: 14))
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 60)
                }
            }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func backgroundImage(geometry: GeometryProxy) -> some View {
        // プレースホルダー背景（画像がない場合はグラデーション）
        if let _ = UIImage(named: "onboarding_welcome") {
            Image("onboarding_welcome")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.1),
                            Color.black.opacity(0.5)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        } else {
            // プレースホルダーグラデーション
            LinearGradient(
                colors: [
                    Color(hex: "4CD964"),
                    Color(hex: "34A853")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Preview

#if DEBUG
struct OnboardingWelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingWelcomeView(viewModel: OnboardingViewModel())
    }
}
#endif
