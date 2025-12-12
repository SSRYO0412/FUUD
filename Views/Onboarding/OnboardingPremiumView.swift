//
//  OnboardingPremiumView.swift
//  FUUD
//
//  Lifesum風 サブスク画面（将来実装用、現在はスキップ）
//

import SwiftUI

struct OnboardingPremiumView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selectedPlan: PremiumPlan = .sixMonths
    @State private var currentHeroIndex = 0

    private let backgroundColor = Color(hex: "1A1A1A")
    private let primaryColor = Color(hex: "4CD964")

    enum PremiumPlan: CaseIterable {
        case threeMonths
        case sixMonths
        case twelveMonths

        var months: Int {
            switch self {
            case .threeMonths: return 3
            case .sixMonths: return 6
            case .twelveMonths: return 12
            }
        }

        var price: String {
            switch self {
            case .threeMonths: return "¥1,480"
            case .sixMonths: return "¥2,480"
            case .twelveMonths: return "¥3,980"
            }
        }

        var monthlyPrice: String {
            switch self {
            case .threeMonths: return "¥493/月"
            case .sixMonths: return "¥413/月"
            case .twelveMonths: return "¥332/月"
            }
        }

        var isMostPopular: Bool {
            return self == .sixMonths
        }
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("FUUD")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)

                    Text("PREMIUM")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(primaryColor)
                        .cornerRadius(4)

                    Spacer()

                    Button(action: { viewModel.skipPremium() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                // Hero carousel (プレースホルダー)
                heroCarousel
                    .frame(height: 200)

                // Features
                featuresSection

                Spacer()

                // Pricing
                pricingSection

                // CTA button
                OnboardingPrimaryButton("続ける") {
                    // 将来: StoreKit購入処理
                    viewModel.skipPremium() // 今はスキップ
                }
                .padding(.horizontal, 24)

                // Restore & Redeem
                HStack(spacing: 40) {
                    Button(action: {}) {
                        Text("購入を復元")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }

                    Button(action: {}) {
                        Text("コードを使用")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(.top, 16)

                // Terms
                Text("プライバシーポリシー & 利用規約")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.top, 8)
                    .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Hero Carousel

    private var heroCarousel: some View {
        TabView(selection: $currentHeroIndex) {
            ForEach(0..<3, id: \.self) { index in
                heroCard(index: index)
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
    }

    private func heroCard(index: Int) -> some View {
        VStack(spacing: 16) {
            // プレースホルダー画像
            if let _ = UIImage(named: "premium_hero_\(index + 1)") {
                Image("premium_hero_\(index + 1)")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [primaryColor.opacity(0.3), primaryColor.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 120)
                    .overlay(
                        Image(systemName: heroIcon(for: index))
                            .font(.system(size: 40))
                            .foregroundColor(primaryColor)
                    )
            }

            Text(heroText(for: index))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 24)
    }

    private func heroIcon(for index: Int) -> String {
        switch index {
        case 0: return "star.fill"
        case 1: return "chart.line.uptrend.xyaxis"
        case 2: return "fork.knife"
        default: return "star.fill"
        }
    }

    private func heroText(for index: Int) -> String {
        switch index {
        case 0: return "プレミアムで5倍成功率アップ"
        case 1: return "5500万人以上の成功事例"
        case 2: return "1000以上のレシピにアクセス"
        default: return ""
        }
    }

    // MARK: - Features Section

    private var featuresSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            featureRow("食事プラン＆ダイエットにアクセス")
            featureRow("カロリー＆マクロ栄養素をカスタマイズ")
            featureRow("1000以上のレシピ")
            featureRow("ライフスコアでパーソナルアドバイス")
            featureRow("その他多数の機能")
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }

    private func featureRow(_ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(primaryColor)

            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.8))

            Spacer()
        }
    }

    // MARK: - Pricing Section

    private var pricingSection: some View {
        VStack(spacing: 8) {
            Text("50% OFF Premium")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(primaryColor)

            HStack(spacing: 8) {
                ForEach(PremiumPlan.allCases, id: \.months) { plan in
                    planCard(plan: plan)
                }
            }
            .padding(.horizontal, 24)

            Text("App Storeで安全に決済。いつでもキャンセル可能。")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.4))
                .padding(.top, 8)
        }
    }

    private func planCard(plan: PremiumPlan) -> some View {
        Button(action: { selectedPlan = plan }) {
            VStack(spacing: 4) {
                if plan.isMostPopular {
                    Text("人気")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(primaryColor)
                        .cornerRadius(4)
                } else {
                    Spacer().frame(height: 14)
                }

                Text("\(plan.months)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(selectedPlan == plan ? primaryColor : .white)

                Text("ヶ月")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))

                Text(plan.price)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)

                Text(plan.monthlyPrice)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(selectedPlan == plan ? primaryColor : Color.white.opacity(0.2), lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

#if DEBUG
struct OnboardingPremiumView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingPremiumView(viewModel: OnboardingViewModel())
    }
}
#endif
