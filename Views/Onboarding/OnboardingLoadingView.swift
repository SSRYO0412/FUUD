//
//  OnboardingLoadingView.swift
//  FUUD
//
//  Lifesum風 プラン準備中画面
//

import SwiftUI

struct OnboardingLoadingView: View {
    @ObservedObject var viewModel: OnboardingViewModel

    @State private var loadingText = "あなた専用のプランを作成中..."
    @State private var progress: CGFloat = 0
    @State private var textIndex = 0

    private let loadingTexts = [
        "あなた専用のプランを作成中...",
        "ヘルスプランをカスタマイズ中...",
        "栄養バランスを計算中...",
        "もうすぐ完了です..."
    ]

    private let backgroundColor = Color(hex: "F5F0E8")
    private let primaryColor = Color(hex: "4CD964")

    var body: some View {
        VStack(spacing: 0) {
            // Illustration
            illustrationView
                .frame(maxHeight: .infinity)

            // Loading content
            VStack(spacing: 24) {
                Text(loadingText)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .animation(.easeInOut, value: loadingText)

                // Circular progress
                ZStack {
                    Circle()
                        .stroke(Color(hex: "E8E8E8"), lineWidth: 3)
                        .frame(width: 40, height: 40)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(primaryColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.5), value: progress)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 100)
        }
        .onAppear {
            startLoading()
        }
    }

    @ViewBuilder
    private var illustrationView: some View {
        if let _ = UIImage(named: "onboarding_loading") {
            Image("onboarding_loading")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 40)
        } else {
            // プレースホルダー
            ZStack {
                Circle()
                    .fill(primaryColor.opacity(0.1))
                    .frame(width: 200, height: 200)

                Image(systemName: "figure.run")
                    .font(.system(size: 80))
                    .foregroundColor(primaryColor)
            }
        }
    }

    private func startLoading() {
        // テキストアニメーション
        Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { timer in
            textIndex = (textIndex + 1) % loadingTexts.count
            loadingText = loadingTexts[textIndex]
        }

        // プログレスアニメーション
        withAnimation(.linear(duration: 2)) {
            progress = 1
        }
    }
}

// MARK: - Preview

#if DEBUG
struct OnboardingLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingLoadingView(viewModel: OnboardingViewModel())
            .background(Color(hex: "F5F0E8"))
    }
}
#endif
