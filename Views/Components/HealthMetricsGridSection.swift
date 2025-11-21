//
//  HealthMetricsGridSection.swift
//  AWStest
//
//  健康指標グリッドセクション（2x2レイアウト）
//

import SwiftUI

struct HealthMetricsGridSection: View {
    @StateObject private var bloodTestService = BloodTestService.shared
    @StateObject private var healthScoreService = HealthScoreService.shared
    @ObservedObject private var demoModeManager = DemoModeManager.shared

    @Binding var isExpanded: Bool
    @Binding var expandedCardDetail: HealthMetricDetail?

    @State private var expandedCardType: HealthMetricType? = nil

    var body: some View {
        VStack(spacing: 12) {
            // 上の行: 代謝力 + 炎症レベル
            HStack(spacing: 12) {
                // 左上: 代謝力 (折れ線グラフ)
                HealthMetricCard(
                    title: "代謝力",
                    iconName: "flame.circle",
                    scoreValue: String(format: "%.0f", metabolicScore * 100),
                    scoreUnit: "%",
                    statusText: metabolicStatus,
                    statusColor: metabolicColor,
                    visualType: .lineChart,
                    progress: metabolicScore,
                    chartDataPoints: metabolicChartData
                )
                .frame(maxWidth: .infinity)
                .frame(height: 130)
                .onTapGesture {
                    expandedCardType = .metabolic
                    expandedCardDetail = metabolicDetail
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isExpanded = true
                    }
                }
                .onAppear {
                    print("🔥 代謝力: progress=\(metabolicScore), chartData=\(metabolicChartData)")
                }

                // 右上: 炎症レベル (半円ゲージ)
                HealthMetricCard(
                    title: "炎症レベル",
                    iconName: "shield.circle",
                    scoreValue: String(format: "%.0f", inflammationScore * 100),
                    scoreUnit: "%",
                    statusText: inflammationStatus,
                    statusColor: inflammationColor,
                    visualType: .semiCircleGauge,
                    progress: inflammationScore
                )
                .frame(maxWidth: .infinity)
                .frame(height: 130)
                .onTapGesture {
                    expandedCardType = .inflammation
                    expandedCardDetail = inflammationDetail
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isExpanded = true
                    }
                }
                .onAppear {
                    print("🛡️ 炎症レベル: progress=\(inflammationScore)")
                }
            }

            // 下の行: 回復スピード + 老化速度
            HStack(spacing: 12) {
                // 左下: 回復スピード (横バー)
                HealthMetricCard(
                    title: "回復スピード",
                    iconName: "arrow.clockwise.circle",
                    scoreValue: String(format: "%.0f", recoveryScore * 100),
                    scoreUnit: "%",
                    statusText: recoveryStatus,
                    statusColor: recoveryColor,
                    visualType: .horizontalBar,
                    progress: recoveryScore
                )
                .frame(maxWidth: .infinity)
                .frame(height: 130)
                .offset(y: 50)
                .onTapGesture {
                    expandedCardType = .recovery
                    expandedCardDetail = recoveryDetail
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isExpanded = true
                    }
                }
                .onAppear {
                    print("🔄 回復スピード: progress=\(recoveryScore)")
                }

