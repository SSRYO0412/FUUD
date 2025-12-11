//
//  DailyActionSection.swift
//  FUUD
//
//  日次目標セクション
//  血液検査結果・遺伝子データ・TDEEに基づき、パーソナライズされた日次目標を提示
//

import SwiftUI

// MARK: - Default Data (Fallback)

struct DailyActionDefaults {
    // デフォルト値（TDEE未取得時のフォールバック）
    static let calorieTarget = 2100
    static let protein = 20.0      // %
    static let fat = 25.0          // %
    static let carbs = 55.0        // %
    static let fiber = 25          // g
    static let vitaminD = 4000     // IU
    static let magnesium = 400     // mg
    static let omega3 = 2.0        // g
    static let zinc = 15           // mg

    // 運動目標（固定値）
    static let cardioMinutes = 30
    static let strengthMinutes = 15
    static let stepGoal = 10000
}

// MARK: - Main View

struct DailyActionSection: View {
    @StateObject private var personalizer = NutritionPersonalizer.shared
    @State private var showingChat = false
    @State private var showingReasons = false

    // MARK: - Computed Properties

    private var calorieTarget: Int {
        personalizer.targetCalories
    }

    private var proteinGrams: Int {
        personalizer.proteinGrams
    }

    private var fatGrams: Int {
        personalizer.fatGrams
    }

    private var carbsGrams: Int {
        personalizer.carbsGrams
    }

    private var isPersonalized: Bool {
        personalizer.adjustedCalories != nil
    }

    private var hasAdjustments: Bool {
        personalizer.hasAdjustmentReasons
    }

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // Header
            headerView

            // Calorie Target Card
            calorieTargetCard

            // Personalization Reasons (if any)
            if hasAdjustments {
                personalizationReasonsButton
            }

            // Orthomol Balance Card
            orthomolBalanceCard

            // Exercise Target Card
            DailyActionCard(
                icon: "🏃",
                title: "EXERCISE TARGET",
                mainValue: "有酸素 \(DailyActionDefaults.cardioMinutes)分 + 筋トレ \(DailyActionDefaults.strengthMinutes)分",
                subtitle: nil,
                benefit: "酸素を取り込む力が上がり、老化を防ぐホルモンが増加",
                accentColor: Color(hex: "0088CC")
            )

            // Step Goal Card
            DailyActionCard(
                icon: "👟",
                title: "STEP GOAL",
                mainValue: "\(DailyActionDefaults.stepGoal.formatted()) 歩",
                subtitle: nil,
                benefit: "血管がしなやかになり、心臓病リスクが20%減少",
                accentColor: Color(hex: "9C27B0")
            )

