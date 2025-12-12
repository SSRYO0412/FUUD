//
//  OnboardingCompleteView.swift
//  FUUD
//
//  Lifesum風 完了画面
//

import SwiftUI

struct OnboardingCompleteView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    private let backgroundColor = Color(hex: "F5F0E8")
    private let primaryColor = Color(hex: "4CD964")

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Illustration
            illustrationView
                .padding(.horizontal, 40)

            Spacer().frame(height: 40)

            // Title
            VStack(spacing: 16) {
                Text("あなたの旅が始まりました！")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                Text("正しい選択をしました。\n健康と栄養について学びながら、\n目標に向かって進みましょう！")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "6B7280"))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 24)

            Spacer()

            // Explore button
            OnboardingPrimaryButton("アプリを探索する") {
                viewModel.nextStep()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    @ViewBuilder
    private var illustrationView: some View {
        if let _ = UIImage(named: "onboarding_complete") {
            Image("onboarding_complete")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 300)
        } else {
            // プレースホルダー
            ZStack {
                // 背景の円
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "FFD700").opacity(0.3),
                                Color(hex: "FF6B6B").opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 250, height: 250)

                // 人物シルエット
                VStack(spacing: 0) {
                    Image(systemName: "figure.arms.open")
                        .font(.system(size: 100))
                        .foregroundColor(primaryColor)

                    // 装飾的な要素
                    HStack(spacing: 20) {
                        Circle()
                            .fill(Color(hex: "FFD700").opacity(0.6))
                            .frame(width: 40, height: 40)

                        Circle()
                            .fill(Color(hex: "FF6B6B").opacity(0.6))
                            .frame(width: 30, height: 30)

                        Circle()
                            .fill(Color(hex: "4CD964").opacity(0.6))
                            .frame(width: 35, height: 35)
                    }
                    .offset(y: -20)
                }
            }
            .frame(height: 300)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct OnboardingCompleteView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingCompleteView(viewModel: OnboardingViewModel())
            .background(Color(hex: "F5F0E8"))
    }
}
#endif
