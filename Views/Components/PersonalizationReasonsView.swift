//
//  PersonalizationReasonsView.swift
//  FUUD
//
//  パーソナライズ調整理由の詳細表示ビュー
//  血液検査・遺伝子データに基づく調整内容を説明
//

import SwiftUI

struct PersonalizationReasonsView: View {
    @Environment(\.dismiss) private var dismiss

    let reasons: [AdjustmentReason]
    let calorieAdjustment: CalorieAdjustment?

    // 血液由来と遺伝子由来で分類
    private var bloodReasons: [AdjustmentReason] {
        reasons.filter { $0.isBloodBased }
    }

    private var geneReasons: [AdjustmentReason] {
        reasons.filter { !$0.isBloodBased }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: VirgilSpacing.lg) {
                    // ヘッダー説明
                    headerSection

                    // サマリーカード
                    if let adjustment = calorieAdjustment {
                        summaryCard(adjustment: adjustment)
                    }

                    // 血液データによる調整
                    if !bloodReasons.isEmpty {
                        reasonSection(
                            title: "血液検査データに基づく調整",
                            icon: "🩸",
                            reasons: bloodReasons,
                            accentColor: Color(hex: "ED1C24")
                        )
                    }

                    // 遺伝子データによる調整
                    if !geneReasons.isEmpty {
                        reasonSection(
                            title: "遺伝子データに基づく調整",
                            icon: "🧬",
                            reasons: geneReasons,
                            accentColor: Color(hex: "9C27B0")
                        )
                    }

                    // ディスクレイマー
                    disclaimerSection
                }
                .padding(VirgilSpacing.md)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("パーソナライズ詳細")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            Text("あなた専用の目標設定")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.virgilTextPrimary)

            Text("血液検査結果と遺伝子データを分析し、あなたに最適化されたカロリー目標とPFCバランスを算出しています。")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.virgilTextSecondary)
                .lineSpacing(4)
        }
        .padding(VirgilSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    // MARK: - Summary Card

    private func summaryCard(adjustment: CalorieAdjustment) -> some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            HStack {
                Text("調整サマリー")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.virgilTextPrimary)

                Spacer()

                // 信頼度バッジ
                confidenceBadge(confidence: adjustment.confidence)
            }

            Divider()

            // 基本TDEE
            HStack {
                Text("基礎TDEE")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.virgilTextSecondary)
                Spacer()
                Text("\(adjustment.baseTDEE) kcal")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.virgilTextPrimary)
            }

            // 目標カロリー（調整前）
            HStack {
                Text("目標カロリー（調整前）")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.virgilTextSecondary)
                Spacer()
                Text("\(adjustment.baseTarget) kcal")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.virgilTextPrimary)
            }

            // 血液データ調整
            if adjustment.adjustmentPercent != 0 {
                HStack {
                    Text("血液データ調整")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.virgilTextSecondary)
                    Spacer()
                    Text(String(format: "%+.0f%%", adjustment.adjustmentPercent * 100))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(adjustment.adjustmentPercent < 0 ? Color(hex: "FF6B35") : Color(hex: "00C853"))
                }
            }

            // 遺伝子データ調整
            if adjustment.geneKcalDelta != 0 {
                HStack {
                    Text("遺伝子データ調整")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.virgilTextSecondary)
                    Spacer()
                    Text(String(format: "%+d kcal", adjustment.geneKcalDelta))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(adjustment.geneKcalDelta < 0 ? Color(hex: "FF6B35") : Color(hex: "00C853"))
                }
            }

            Divider()

            // 最終目標
            HStack {
                Text("パーソナライズ後の目標")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.virgilTextPrimary)
                Spacer()
                Text("\(adjustment.adjustedTarget) kcal")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "00C853"))
            }
        }
        .padding(VirgilSpacing.md)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private func confidenceBadge(confidence: String) -> some View {
        let (text, color): (String, Color) = {
            switch confidence {
            case "high":
                return ("高精度", Color(hex: "00C853"))
            case "medium":
                return ("中精度", Color(hex: "FFCB05"))
            default:
                return ("参考値", Color.gray)
            }
        }()

        return Text(text)
            .font(.system(size: 10, weight: .medium))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .cornerRadius(4)
    }

    // MARK: - Reason Section

    private func reasonSection(title: String, icon: String, reasons: [AdjustmentReason], accentColor: Color) -> some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            HStack(spacing: VirgilSpacing.xs) {
                Text(icon)
                    .font(.system(size: 16))
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.virgilTextPrimary)
            }

            VStack(spacing: VirgilSpacing.xs) {
                ForEach(reasons) { reason in
                    reasonRow(reason: reason, accentColor: accentColor)
                }
            }
        }
        .padding(VirgilSpacing.md)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private func reasonRow(reason: AdjustmentReason, accentColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(reason.displayText)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.virgilTextPrimary)

            HStack(spacing: 4) {
                Text("→")
                    .font(.system(size: 10))
                    .foregroundColor(accentColor)
                Text(reason.adjustmentText)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(accentColor)
            }
        }
        .padding(VirgilSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(accentColor.opacity(0.05))
        .cornerRadius(8)
    }

    // MARK: - Disclaimer Section

    private var disclaimerSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            HStack(spacing: VirgilSpacing.xs) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "FFCB05"))
                Text("ご注意")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.virgilTextPrimary)
            }

            Text("この情報は医療診断ではなく、生活習慣改善の目安としてご利用ください。検査値が大きく外れている場合や、体調に不安がある場合は、医療機関にご相談ください。")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.virgilTextSecondary)
                .lineSpacing(3)
        }
        .padding(VirgilSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "FFCB05").opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#if DEBUG
struct PersonalizationReasonsView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalizationReasonsView(
            reasons: [
                .highHbA1c(value: 6.2),
                .highTG(value: 180),
                .geneBasalMetabolismLow,
                .geneHighProteinEffective
            ],
            calorieAdjustment: CalorieAdjustment(
                baseTDEE: 2100,
                baseTarget: 1800,
                bmr: 1650,
                adjustedTarget: 1680,
                adjustmentPercent: -0.10,
                geneKcalDelta: -30,
                reasons: [],
                confidence: "high",
                goalType: "lose"
            )
        )
    }
}
#endif