            // AI Chat Button
            aiChatButton
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
        .onAppear {
            Task {
                await personalizer.calculatePersonalization()
            }
        }
        .sheet(isPresented: $showingChat) {
            ChatView()
        }
        .sheet(isPresented: $showingReasons) {
            PersonalizationReasonsView(
                reasons: personalizer.adjustedCalories?.reasons ?? [],
                calorieAdjustment: personalizer.adjustedCalories
            )
        }
    }

    // MARK: - Header View

    private var headerView: some View {
        HStack {
            HStack(spacing: VirgilSpacing.xs) {
                Text("📋")
                    .font(.system(size: 14))
                Text("TODAY'S ACTION PLAN")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.virgilTextSecondary)
            }

            Spacer()

            if personalizer.isLoading {
                ProgressView()
                    .scaleEffect(0.6)
            } else if isPersonalized {
                Text("パーソナライズ済")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(Color(hex: "00C853"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "00C853").opacity(0.1))
                    .cornerRadius(4)
            } else {
                Text("デフォルト")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.virgilTextSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(4)
            }
        }
    }

    // MARK: - Calorie Target Card

    private var calorieTargetCard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
            HStack(spacing: VirgilSpacing.xs) {
                Text("🔥")
                    .font(.system(size: 14))
                Text("CALORIE TARGET")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.virgilTextPrimary)

                Spacer()

                // 調整率表示
                if let adjustment = personalizer.adjustedCalories,
                   adjustment.adjustmentPercent != 0 || adjustment.geneKcalDelta != 0 {
                    adjustmentBadge(adjustment: adjustment)
                }
            }

            Text("\(calorieTarget) kcal")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.virgilTextPrimary)

            // 目標タイプ表示
            if let goalType = personalizer.adjustedCalories?.goalType {
                Text(goalTypeText(goalType))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.virgilTextSecondary)
            }

            HStack(spacing: 4) {
                Text("→")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "FF6B35"))
                Text("脂肪を燃やしながら筋肉を守る最適なエネルギー量")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: "FF6B35"))
            }
        }
        .padding(VirgilSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.02))
        .cornerRadius(8)
    }

    private func adjustmentBadge(adjustment: CalorieAdjustment) -> some View {
        let percentText = adjustment.adjustmentPercent != 0
            ? String(format: "%+.0f%%", adjustment.adjustmentPercent * 100)
            : ""
        let kcalText = adjustment.geneKcalDelta != 0
            ? String(format: "%+dkcal", adjustment.geneKcalDelta)
            : ""

        let fullText = [percentText, kcalText].filter { !$0.isEmpty }.joined(separator: " ")
        let isNegative = adjustment.adjustmentPercent < 0 || adjustment.geneKcalDelta < 0

        return Text(fullText)
            .font(.system(size: 8, weight: .medium))
            .foregroundColor(isNegative ? Color(hex: "FF6B35") : Color(hex: "00C853"))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background((isNegative ? Color(hex: "FF6B35") : Color(hex: "00C853")).opacity(0.1))
            .cornerRadius(4)
    }

    private func goalTypeText(_ goalType: String) -> String {
        switch goalType {
        case "lose": return "減量目標"
        case "maintain": return "維持目標"
        case "gain": return "増量目標"
        default: return ""
        }
    }

    // MARK: - Personalization Reasons Button

    private var personalizationReasonsButton: some View {
        Button(action: {
            showingReasons = true
        }) {
            HStack(spacing: VirgilSpacing.xs) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: "0088CC"))

                Text("あなたのデータに基づく調整を確認")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(Color(hex: "0088CC"))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "0088CC"))
            }
            .padding(VirgilSpacing.xs)
            .background(Color(hex: "0088CC").opacity(0.08))
            .cornerRadius(6)
        }
    }

    // MARK: - Orthomol Balance Card

    private var orthomolBalanceCard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
            HStack(spacing: VirgilSpacing.xs) {
                Text("🧬")
                    .font(.system(size: 14))
                Text("ORTHOMOL BALANCE")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.virgilTextPrimary)
            }

            // Macro nutrients (PFC)
            HStack(spacing: VirgilSpacing.sm) {
                NutrientPill(label: "P", value: "\(proteinGrams)g", color: Color(hex: "ED1C24"))
                NutrientPill(label: "F", value: "\(fatGrams)g", color: Color(hex: "FFCB05"))
                NutrientPill(label: "C", value: "\(carbsGrams)g", color: Color(hex: "0088CC"))
                NutrientPill(label: "繊維", value: "\(DailyActionDefaults.fiber)g", color: Color(hex: "00C853"))
            }

            // PFC比率表示
            Text("P\(String(format: "%.0f", personalizer.pfcBalance.protein))% / F\(String(format: "%.0f", personalizer.pfcBalance.fat))% / C\(String(format: "%.0f", personalizer.pfcBalance.carbs))%")
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(.virgilTextSecondary)

            // Micro nutrients
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: VirgilSpacing.sm) {
                    MicroNutrientLabel(name: "ビタミンD", value: "\(DailyActionDefaults.vitaminD)IU")
                    MicroNutrientLabel(name: "マグネシウム", value: "\(DailyActionDefaults.magnesium)mg")
                }
                HStack(spacing: VirgilSpacing.sm) {
                    MicroNutrientLabel(name: "オメガ3", value: "\(String(format: "%.0f", DailyActionDefaults.omega3))g")
                    MicroNutrientLabel(name: "亜鉛", value: "\(DailyActionDefaults.zinc)mg")
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
    }

    // MARK: - AI Chat Button

    private var aiChatButton: some View {
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
