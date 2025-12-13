//
//  HomeView.swift
//  AWStest
//
//  ホーム画面 - HTML版完全一致
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var cognitoService: SimpleCognitoService
    @StateObject private var personalizer = NutritionPersonalizer.shared
    @StateObject private var mealService = MealLogService.shared
    @StateObject private var healthKitService = HealthKitService.shared
    @State private var aiInsightIndex = 0
    @State private var isCardExpanded = false
    @State private var expandedCardDetail: HealthMetricDetail? = nil
    @Namespace private var animation

    // AIインサイト文面はUI試作用。API連携後に実データへ置き換え予定
    private let aiInsights = [
        "睡眠効率が前週比12%向上。深睡眠時の成長ホルモン分泌が最適化されています...", // 仮のAIインサイト
        "腸内細菌の多様性スコアが85点に到達。酪酸産生菌が23%増加しました...", // 仮のAIインサイト
        "hrv朝測定値が68msに改善。自律神経バランスが最適範囲です..." // 仮のAIインサイト
    ]

    private var backgroundTargetCalories: Int {
        personalizer.adjustedCalories?.adjustedTarget ?? 1800
    }

    private var backgroundEatenCalories: Int {
        mealService.todayTotals.calories
    }

    private var backgroundBurnedCalories: Int {
        Int(healthKitService.healthData?.activeEnergyBurned ?? 0)
    }

    private var backgroundRemainingCalories: Int {
        backgroundTargetCalories - backgroundEatenCalories + backgroundBurnedCalories
    }

    private var orbColorStyle: OrbBackground.ColorStyle {
        guard backgroundTargetCalories > 0 else { return .neutral }

        let ratio = Double(backgroundRemainingCalories) / Double(backgroundTargetCalories)

        if ratio <= 0 {
            return .red
        } else if ratio < 0.3 {
            return .yellow
        } else if ratio < 0.7 {
            return .green
        } else {
            return .blue
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.secondarySystemBackground)
                    .ignoresSafeArea()

                // Orb Background Animation
                OrbBackground(style: orbColorStyle)

                ScrollView {
                    VStack(spacing: VirgilSpacing.lg) {
                        // Header - Lifesum style centered
                        HomeHeaderSection()
                            .padding(.horizontal, VirgilSpacing.md)

                        // ===== FUUD Lifesum風セクション =====

                        // 以下のカード - 左右paddingあり
                        VStack(spacing: VirgilSpacing.lg) {
                            // 1. Nutrition Today（Lifesum風 - 大型円形リング + PFCバー）
                            NutritionTodaySection()

                            // 2. AI Insight Card（Lifesum風 - パーソナライズインサイト）
                            AIInsightCard()

                            // 3. Meal Log List（Lifesum風 - 今日の食事ログ）
                            MealLogListSection()

                            // 4. Exercise Section（Lifesum風 - 運動記録）
                            ExerciseSectionHome()

                            // 5. Water Intake（Lifesum風 - 水分摂取）
                            WaterIntakeSection()

                            // 6. Fasting Timer（Lifesum風 - 断食タイマー）
                            FastingTimerCardView()

                            // 7. Steps（HealthKit歩数プログレス）
                            StepsSection()
                        }
                        .padding(.horizontal, VirgilSpacing.md)
                    }
                    .padding(.top, VirgilSpacing.lg)
                    .padding(.bottom, 100)
                }
                .blur(radius: isCardExpanded ? 8 : 0)
                .animation(.easeInOut(duration: 0.3), value: isCardExpanded)
            }
            .expandableCard(detail: expandedCardDetail, isExpanded: $isCardExpanded, namespace: animation)
            .navigationBarHidden(true)
            .floatingChatButton()
        }
        .onAppear {
            startAIInsightRotation()
            setupHealthKit()
        }
    }

    private func startAIInsightRotation() {
        Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { _ in
            withAnimation {
                aiInsightIndex = (aiInsightIndex + 1) % aiInsights.count
            }
        }
    }

    /// HealthKit接続をセットアップ（認証 + データ取得）
    private func setupHealthKit() {
        Task {
            do {
                // 1. 認証リクエスト
                try await healthKitService.requestAuthorization()
                print("✅ HealthKit認証成功")

                // 2. データ取得
                await healthKitService.fetchAllHealthData()
                print("✅ HealthKitデータ取得完了")

            } catch {
                print("❌ HealthKit接続エラー: \(error.localizedDescription)")
                // エラーがあってもアプリは続行（HealthKitがなくても動作する）
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(SimpleCognitoService.shared)
    }
}
#endif
