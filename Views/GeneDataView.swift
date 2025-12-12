//
//  GeneDataView.swift
//  AWStest
//
//  遺伝子データ表示画面（大カテゴリーカード + 詳細モーダル）
//

import SwiftUI

struct GeneDataView: View {
    @StateObject private var geneDataService = GeneDataService.shared

    /// カテゴリー選択時のコールバック（親で処理）
    var onCategorySelected: ((GeneCategoryGroup) -> Void)?

    var body: some View {
        Group {
            if geneDataService.isLoading {
                loadingView
            } else if !geneDataService.errorMessage.isEmpty {
                errorView
            } else if geneDataService.geneData != nil {
                geneDataContent
            } else {
                emptyStateView
            }
        }
    }

    // MARK: - Gene Data Content (大カテゴリーカード一覧)

    private var geneDataContent: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // 大カテゴリーカードを表示
            ForEach(geneDataService.generateCategoryGroups()) { group in
                GeneCategoryCard(category: group)
                    .onTapGesture {
                        onCategorySelected?(group)
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

// MARK: - Gene Category Card (大カテゴリーカード)

struct GeneCategoryCard: View {
    let category: GeneCategoryGroup

    // スコアに応じた色
    private var scoreColor: Color {
        switch category.averageScore {
        case 20...100:
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

    var body: some View {
        HStack(spacing: VirgilSpacing.md) {
            // アイコン
            Image(systemName: category.icon)
                .font(.system(size: 24))
                .foregroundColor(scoreColor)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                // 大カテゴリー名
                Text(category.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.virgilTextPrimary)

                // タイプ名
                Text(category.typeName)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.virgilTextSecondary)
            }

            Spacer()

            // 矢印アイコン
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)
        }
        .padding(VirgilSpacing.md)
        .frame(maxWidth: .infinity)
        .liquidGlassCard()
    }
}

// MARK: - Gene Category Detail Overlay (詳細モーダル)

struct GeneCategoryDetailOverlay: View {
    let category: GeneCategoryGroup
    @Binding var isPresented: Bool
    @State private var dragOffset: CGFloat = 0
    @State private var opacity: Double = 1

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景タップで閉じる（透明）
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        closeDetail()
                    }

                // 詳細カード（画面全体）
                VStack(spacing: 0) {
                    // ドラッグインジケーター
                    RoundedRectangle(cornerRadius: 2.5)
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 40, height: 5)
                        .padding(.top, VirgilSpacing.sm)
                        .padding(.bottom, VirgilSpacing.md)

                    ScrollView {
                        VStack(alignment: .leading, spacing: VirgilSpacing.lg) {
                            // ヘッダー
                            detailHeader

                            // 遺伝子説明
                            descriptionSection

                            // 小カテゴリーカード一覧
                            markersSection
                        }
                        .padding(.horizontal, VirgilSpacing.md)
                        .padding(.top, 60)
                        .padding(.bottom, VirgilSpacing.xl)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
                // 上部フェードオーバーレイ（VStackの上に重ねる）
                .overlay(alignment: .top) {
                    LinearGradient(
                        colors: [
                            Color(.secondarySystemBackground),
                            Color(.secondarySystemBackground).opacity(0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 60)
                    .blur(radius: 8)
                    .allowsHitTesting(false)
                }
                .offset(y: dragOffset)
                .opacity(opacity)
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.height > 0 {
                                dragOffset = value.translation.height
                                opacity = max(0.0, 1.0 - Double(dragOffset / 200))
                            }
                        }
                        .onEnded { value in
                            if value.translation.height > 300 {
                                closeDetail()
                            } else {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    dragOffset = 0
                                    opacity = 1
                                }
                            }
                        }
                )
            }
            .padding(.top, geometry.safeAreaInsets.top * 0.5) // SafeAreaの半分の位置
        }
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var detailHeader: some View {
        HStack(spacing: VirgilSpacing.md) {
            // アイコン
            Image(systemName: category.icon)
                .font(.system(size: 32))
                .foregroundColor(scoreColor)
                .frame(width: 50, height: 50)

            VStack(alignment: .leading, spacing: 4) {
                // 大カテゴリー名
                Text(category.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.virgilTextPrimary)

                // タイプ名
                Text(category.typeName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(scoreColor)
            }

            Spacer()

            // 閉じるボタン
            Button(action: { closeDetail() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.gray)
            }
        }
    }

    // MARK: - Description Section

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            Text("あなたの遺伝子")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            Text(category.description)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.virgilTextPrimary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(VirgilSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(VirgilSpacing.radiusMedium)
    }

    // MARK: - Markers Section

    private var markersSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            Text("詳細項目")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            ForEach(category.markers) { marker in
                GeneMarkerCard(marker: marker)
            }
        }
    }

    // MARK: - Helpers

    private var scoreColor: Color {
        switch category.averageScore {
        case 20...100:
            return Color(hex: "00C853")
        case 1...19:
            return Color(hex: "66BB6A")
        case -19...0:
            return Color(hex: "FFCB05")
        case -99...(-20):
            return Color(hex: "FF9800")
        default:
            return Color(hex: "ED1C24")
        }
    }

    private func closeDetail() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isPresented = false
        }
    }
}

// MARK: - Gene Marker Card (小カテゴリーカード)

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

    var body: some View {
        HStack {
            // 項目名（左寄せ）
            Text(marker.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.virgilTextPrimary)
                .lineLimit(1)

            Spacer()

            // 5段階評価（右寄せ）
            Text(impact.scoreLevel.rawValue)
                .font(.system(size: 16, weight: .bold))
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