                // 右下: 老化速度 (横バー)
                HealthMetricCard(
                    title: "老化速度",
                    iconName: "chart.line.uptrend.xyaxis.circle",
                    scoreValue: String(format: "%.1f", agingRate),
                    scoreUnit: "歳/年",
                    statusText: agingRateStatus,
                    statusColor: agingRateColor,
                    visualType: .horizontalBar,
                    progress: agingRateProgress
                )
                .frame(maxWidth: .infinity)
                .frame(height: 130)
                .offset(y: 50)
                .onTapGesture {
                    expandedCardType = .aging
                    expandedCardDetail = agingDetail
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        isExpanded = true
                    }
                }
                .onAppear {
                    print("📈 老化速度詳細:")
                    print("  - agingScore: \(String(format: "%.2f", agingScore))")
                    print("  - agingRate: \(String(format: "%.2f", agingRate))歳/年")
                    print("  - agingRateProgress: \(String(format: "%.2f", agingRateProgress))")
                    print("  - 表示値: \(String(format: "%.1f", agingRate))歳/年")
                    print("  - バー幅: \(String(format: "%.0f", agingRateProgress * 100))%")
                }
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            // スコア計算をトリガー
            Task {
                await healthScoreService.calculateAllScores()
            }
        }
    }

    // MARK: - Card Detail Data

    /// 代謝力カードの詳細データ
    private var metabolicDetail: HealthMetricDetail {
        HealthMetricDetail(
            type: .metabolic,
            score: metabolicScore * 100,
            scoreDisplay: "\(Int(metabolicScore * 100))%",
            status: metabolicStatus,
            breakdowns: [
                ScoreBreakdown(category: "血糖制御", percentage: 30, value: metabolicScore * 100 * 0.9),
                ScoreBreakdown(category: "脂質代謝", percentage: 25, value: metabolicScore * 100 * 0.95),
                ScoreBreakdown(category: "エネルギー効率", percentage: 20, value: metabolicScore * 100 * 1.1),
                ScoreBreakdown(category: "インスリン感受性", percentage: 15, value: metabolicScore * 100 * 0.85),
                ScoreBreakdown(category: "ミトコンドリア機能", percentage: 10, value: metabolicScore * 100)
            ],
            topMarkers: [
                BloodMarker(name: "HbA1c", value: "5.4", unit: "%", status: .good, normalRange: "<5.7"),
                BloodMarker(name: "TG", value: "92", unit: "mg/dL", status: .optimal, normalRange: "<150"),
                BloodMarker(name: "HDL", value: "65", unit: "mg/dL", status: .optimal, normalRange: ">40"),
                BloodMarker(name: "LDL", value: "105", unit: "mg/dL", status: .good, normalRange: "<120"),
                BloodMarker(name: "Glucose", value: "95", unit: "mg/dL", status: .optimal, normalRange: "70-100")
            ],
            trendData: metabolicChartData.enumerated().map { index, value in
                TrendData(date: Calendar.current.date(byAdding: .day, value: -6 + index, to: Date())!, value: value)
            },
            actions: [
                RecommendedAction(icon: "🏃", title: "朝の有酸素運動", description: "空腹時に30分の軽いジョギングで脂肪燃焼促進", priority: .high),
                RecommendedAction(icon: "🍽️", title: "食後の軽い運動", description: "食後15分の散歩で血糖値スパイク抑制", priority: .high),
                RecommendedAction(icon: "🥗", title: "低GI食品選択", description: "全粒穀物・野菜中心の食事で血糖安定化", priority: .medium)
            ]
        )
    }

    /// 炎症レベルカードの詳細データ
    private var inflammationDetail: HealthMetricDetail {
        HealthMetricDetail(
            type: .inflammation,
            score: inflammationScore * 100,
            scoreDisplay: "\(Int(inflammationScore * 100))%",
            status: inflammationStatus,
            breakdowns: [
                ScoreBreakdown(category: "急性炎症", percentage: 40, value: inflammationScore * 100 * 1.1),
                ScoreBreakdown(category: "慢性炎症", percentage: 30, value: inflammationScore * 100 * 0.9),
                ScoreBreakdown(category: "酸化ストレス", percentage: 20, value: inflammationScore * 100),
                ScoreBreakdown(category: "免疫バランス", percentage: 10, value: inflammationScore * 100 * 1.05)
            ],
            topMarkers: [
                BloodMarker(name: "CRP", value: "0.08", unit: "mg/dL", status: .optimal, normalRange: "<0.3"),
                BloodMarker(name: "IL-6", value: "2.1", unit: "pg/mL", status: .good, normalRange: "<5.0"),
                BloodMarker(name: "Ferritin", value: "88", unit: "ng/mL", status: .good, normalRange: "30-400"),
                BloodMarker(name: "白血球", value: "6200", unit: "/μL", status: .optimal, normalRange: "3500-9000"),
                BloodMarker(name: "ESR", value: "8", unit: "mm/hr", status: .optimal, normalRange: "<15")
            ],
            trendData: Array(0..<7).map { day in
                TrendData(date: Calendar.current.date(byAdding: .day, value: -6 + day, to: Date())!, value: inflammationScore * 100 + Double.random(in: -5...5))
            },
            actions: [
                RecommendedAction(icon: "🥗", title: "抗炎症食材摂取", description: "オメガ3・ターメリック・緑茶で炎症抑制", priority: .high),
                RecommendedAction(icon: "🧘", title: "ストレス管理", description: "毎日15分の瞑想でコルチゾール低減", priority: .high),
                RecommendedAction(icon: "😴", title: "十分な睡眠", description: "7-8時間の質の高い睡眠で炎症回復", priority: .medium)
            ]
        )
    }

    /// 回復スピードカードの詳細データ
    private var recoveryDetail: HealthMetricDetail {
        HealthMetricDetail(
            type: .recovery,
            score: recoveryScore * 100,
            scoreDisplay: "\(Int(recoveryScore * 100))%",
            status: recoveryStatus,
            breakdowns: [
                ScoreBreakdown(category: "筋肉回復", percentage: 35, value: recoveryScore * 100 * 1.05),
                ScoreBreakdown(category: "神経回復", percentage: 25, value: recoveryScore * 100 * 0.95),
                ScoreBreakdown(category: "代謝回復", percentage: 20, value: recoveryScore * 100),
                ScoreBreakdown(category: "睡眠質", percentage: 20, value: recoveryScore * 100 * 0.98)
            ],
            topMarkers: [
                BloodMarker(name: "CK", value: "145", unit: "U/L", status: .optimal, normalRange: "50-200"),
                BloodMarker(name: "LDH", value: "168", unit: "U/L", status: .good, normalRange: "120-240"),
                BloodMarker(name: "Cortisol", value: "12.5", unit: "μg/dL", status: .optimal, normalRange: "6-18"),
                BloodMarker(name: "HRV", value: "68", unit: "ms", status: .good, normalRange: ">50"),
                BloodMarker(name: "深睡眠", value: "90", unit: "分", status: .optimal, normalRange: ">60")
            ],
            trendData: Array(0..<7).map { day in
                TrendData(date: Calendar.current.date(byAdding: .day, value: -6 + day, to: Date())!, value: recoveryScore * 100 + Double.random(in: -3...3))
            },
            actions: [
                RecommendedAction(icon: "🚶", title: "アクティブリカバリー", description: "軽い散歩・ストレッチで血流促進", priority: .high),
                RecommendedAction(icon: "😴", title: "質の高い睡眠", description: "22時就寝で深睡眠90分以上確保", priority: .high),
                RecommendedAction(icon: "🍖", title: "タンパク質摂取", description: "体重×1.5gのタンパク質で筋肉回復", priority: .medium)
            ]
        )
    }

    /// 老化速度カードの詳細データ
    private var agingDetail: HealthMetricDetail {
        HealthMetricDetail(
            type: .aging,
            score: agingRate,
            scoreDisplay: String(format: "%.1f歳/年", agingRate),
            status: agingRateStatus,
            breakdowns: [
                ScoreBreakdown(category: "細胞老化", percentage: 30, value: agingScore * 100 * 0.9),
                ScoreBreakdown(category: "酸化ダメージ", percentage: 25, value: agingScore * 100 * 1.05),
                ScoreBreakdown(category: "糖化", percentage: 20, value: agingScore * 100 * 0.95),
                ScoreBreakdown(category: "テロメア", percentage: 15, value: agingScore * 100 * 1.1),
                ScoreBreakdown(category: "DNA修復", percentage: 10, value: agingScore * 100)
            ],
            topMarkers: [
                BloodMarker(name: "AGEs", value: "12", unit: "μg/mL", status: .good, normalRange: "<15"),
                BloodMarker(name: "抗酸化能力", value: "1.2", unit: "mM", status: .good, normalRange: ">1.0"),
                BloodMarker(name: "HbA1c", value: "5.4", unit: "%", status: .good, normalRange: "<5.7"),
                BloodMarker(name: "Albumin", value: "4.4", unit: "g/dL", status: .optimal, normalRange: "3.8-5.3"),
                BloodMarker(name: "TP", value: "7.1", unit: "g/dL", status: .optimal, normalRange: "6.5-8.0")
            ],
            trendData: Array(0..<7).map { day in
                TrendData(date: Calendar.current.date(byAdding: .day, value: -6 + day, to: Date())!, value: agingRate + Double.random(in: -0.1...0.1))
            },
            actions: [
                RecommendedAction(icon: "🥗", title: "抗酸化食品摂取", description: "ベリー類・緑茶・ダークチョコで酸化防止", priority: .high),
                RecommendedAction(icon: "🍽️", title: "カロリー制限", description: "適度なカロリー制限で長寿遺伝子活性化", priority: .medium),
                RecommendedAction(icon: "🏃", title: "適度な運動", description: "週3回の中強度運動でテロメア保護", priority: .medium)
            ]
        )
    }

    // MARK: - Computed Properties

    /// 代謝力スコア（ScoreEngineで計算、0-1の範囲）
    private var metabolicScore: Double {
        // ScoreEngineから取得（0-100スケール）→ 0-1に変換
        if let score = healthScoreService.metabolicScore {
            return score / 100.0
        }

        // データなしの場合はデフォルト値
        print("⚠️ 代謝力: ScoreEngineからデータなし")
        return 0.35
    }

    private var metabolicStatus: String {
        if metabolicScore >= 0.7 { return "高" }
        if metabolicScore >= 0.4 { return "中" }
        return "低"
    }

    private var metabolicColor: Color {
        if metabolicScore >= 0.7 { return Color(hex: "00C853") }
        if metabolicScore >= 0.4 { return Color(hex: "FFCB05") }
        return Color(hex: "5E7CE2")
    }

    /// 炎症レベル（ScoreEngineで計算、0-1の範囲）
    private var inflammationScore: Double {
        // ScoreEngineから取得（0-100スケール）→ 0-1に変換
        if let score = healthScoreService.inflammationScore {
            return score / 100.0
        }

        // データなしの場合はデフォルト値
        print("⚠️ 炎症レベル: ScoreEngineからデータなし")
        return 0.4
    }

    private var inflammationStatus: String {
        if inflammationScore >= 0.7 { return "状態正常" }
        if inflammationScore >= 0.4 { return "注意" }
        return "高い"
    }

    private var inflammationColor: Color {
        if inflammationScore >= 0.7 { return Color(hex: "5E7CE2") }
        if inflammationScore >= 0.4 { return Color(hex: "FFCB05") }
        return Color(hex: "ED1C24")
    }

    /// 回復スピード（ScoreEngineで計算、0-1の範囲）
    private var recoveryScore: Double {
        // ScoreEngineから取得（0-100スケール）→ 0-1に変換
        if let score = healthScoreService.recoveryScore {
            return score / 100.0
        }

        // データなしの場合はデフォルト値
        print("⚠️ 回復スピード: ScoreEngineからデータなし")
        return 0.71
    }

    private var recoveryStatus: String {
        if recoveryScore >= 0.7 { return "準備完了" }
        if recoveryScore >= 0.4 { return "回復中" }
        return "疲労"
    }

    private var recoveryColor: Color {
        if recoveryScore >= 0.7 { return Color(hex: "4FC0D0") }
        if recoveryScore >= 0.4 { return Color(hex: "FFCB05") }
        return Color(hex: "ED1C24")
    }

    /// 老化速度スコア（ScoreEngineで計算、0-1の範囲）
    private var agingScore: Double {
        // ScoreEngineから取得（0-100スケール）→ 0-1に変換
        if let score = healthScoreService.agingPaceScore {
            return score / 100.0
        }

        // データなしの場合はデフォルト値
        print("⚠️ 老化速度: ScoreEngineからデータなし")
        return 0.43
    }

    private var agingStatus: String {
        if agingScore >= 0.7 { return "優秀" }
        if agingScore >= 0.4 { return "普通" }
        return "低い"
    }

    private var agingColor: Color {
        if agingScore >= 0.7 { return Color(hex: "00C853") }
        if agingScore >= 0.4 { return Color(hex: "FFCB05") }
        return Color(hex: "ED1C24")
    }

    /// 代謝力のチャートデータ（過去7日間）
    private var metabolicChartData: [Double] {
        // デモモードの場合、7日分のデモデータを表示
        if demoModeManager.isDemoMode {
            return DemoModeManager.createDemoMetabolicChartData()
        }

        // 通常モードでは現在の値のみ（過去データがない場合）
        let currentValue = metabolicScore * 100
        return [currentValue]
    }

    /// 老化速度（歳/年）を計算
    private var agingRate: Double {
        // agingScoreは0-1の範囲で、1が最良（老化が遅い）、0が最悪（老化が速い）
        // 老化速度 = 2.0 - (agingScore * 1.5)
        // agingScore=1.0 → 0.5歳/年（非常に遅い老化）
        // agingScore=0.67 → 1.0歳/年（標準的な老化）
        // agingScore=0 → 2.0歳/年（非常に速い老化）
        let rate = 2.0 - (agingScore * 1.5)
        print("✅ 老化速度: \(String(format: "%.2f", rate))歳/年 (スコア: \(String(format: "%.2f", agingScore * 100))%)")
        return rate
    }

    private var agingRateStatus: String {
        if agingRate <= 0.8 { return "優秀" }
        if agingRate <= 1.2 { return "標準" }
        return "注意"
    }

    private var agingRateColor: Color {
        if agingRate <= 0.8 { return Color(hex: "00C853") }
        if agingRate <= 1.2 { return Color(hex: "FFCB05") }
        return Color(hex: "ED1C24")
    }

    /// 老化速度の横バープログレス（0-1）
    private var agingRateProgress: Double {
        // 0.5歳/年 → 1.0 (最良)
        // 1.0歳/年 → 0.67 (標準)
        // 2.0歳/年 → 0.0 (最悪)
        return max(0, min(1, (2.0 - agingRate) / 1.5))
    }
}

#if DEBUG
struct HealthMetricsGridSection_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var isExpanded = false
        @State private var expandedDetail: HealthMetricDetail? = nil

        var body: some View {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "FAFAFA"), Color(hex: "F0F0F0")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    HealthMetricsGridSection(isExpanded: $isExpanded, expandedCardDetail: $expandedDetail)
                        .padding(.top, 20)
                }
            }
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
#endif
