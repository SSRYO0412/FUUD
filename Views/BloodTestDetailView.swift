//
//  BloodTestDetailView.swift
//  AWStest
//
//  血液検査項目詳細画面（Virgilデザイン）
//

import SwiftUI
import Charts

struct BloodTestDetailView: View {
    let bloodItem: BloodTestService.BloodItem

    // 絵文字マッピング（BloodItemCardと同じロジック）
    var emoji: String {
        let key = bloodItem.key.lowercased()
        switch key {
        // 血糖・代謝系
        case "hba1c", "hemoglobin_a1c": return "🍬"
        case "glucose", "glu", "blood_sugar": return "🩸"
        case "ga", "glycoalbumin": return "🍰"
        case "1,5-ag", "1_5_ag": return "🍯"

        // 肝機能系
        case "ast", "got": return "🫘"
        case "alt", "gpt": return "🫘"
        case "ggt", "γ-gtp", "gamma_gtp": return "🫁"
        case "alp": return "🦴"
        case "t-bil", "tbil", "total_bilirubin": return "💛"
        case "d-bil", "dbil", "direct_bilirubin": return "💛"

        // 脂質系
        case "tc", "tcho", "total_cholesterol": return "🧈"
        case "tg", "triglyceride": return "🥓"
        case "hdl", "hdl_cholesterol": return "✨"
        case "ldl", "ldl_cholesterol": return "⚠️"
        case "apob", "apo_b": return "🔬"
        case "lp(a)", "lipoprotein_a": return "🧬"

        // タンパク質系
        case "tp", "total_protein": return "🥩"
        case "alb", "albumin": return "🥚"
        case "palb", "prealbumin": return "🥛"

        // 腎機能系
        case "bun", "urea_nitrogen": return "🫘"
        case "cre", "creatinine": return "🫘"
        case "ua", "uric_acid": return "💎"
        case "egfr": return "🚰"

        // 炎症・免疫系
        case "crp", "c_reactive_protein": return "🔥"
        case "wbc", "white_blood_cell": return "🛡️"
        case "neutrophil": return "⚔️"

        // 血液成分系
        case "rbc", "red_blood_cell": return "🔴"
        case "hb", "hemoglobin": return "🩸"
        case "ht", "hematocrit": return "📊"
        case "mcv": return "📏"
        case "mch": return "📐"
        case "mchc": return "🎨"
        case "plt", "platelet": return "🩹"

        // ミネラル・ビタミン系
        case "fe", "iron": return "⚙️"
        case "ferritin": return "🧲"
        case "zn", "zinc": return "⚡"
        case "mg", "magnesium": return "💚"
        case "ca", "calcium": return "🦴"
        case "vitamin_d", "vit_d": return "☀️"
        case "vitamin_b12", "vit_b12": return "🌟"

        // 筋肉・運動系
        case "ck", "cpk", "creatine_kinase": return "💪"
        case "mb", "myoglobin": return "🏃"
        case "lac", "lactate": return "🔋"

        // 甲状腺系
        case "tsh": return "🦋"
        case "ft3", "ft4": return "🦋"

        // ホルモン系
        case "cortisol": return "😰"
        case "testosterone": return "💪"
        case "estrogen": return "🌸"

        default: return "🔬"
        }
    }

