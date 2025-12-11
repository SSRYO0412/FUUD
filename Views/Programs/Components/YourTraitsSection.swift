//
//  YourTraitsSection.swift
//  FUUD
//
//  Your Traits セクション - 統合カード + Liquid Glass
//

import SwiftUI

// MARK: - Your Traits Section Container

struct YourTraitsSection: View {
    @ObservedObject var viewModel: YourTraitsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            // セクションタイトル
            Text("YOUR TRAITS")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, VirgilSpacing.md)

            // 統合カード（常に表示、データなしはEmptyDataRowで表示）
            UnifiedTraitsCard(
                geneTraits: viewModel.traitsData.geneTraits,
                bloodSummary: viewModel.traitsData.bloodSummary,
                weightGoal: viewModel.traitsData.weightGoal,
                hasGeneData: viewModel.traitsData.hasGeneData,
                hasBloodData: viewModel.traitsData.hasBloodData,
                hasWeightData: viewModel.traitsData.hasWeightData
            )
            .padding(.horizontal, VirgilSpacing.md)
        }
    }
}

// MARK: - Unified Traits Card

struct UnifiedTraitsCard: View {
    let geneTraits: [GeneTraitResult]
    let bloodSummary: BloodTestSummary?
    let weightGoal: WeightGoalInfo?
    let hasGeneData: Bool
    let hasBloodData: Bool
    let hasWeightData: Bool

    var body: some View {
        VStack(spacing: 0) {
            // 遺伝子タイプセクション
            if hasGeneData {
                GeneTraitsRow(traits: geneTraits)
            } else {
                EmptyDataRow(icon: "🧬", title: "遺伝子タイプ", message: "データがありません")
            }

            // 区切り線
            Divider()
                .padding(.vertical, VirgilSpacing.sm)

            // 血液検査セクション
            if hasBloodData, let summary = bloodSummary {
                BloodTestRow(summary: summary)
            } else {
                EmptyDataRow(icon: "🩸", title: "血液検査", message: "データがありません")
            }

            // 区切り線
            Divider()
                .padding(.vertical, VirgilSpacing.sm)

            // 目標セクション
            if hasWeightData, let goal = weightGoal {
                WeightGoalRow(goal: goal)
            } else {
                EmptyDataRow(icon: "🎯", title: "目標", message: "データがありません")
            }
        }
        .padding(VirgilSpacing.md)
        .frame(maxWidth: .infinity)
        .liquidGlassCard()
    }
}

// MARK: - Gene Traits Row

struct GeneTraitsRow: View {
    let traits: [GeneTraitResult]

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            // ヘッダー
            HStack(spacing: 6) {
                Text("🧬")
                    .font(.system(size: 14))
                Text("遺伝子タイプ")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.lifesumDarkGreen)
            }

            // 4カテゴリ横並び
            HStack(spacing: 0) {
                ForEach(traits) { trait in
                    GeneTraitCell(trait: trait)
                    if trait.id != traits.last?.id {
                        Spacer(minLength: 4)
                    }
                }
            }
        }
    }
}

struct GeneTraitCell: View {
    let trait: GeneTraitResult

    var body: some View {
        VStack(spacing: 4) {
            Text(shortCategoryName(trait.categoryName))
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
                .lineLimit(1)

            Text(trait.evaluation)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(trait.status.color)
                .lineLimit(1)

            // 斜め矢印で評価を表現
            Image(systemName: statusArrowIcon)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(trait.status.color)
        }
        .frame(maxWidth: .infinity)
    }

    /// ステータスに応じた矢印アイコン
    private var statusArrowIcon: String {
        switch trait.status {
        case .positive: return "arrow.up.right"    // 斜め上 ↗
        case .neutral:  return "arrow.right"       // 横 →
        case .negative: return "arrow.down.right"  // 斜め下 ↘
        }
    }

    private func shortCategoryName(_ name: String) -> String {
        switch name {
        case "タンパク質応答": return "タンパク質"
        default: return name
        }
    }
}

// MARK: - Blood Test Row

struct BloodTestRow: View {
    let summary: BloodTestSummary

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            // ヘッダー
            HStack(spacing: 6) {
                Text("🩸")
                    .font(.system(size: 14))
                Text("血液検査")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.lifesumDarkGreen)
            }

            // チップ一覧
            if summary.isAllNormal {
                // 全て正常
                HStack(spacing: 6) {
                    BloodChip(
                        icon: "checkmark",
                        text: "正常",
                        count: summary.normalCount,
                        isNormal: true
                    )
                }
            } else {
                // 異常/注意項目 + 正常数
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        // 異常/注意項目を先に表示
                        ForEach(summary.highlightItems.filter { !$0.isNormal }) { item in
                            BloodChip(
                                icon: "exclamationmark.triangle.fill",
                                text: "\(item.nameJp) \(item.status)",
                                count: nil,
                                isNormal: false,
                                statusColor: item.statusColor
                            )
                        }

                        // 正常項目をまとめて表示
                        if summary.normalCount > 0 {
                            BloodChip(
                                icon: "checkmark",
                                text: "正常",
                                count: summary.normalCount,
                                isNormal: true
                            )
                        }
                    }
                }
            }
        }
    }
}

