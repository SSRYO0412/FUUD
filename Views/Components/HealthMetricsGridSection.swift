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
        let currentValue = metabolicScore * 100
        // 現在のデータポイントのみ（過去データがない場合）
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
    static var previews: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "FAFAFA"), Color(hex: "F0F0F0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                HealthMetricsGridSection()
                    .padding(.top, 20)
            }
        }
    }
}
#endif