    // ステータス色
    var statusColor: Color {
        switch bloodItem.statusColor {
        case "green":
            return Color(hex: "00C853")
        case "orange":
            return Color(hex: "FFCB05")
        case "red":
            return Color(hex: "ED1C24")
        default:
            return .gray
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.lg) {
                // ヘッダースコアカード
                VStack(spacing: VirgilSpacing.sm) {
                    Text(emoji)
                        .font(.system(size: 32))

                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(bloodItem.value)
                            .font(.system(size: 40, weight: .black))
                            .foregroundColor(statusColor)

                        Text(bloodItem.unit)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.virgilTextSecondary)
                    }

                    Text(bloodItem.status)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(statusColor.opacity(0.15))
                        .cornerRadius(8)

                    Text(bloodItem.nameJp.uppercased())
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)
                        .padding(.top, 4)
                }
                .frame(maxWidth: .infinity)
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // 詳細情報カード
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("詳細情報")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    VStack(spacing: VirgilSpacing.sm) {
                        DetailInfoRow(label: "検査項目", value: bloodItem.nameJp)
                        DetailInfoRow(label: "項目キー", value: bloodItem.key.uppercased())
                        DetailInfoRow(label: "測定値", value: "\(bloodItem.value) \(bloodItem.unit)")
                        DetailInfoRow(label: "判定", value: bloodItem.status, valueColor: statusColor)
                        DetailInfoRow(label: "基準範囲", value: bloodItem.reference)
                    }
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // 推奨事項カード
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("推奨事項")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    VStack(spacing: VirgilSpacing.sm) {
                        ForEach(Array(getRecommendations().enumerated()), id: \.offset) { index, recommendation in
                            BloodRecommendationCard(
                                icon: index == 0 ? "💡" : (index == 1 ? "🎯" : "📋"),
                                text: recommendation,
                                priority: index == 0 ? "高" : (index == 1 ? "中" : "低")
                            )
                        }
                    }
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()

                // 履歴トレンドカード（将来実装）
                VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                    Text("履歴トレンド")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    VStack(spacing: VirgilSpacing.md) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 40))
                            .foregroundColor(.virgilTextSecondary)

                        Text("過去の検査結果を表示する機能は今後実装予定です")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.virgilTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(VirgilSpacing.xl)
                    .background(Color.black.opacity(0.02))
                    .cornerRadius(12)
                }
                .padding(VirgilSpacing.md)
                .virgilGlassCard()
            }
            .padding(.horizontal, VirgilSpacing.md)
            .padding(.top, VirgilSpacing.md)
            .padding(.bottom, 100)
        }
        .background(
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "FAFAFA"), Color(hex: "F0F0F0")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                OrbBackground()
                GridOverlay()
            }
        )
        .navigationTitle(bloodItem.nameJp)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Helper Methods

    private func getRecommendations() -> [String] {
        // 血液検査項目に基づく簡単な推奨事項生成
        let status = bloodItem.status.lowercased()
        let key = bloodItem.key.lowercased()

        var recommendations: [String] = []

        if ["正常", "normal"].contains(status) {
            recommendations.append("現在の値は正常範囲内です。現在の生活習慣を維持してください。")
            recommendations.append("定期的な健康診断を受けることをお勧めします。")
        } else {
            recommendations.append("値が基準範囲外です。医師に相談することをお勧めします。")

            if key.contains("glucose") || key.contains("血糖") {
                recommendations.append("食事のバランスを見直し、適度な運動を心がけてください。")
                recommendations.append("糖質の摂取量に注意してください。")
            } else if key.contains("cholesterol") || key.contains("コレステロール") {
                recommendations.append("飽和脂肪酸の摂取を控え、オメガ3脂肪酸を摂取してください。")
                recommendations.append("定期的な有酸素運動を行ってください。")
            } else if key.contains("pressure") || key.contains("血圧") {
                recommendations.append("塩分摂取量を控えてください。")
                recommendations.append("ストレス管理と十分な睡眠を心がけてください。")
            } else {
                recommendations.append("バランスの取れた食事と適度な運動を心がけてください。")
                recommendations.append("十分な休息とストレス管理を行ってください。")
            }
        }

        return recommendations
    }
}

// MARK: - Detail Info Row

struct DetailInfoRow: View {
    let label: String
    let value: String
    var valueColor: Color? = nil

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.virgilTextSecondary)
                .frame(width: 70, alignment: .leading)

            Text(value)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(valueColor ?? .virgilTextPrimary)

            Spacer()
        }
        .padding(VirgilSpacing.sm)
        .background(Color.black.opacity(0.02))
        .cornerRadius(6)
    }
}

// MARK: - Blood Recommendation Card

struct BloodRecommendationCard: View {
    let icon: String
    let text: String
    let priority: String

    private var priorityColor: Color {
        switch priority {
        case "高": return Color(hex: "ED1C24")
        case "中": return Color(hex: "FFCB05")
        case "低": return Color(hex: "0088CC")
        default: return .gray
        }
    }

    var body: some View {
        HStack(spacing: VirgilSpacing.md) {
            Text(icon)
                .font(.system(size: 20))

            VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
                Text(text)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.virgilTextPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Text(priority)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(priorityColor)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(priorityColor.opacity(0.1))
                .cornerRadius(4)
        }
        .padding(VirgilSpacing.sm)
        .background(Color.black.opacity(0.02))
        .cornerRadius(8)
    }
}

// MARK: - Preview

struct BloodTestDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BloodTestDetailView(
                bloodItem: BloodTestService.BloodItem(
                    key: "glucose",
                    nameJp: "血糖値",
                    value: "95",
                    unit: "mg/dL",
                    status: "正常",
                    reference: "70-110"
                )
            )
        }
    }
}