struct BloodChip: View {
    let icon: String
    let text: String
    let count: Int?
    let isNormal: Bool
    var statusColor: Color = .virgilWarning

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9))

            Text(text)
                .font(.system(size: 10, weight: .medium))

            if let count = count {
                Text("x\(count)")
                    .font(.system(size: 10, weight: .semibold))
            }
        }
        .foregroundColor(isNormal ? .secondary : statusColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isNormal ? Color.gray.opacity(0.1) : statusColor.opacity(0.1))
        .cornerRadius(4)
    }
}

// MARK: - Weight Goal Row

struct WeightGoalRow: View {
    let goal: WeightGoalInfo

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            // ヘッダー
            HStack(spacing: 6) {
                Text("🎯")
                    .font(.system(size: 14))
                Text("目標")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.lifesumDarkGreen)
            }

            // 体重情報（横一列）
            HStack(spacing: VirgilSpacing.sm) {
                // 現在
                VStack(spacing: 2) {
                    Text("現在")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    if let current = goal.currentWeight {
                        Text(String(format: "%.1f", current))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                        + Text(" kg")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    } else {
                        Text("--")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                }

                // 矢印
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(goal.goalType.color)

                // 目標
                VStack(spacing: 2) {
                    Text("目標")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                    if let target = goal.targetWeight {
                        Text(String(format: "%.1f", target))
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.lifesumDarkGreen)
                        + Text(" kg")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    } else {
                        Text("--")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // 残りチップ
                if let remaining = goal.remaining {
                    HStack(spacing: 4) {
                        Text(goal.goalType.displayName)
                            .font(.system(size: 10, weight: .semibold))
                        Text(String(format: "%+.1fkg", remaining))
                            .font(.system(size: 10, weight: .medium))
                    }
                    .foregroundColor(goal.goalType.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(goal.goalType.color.opacity(0.1))
                    .cornerRadius(4)
                }
            }
        }
    }
}

// MARK: - Empty Data Row

struct EmptyDataRow: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            HStack(spacing: 6) {
                Text(icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.lifesumDarkGreen)
            }
            Text(message)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            // サンプルの統合カード
            UnifiedTraitsCard(
                geneTraits: [
                    GeneTraitResult(id: "1", categoryName: "脂肪燃焼", score: 20, evaluation: "優位", status: .positive),
                    GeneTraitResult(id: "2", categoryName: "糖質代謝", score: -5, evaluation: "やや注意", status: .neutral),
                    GeneTraitResult(id: "3", categoryName: "タンパク質応答", score: 15, evaluation: "高応答型", status: .positive),
                    GeneTraitResult(id: "4", categoryName: "脂質代謝", score: 10, evaluation: "良好", status: .positive)
                ],
                bloodSummary: BloodTestSummary(
                    totalCount: 9,
                    normalCount: 7,
                    cautionCount: 1,
                    abnormalCount: 1,
                    highlightItems: [
                        .init(key: "TG", nameJp: "中性脂肪", status: "高い", isNormal: false),
                        .init(key: "gamma_gtp", nameJp: "γ-GTP", status: "注意", isNormal: false),
                        .init(key: "HbA1c", nameJp: "HbA1c", status: "正常", isNormal: true),
                        .init(key: "LDL", nameJp: "LDL", status: "正常", isNormal: true)
                    ],
                    isAllNormal: false
                ),
                weightGoal: WeightGoalInfo(
                    currentWeight: 75.0,
                    targetWeight: 70.0,
                    goalType: .lose,
                    remaining: -5.0
                ),
                hasGeneData: true,
                hasBloodData: true,
                hasWeightData: true
            )
            .padding(.horizontal, 16)

            // 全て正常パターン
            UnifiedTraitsCard(
                geneTraits: [
                    GeneTraitResult(id: "1", categoryName: "脂肪燃焼", score: 20, evaluation: "優位", status: .positive),
                    GeneTraitResult(id: "2", categoryName: "糖質代謝", score: 15, evaluation: "良好", status: .positive),
                    GeneTraitResult(id: "3", categoryName: "タンパク質応答", score: 15, evaluation: "高応答型", status: .positive),
                    GeneTraitResult(id: "4", categoryName: "脂質代謝", score: 10, evaluation: "良好", status: .positive)
                ],
                bloodSummary: BloodTestSummary(
                    totalCount: 9,
                    normalCount: 9,
                    cautionCount: 0,
                    abnormalCount: 0,
                    highlightItems: [],
                    isAllNormal: true
                ),
                weightGoal: WeightGoalInfo(
                    currentWeight: 70.0,
                    targetWeight: 70.0,
                    goalType: .maintain,
                    remaining: 0
                ),
                hasGeneData: true,
                hasBloodData: true,
                hasWeightData: true
            )
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 20)
    }
    .background(Color(.systemBackground))
}
