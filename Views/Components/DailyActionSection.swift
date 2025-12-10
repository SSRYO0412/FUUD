//
//  DailyActionSection.swift
//  TUUN
//
//  日次目標セクション
//  血液検査結果とバイタルデータをもとに、AIが最適な日次目標を提示
//

import SwiftUI

// MARK: - Demo Data

struct DailyActionData {
    // [DUMMY] 全てデモデータ - API連携後に実データへ置き換え予定

    // カロリー目標
    static let calorieTarget = 2100

    // 分子栄養学的栄養素目標
    static let protein = 150      // g
    static let fat = 70           // g
    static let carbs = 200        // g
    static let fiber = 25         // g
    static let vitaminD = 4000    // IU
    static let magnesium = 400    // mg
    static let omega3 = 2.0       // g
    static let zinc = 15          // mg

    // 運動目標
    static let cardioMinutes = 30
    static let strengthMinutes = 15

    // 歩数目標
    static let stepGoal = 10000
}

// MARK: - Main View

struct DailyActionSection: View {
    @State private var showingChat = false

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // Header
            HStack {
                HStack(spacing: VirgilSpacing.xs) {
                    Text("📋")
                        .font(.system(size: 14))
                    Text("TODAY'S ACTION PLAN")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)
                }

                Spacer()

                Text("AI最適化")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(Color(hex: "00C853"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "00C853").opacity(0.1))
                    .cornerRadius(4)
            }

            // Calorie Target Card
            DailyActionCard(
                icon: "🔥",
                title: "CALORIE TARGET",
                mainValue: "\(DailyActionData.calorieTarget) kcal",
                subtitle: nil,
                benefit: "脂肪を燃やしながら筋肉を守る最適なエネルギー量",
                accentColor: Color(hex: "FF6B35")
            )

            // Orthomol Balance Card
            VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
                HStack(spacing: VirgilSpacing.xs) {
                    Text("🧬")
                        .font(.system(size: 14))
                    Text("ORTHOMOL BALANCE")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.virgilTextPrimary)
                }

                // Macro nutrients
                HStack(spacing: VirgilSpacing.sm) {
                    NutrientPill(label: "P", value: "\(DailyActionData.protein)g", color: Color(hex: "ED1C24"))
                    NutrientPill(label: "F", value: "\(DailyActionData.fat)g", color: Color(hex: "FFCB05"))
                    NutrientPill(label: "C", value: "\(DailyActionData.carbs)g", color: Color(hex: "0088CC"))
                    NutrientPill(label: "繊維", value: "\(DailyActionData.fiber)g", color: Color(hex: "00C853"))
                }

                // Micro nutrients
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: VirgilSpacing.sm) {
                        MicroNutrientLabel(name: "ビタミンD", value: "\(DailyActionData.vitaminD)IU")
                        MicroNutrientLabel(name: "マグネシウム", value: "\(DailyActionData.magnesium)mg")
                    }
                    HStack(spacing: VirgilSpacing.sm) {
                        MicroNutrientLabel(name: "オメガ3", value: "\(String(format: "%.0f", DailyActionData.omega3))g")
                        MicroNutrientLabel(name: "亜鉛", value: "\(DailyActionData.zinc)mg")
                    }
                }
                .padding(.top, 4)

                // Benefit
                HStack(spacing: 4) {
                    Text("→")
                        .font(.system(size: 10))
                        .foregroundColor(Color(hex: "00C853"))
                    Text("細胞のエネルギー工場を活性化し、免疫力アップ・疲れにくい体へ")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "00C853"))
                }
                .padding(.top, 4)
            }
            .padding(VirgilSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black.opacity(0.02))
            .cornerRadius(8)

            // Exercise Target Card
            DailyActionCard(
                icon: "🏃",
                title: "EXERCISE TARGET",
                mainValue: "有酸素 \(DailyActionData.cardioMinutes)分 + 筋トレ \(DailyActionData.strengthMinutes)分",
                subtitle: nil,
                benefit: "酸素を取り込む力が上がり、老化を防ぐホルモンが増加",
                accentColor: Color(hex: "0088CC")
            )

            // Step Goal Card
            DailyActionCard(
                icon: "👟",
                title: "STEP GOAL",
                mainValue: "\(DailyActionData.stepGoal.formatted()) 歩",
                subtitle: nil,
                benefit: "血管がしなやかになり、心臓病リスクが20%減少",
                accentColor: Color(hex: "9C27B0")
            )

            // AI Chat Button
            Button(action: {
                showingChat = true
            }) {
                HStack {
                    Spacer()
                    HStack(spacing: VirgilSpacing.xs) {
                        Text("🤖")
                            .font(.system(size: 14))
                        Text("AIと目標を相談")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.virgilTextPrimary)
                    }
                    Spacer()
                }
                .padding(VirgilSpacing.sm)
                .background(Color.black.opacity(0.03))
                .cornerRadius(8)
            }
            .sheet(isPresented: $showingChat) {
                ChatView()
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }
}

// MARK: - Daily Action Card Component

private struct DailyActionCard: View {
    let icon: String
    let title: String
    let mainValue: String
    let subtitle: String?
    let benefit: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
            HStack(spacing: VirgilSpacing.xs) {
                Text(icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.virgilTextPrimary)
            }

            Text(mainValue)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.virgilTextPrimary)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.virgilTextSecondary)
            }

            HStack(spacing: 4) {
                Text("→")
                    .font(.system(size: 10))
                    .foregroundColor(accentColor)
                Text(benefit)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(accentColor)
            }
        }
        .padding(VirgilSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.02))
        .cornerRadius(8)
    }
}

// MARK: - Nutrient Pill Component

private struct NutrientPill: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 2) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 4)
                .padding(.vertical, 2)
                .background(color)
                .cornerRadius(3)

            Text(value)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.virgilTextPrimary)
        }
    }
}

// MARK: - Micro Nutrient Label Component

private struct MicroNutrientLabel: View {
    let name: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Text(name)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.virgilTextSecondary)
            Text(value)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.virgilTextPrimary)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct DailyActionSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.secondarySystemBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    DailyActionSection()
                }
                .padding()
            }
        }
    }
}
#endif
