//
//  HealthMetricDetailCard.swift
//  AWStest
//
//  HOMEカード詳細ビュー（Liquid Glassスタイル）
//

import SwiftUI

struct HealthMetricDetailCard: View {
    let detail: HealthMetricDetail
    var onClose: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // ヘッダーセクション
                    headerSection

                    // スコアブレークダウン
                    breakdownSection

                    // 主要マーカーTOP5
                    topMarkersSection

                    // 7日間トレンド
                    trendSection

                    // 推奨アクション
                    actionsSection
                }
                .padding(24)
                .padding(.top, 16)
            }
            .background(liquidGlassBackground)
            .overlay(alignment: .topTrailing) {
                closeButton
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 16) {
            // アイコン
            Image(systemName: detail.type.icon)
                .font(.system(size: 48, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: detail.type.accentColor), Color(hex: detail.type.accentColor).opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // タイトル
            Text(detail.type.rawValue)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)

            // スコア表示
            VStack(spacing: 4) {
                Text(detail.scoreDisplay)
                    .font(.system(size: 56, weight: .black))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: detail.type.accentColor), Color(hex: detail.type.accentColor).opacity(0.8)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text(detail.status)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.black.opacity(0.7))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    // MARK: - Breakdown Section

    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SCORE BREAKDOWN")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.black.opacity(0.6))
                .tracking(1.2)

            VStack(spacing: 12) {
                ForEach(detail.breakdowns) { breakdown in
                    BreakdownRow(breakdown: breakdown)
                }
            }
        }
        .padding(20)
        .background(liquidGlassCard)
    }

    // MARK: - Top Markers Section

    private var topMarkersSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("💉")
                    .font(.system(size: 16))
                Text("TOP 5 BLOOD MARKERS")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.black.opacity(0.6))
                    .tracking(1.2)
            }

            VStack(spacing: 12) {
                ForEach(detail.topMarkers) { marker in
                    MarkerRow(marker: marker)
                }
            }
        }
        .padding(20)
        .background(liquidGlassCard)
    }

    // MARK: - Trend Section

    private var trendSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("7-DAY TREND")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.black.opacity(0.6))
                .tracking(1.2)

            // シンプルな横バートレンド表示
            HStack(spacing: 4) {
                ForEach(detail.trendData) { data in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: detail.type.accentColor).opacity(0.8), Color(hex: detail.type.accentColor).opacity(0.4)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 8, height: CGFloat(data.value) * 0.8)

                        Spacer(minLength: 0)
                    }
                    .frame(height: 80)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(liquidGlassCard)
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("RECOMMENDATIONS")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.black.opacity(0.6))
                .tracking(1.2)

            VStack(spacing: 12) {
                ForEach(detail.actions) { action in
                    ActionCard(action: action)
                }
            }
        }
        .padding(20)
        .background(liquidGlassCard)
    }

    // MARK: - Close Button

    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 32))
                .foregroundStyle(.black.opacity(0.8), .black.opacity(0.1))
        }
        .padding(24)
    }

    // MARK: - Liquid Glass Styles

    private var liquidGlassBackground: some View {
        Color.clear
            .ignoresSafeArea()
    }

    @ViewBuilder
    private var liquidGlassCard: some View {
        if #available(iOS 26.0, *) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.clear)
                .glassEffect(.regular, in: .rect(cornerRadius: 16, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        }
    }
}

// MARK: - Breakdown Row Component

struct BreakdownRow: View {
    let breakdown: ScoreBreakdown

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(breakdown.category)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.black)

                Spacer()

                Text("\(Int(breakdown.percentage))%")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.black.opacity(0.6))
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景バー
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black.opacity(0.1))
                        .frame(height: 8)

                    // 進捗バー
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: breakdown.color), Color(hex: breakdown.color).opacity(0.6)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * (breakdown.value / 100), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Marker Row Component

struct MarkerRow: View {
    let marker: BloodMarker

    var body: some View {
        HStack(spacing: 12) {
            // マーカー名
            Text(marker.name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.black)
                .frame(width: 70, alignment: .leading)

            // 値
            Text("\(marker.value) \(marker.unit)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.black.opacity(0.8))
                .frame(maxWidth: .infinity, alignment: .leading)

            // ステータスバッジ
            Text(marker.status.rawValue)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(Color(hex: marker.status.color).opacity(0.3))
                        .overlay(
                            Capsule()
                                .stroke(Color(hex: marker.status.color).opacity(0.5), lineWidth: 1)
                        )
                )
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Action Card Component

struct ActionCard: View {
    let action: RecommendedAction

    var body: some View {
        HStack(spacing: 16) {
            // アイコン
            Text(action.icon)
                .font(.system(size: 28))

            // テキスト
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(action.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.black)

                    Spacer()

                    // 優先度バッジ
                    Text(action.priority.rawValue)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(Color(hex: action.priority.color).opacity(0.3))
                        )
                }

                Text(action.description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.black.opacity(0.7))
                    .lineSpacing(2)
            }
        }
        .padding(16)
        .background(actionCardBackground)
    }

    @ViewBuilder
    private var actionCardBackground: some View {
        if #available(iOS 26.0, *) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.clear)
                .glassEffect(.regular, in: .rect(cornerRadius: 12, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct HealthMetricDetailCard_Previews: PreviewProvider {
    static var previews: some View {
        HealthMetricDetailCard(
            detail: .metabolicSample,
            onClose: {}
        )
        .preferredColorScheme(.dark)
    }
}
#endif
