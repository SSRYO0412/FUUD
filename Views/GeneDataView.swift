//
//  GeneDataView.swift
//  AWStest
//
//  遺伝子データ表示画面（v6.0対応）
//

import SwiftUI

struct GeneDataView: View {
    @StateObject private var geneDataService = GeneDataService.shared

    var body: some View {
        Group {
            if geneDataService.isLoading {
                loadingView
            } else if !geneDataService.errorMessage.isEmpty {
                errorView
            } else if let geneData = geneDataService.geneData {
                geneDataContent(geneData: geneData)
            } else {
                emptyStateView
            }
        }
    }

    // MARK: - Gene Data Content

    @ViewBuilder
    private func geneDataContent(geneData: GeneDataService.GeneData) -> some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            // 全マーカーを縦に並べる（カテゴリータイトルなし）
            ForEach(geneData.categories, id: \.self) { category in
                ForEach(geneData.markers(for: category)) { marker in
                    GeneMarkerCard(marker: marker)
                }
            }
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack(spacing: VirgilSpacing.md) {
            ProgressView()
                .scaleEffect(1.2)
            Text("遺伝子データを読み込んでいます...")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.virgilTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .liquidGlassCard()
    }

    // MARK: - Error View

    private var errorView: some View {
        VStack(spacing: VirgilSpacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.red)

            Text("エラー")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.virgilTextPrimary)

            Text(geneDataService.errorMessage)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.virgilTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, VirgilSpacing.lg)

            Button(action: {
                Task {
                    await geneDataService.refreshData()
                }
            }) {
                Text("再試行")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, VirgilSpacing.lg)
                    .padding(.vertical, VirgilSpacing.sm)
                    .background(Color.blue)
                    .cornerRadius(VirgilSpacing.radiusMedium)
            }
        }
        .padding(VirgilSpacing.xl)
        .liquidGlassCard()
    }

    // MARK: - Empty State View

    private var emptyStateView: some View {
        VStack(spacing: VirgilSpacing.md) {
            Image(systemName: "dna")
                .font(.system(size: 40))
                .foregroundColor(.gray)

            Text("遺伝子データがありません")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.virgilTextPrimary)

            Text("遺伝子データをアップロードしてください")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.virgilTextSecondary)
                .multilineTextAlignment(.center)

            Button(action: {
                Task {
                    await geneDataService.fetchGeneData()
                }
            }) {
                Text("データを取得")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, VirgilSpacing.lg)
                    .padding(.vertical, VirgilSpacing.sm)
                    .background(Color.blue)
                    .cornerRadius(VirgilSpacing.radiusMedium)
            }
        }
        .padding(VirgilSpacing.xl)
        .liquidGlassCard()
    }

}

// MARK: - Preview

// MARK: - Gene Marker Card

struct GeneMarkerCard: View {
    let marker: GeneDataService.GeneticMarker

    // 事前計算済みのキャッシュを使用
    private var impact: SNPImpactCount {
        marker.cachedImpact ?? SNPImpactCount(protective: 0, risk: 0, neutral: 0)
    }

    // スコアに応じた色
    private var scoreColor: Color {
        switch impact.score {
        case 20...1000:
            return Color(hex: "00C853") // 緑（良好）
        case 1...19:
            return Color(hex: "66BB6A") // 薄緑
        case -19...0:
            return Color(hex: "FFCB05") // 黄色（中立）
        case -99...(-20):
            return Color(hex: "FF9800") // オレンジ（注意）
        default:
            return Color(hex: "ED1C24") // 赤（要注意）
        }
    }

    // スコアのフォーマット
    private var formattedScore: String {
        if impact.score > 0 {
            return "+\(impact.score)"
        } else {
            return "\(impact.score)"
        }
    }

    var body: some View {
        HStack {
            // 項目名（左寄せ）
            Text(marker.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.virgilTextPrimary)
                .lineLimit(1)

            Spacer()

            // スコア（右寄せ）
            Text(formattedScore)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(scoreColor)
        }
        .padding(.horizontal, VirgilSpacing.md)
        .padding(.vertical, VirgilSpacing.sm)
        .frame(maxWidth: .infinity)
        .liquidGlassCard()
    }
}

#if DEBUG
struct GeneDataView_Previews: PreviewProvider {
    static var previews: some View {
        GeneDataView()
    }
}
#endif
