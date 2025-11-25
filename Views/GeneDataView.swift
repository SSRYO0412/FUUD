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
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // メタ情報カード
            metaInfoCard(geneData: geneData)

            // カテゴリー別遺伝子マーカー表示
            ForEach(geneData.categories, id: \.self) { category in
                categoryCard(category: category, markers: geneData.markers(for: category))
            }
        }
    }

    // MARK: - Meta Info Card

    @ViewBuilder
    private func metaInfoCard(geneData: GeneDataService.GeneData) -> some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            Text("GENETIC ANALYSIS")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.gray)

            VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
                HStack {
                    Text("解析日時")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.virgilTextSecondary)
                    Spacer()
                    Text(geneData.formattedTimestamp)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.virgilTextPrimary)
                }

                HStack {
                    Text("処理された遺伝子型")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.virgilTextSecondary)
                    Spacer()
                    Text("\(Int(geneData.totalGenotypesProcessed).formatted())")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.virgilTextPrimary)
                }

                HStack {
                    Text("データ品質スコア")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.virgilTextSecondary)
                    Spacer()
                    Text(String(format: "%.2f", geneData.dataQualityScore))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(qualityScoreColor(geneData.dataQualityScore))
                }

                HStack {
                    Text("バージョン")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.virgilTextSecondary)
                    Spacer()
                    Text("v\(geneData.version)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.virgilTextPrimary)
                }
            }
            .padding(VirgilSpacing.md)
            .background(Color.black.opacity(0.02))
            .cornerRadius(VirgilSpacing.radiusMedium)
        }
        .virgilGlassCard()
    }

    // MARK: - Category Card

    @ViewBuilder
    private func categoryCard(category: String, markers: [GeneDataService.GeneticMarker]) -> some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            // カテゴリー名
            Text(category)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.virgilTextPrimary)
                .padding(.bottom, VirgilSpacing.xs)

            // マーカーリスト
            VStack(spacing: VirgilSpacing.xs) {
                ForEach(markers) { marker in
                    markerDisclosure(marker: marker)
                }
            }
        }
        .virgilGlassCard()
    }

    // MARK: - Marker Disclosure

    @ViewBuilder
    private func markerDisclosure(marker: GeneDataService.GeneticMarker) -> some View {
        // 事前計算済みのキャッシュを使用（ビュー描画時の重い計算を回避）
        let impact = marker.cachedImpact ?? SNPImpactCount(protective: 0, risk: 0, neutral: 0)

        DisclosureGroup {
            VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
                // 影響因子カウント表示
                HStack(spacing: VirgilSpacing.sm) {
                    HStack(spacing: 4) {
                        Text("🟢")
                            .font(.system(size: 10))
                        Text("保護: \(impact.protective)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(hex: "66BB6A"))
                    }
                    HStack(spacing: 4) {
                        Text("🔴")
                            .font(.system(size: 10))
                        Text("リスク: \(impact.risk)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(Color(hex: "E57373"))
                    }
                    HStack(spacing: 4) {
                        Text("⚪️")
                            .font(.system(size: 10))
                        Text("中立: \(impact.neutral)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.bottom, VirgilSpacing.xs)

                Divider()
                    .padding(.vertical, VirgilSpacing.xs)

                // SNP情報表示
                ForEach(marker.snpIDs, id: \.self) { snpID in
                    if let genotype = marker.genotype(for: snpID) {
                        HStack {
                            Text(snpID)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.virgilTextSecondary)
                            Spacer()
                            Text(genotype)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.virgilTextPrimary)
                                .padding(.horizontal, VirgilSpacing.xs)
                                .padding(.vertical, 2)
                                .background(Color(hex: "E3F2FD"))
                                .cornerRadius(4)
                        }
                        .padding(.vertical, 2)
                    }
                }

                // スコア表示
                HStack {
                    Text("影響スコア:")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.gray)
                    Text("\(impact.score > 0 ? "+" : "")\(impact.score)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(scoreColor(impact.score))
                }
                .padding(.top, VirgilSpacing.xs)
            }
            .padding(VirgilSpacing.sm)
            .background(Color.black.opacity(0.01))
            .cornerRadius(VirgilSpacing.radiusSmall)
        } label: {
            VStack(spacing: VirgilSpacing.xs) {
                HStack {
                    Text(marker.title)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.virgilTextPrimary)
                    Spacer()
                    Text("\(marker.snpCount)")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.gray)
                }

                // 影響因子カウントサマリー
                HStack(spacing: VirgilSpacing.xs) {
                    Text("🟢 \(impact.protective)")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color(hex: "66BB6A"))
                    Text("🔴 \(impact.risk)")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(Color(hex: "E57373"))
                    Text("⚪️ \(impact.neutral)")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
            .padding(.vertical, VirgilSpacing.xs)
        }
        .padding(VirgilSpacing.sm)
        .background(Color.black.opacity(0.02))
        .cornerRadius(VirgilSpacing.radiusMedium)
    }

    /// スコアに応じた色を返す
    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 20...100:
            return Color(hex: "66BB6A") // 緑（優秀）
        case -19...19:
            return Color(hex: "FBC02D") // 黄色（中立）
        default:
            return Color(hex: "E57373") // 赤（要注意）
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
        .virgilGlassCard()
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
        .virgilGlassCard()
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
        .virgilGlassCard()
    }

    // MARK: - Helper Functions

    /// データ品質スコアに応じた色を返す
    private func qualityScoreColor(_ score: Double) -> Color {
        switch score {
        case 0.8...1.0:
            return Color(hex: "66BB6A") // 緑（優秀）
        case 0.5...0.79:
            return Color(hex: "FBC02D") // 黄色（良好）
        default:
            return Color(hex: "E57373") // 赤（要改善）
        }
    }
}

// MARK: - Preview

#if DEBUG
struct GeneDataView_Previews: PreviewProvider {
    static var previews: some View {
        GeneDataView()
    }
}
#endif
