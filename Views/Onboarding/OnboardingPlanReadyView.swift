//
//  OnboardingPlanReadyView.swift
//  FUUD
//
//  Lifesum風 プラン完成画面
//

import SwiftUI

struct OnboardingPlanReadyView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showDetails = false

    private let backgroundColor = Color(hex: "F5F0E8")
    private let primaryColor = Color(hex: "4CD964")

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Success checkmark
                ZStack {
                    Circle()
                        .fill(primaryColor)
                        .frame(width: 60, height: 60)

                    Image(systemName: "checkmark")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, 40)

                // Title
                VStack(spacing: 8) {
                    Text("\(viewModel.userData.firstName ?? "あなた")さん、")
                        .font(.system(size: 24, weight: .semibold))
                    Text("あなた専用のヘルスプランが完成しました！")
                        .font(.system(size: 24, weight: .semibold))
                }
                .multilineTextAlignment(.center)
                .foregroundColor(.primary)
                .padding(.horizontal, 24)

                // Nutrition card
                if let plan = viewModel.nutritionPlan {
                    nutritionCard(plan: plan)
                }

                // Goals section
                goalsSection

                // Get started button
                OnboardingPrimaryButton("GET STARTED") {
                    viewModel.nextStep()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: - Nutrition Card

    private func nutritionCard(plan: NutritionPlan) -> some View {
        VStack(spacing: 16) {
            Text("1日の栄養目標")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)

            Text("アプリでいつでも編集できます")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "6B7280"))

            VStack(spacing: 12) {
                nutritionRow(label: "カロリー", value: "\(plan.calories) kcal", color: .primary)

                Divider()

                nutritionRow(label: "炭水化物", value: "\(plan.carbsPercentage)%", color: Color(hex: "FF9500"))

                Divider()

                nutritionRow(label: "脂質", value: "\(plan.fatPercentage)%", color: Color(hex: "FFD60A"))

                Divider()

                nutritionRow(label: "タンパク質", value: "\(plan.proteinPercentage)%", color: Color(hex: "34C759"))

                Divider()

                nutritionRow(label: "ライフスコア", value: "\(plan.lifeScore) points", color: primaryColor)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 24)
    }

    private func nutritionRow(label: String, value: String, color: Color) -> some View {
        HStack {
            HStack(spacing: 8) {
                Rectangle()
                    .fill(color)
                    .frame(width: 4, height: 20)
                    .cornerRadius(2)

                Text(label)
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
            }

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.primary)
        }
    }

    // MARK: - Goals Section

    private var goalsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("目標達成のために：")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)

            VStack(spacing: 16) {
                ForEach(GoalAchievementItem.defaultItems) { item in
                    goalRow(item: item)
                }
            }

            // Sources link
            Button(action: {}) {
                Text("推奨事項のソース")
                    .font(.system(size: 14))
                    .foregroundColor(primaryColor)
                    .underline()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 24)
    }

    private func goalRow(item: GoalAchievementItem) -> some View {
        HStack(spacing: 12) {
            // Icon (プレースホルダー)
            if let _ = UIImage(named: item.icon) {
                Image(item.icon)
                    .resizable()
                    .frame(width: 40, height: 40)
            } else {
                // プレースホルダーアイコン
                Circle()
                    .fill(primaryColor.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: iconForGoal(item.icon))
                            .font(.system(size: 16))
                            .foregroundColor(primaryColor)
                    )
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 14))
                    .foregroundColor(.primary)
                if !item.description.isEmpty {
                    Text(item.description)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "6B7280"))
                }
            }

            Spacer()
        }
    }

    private func iconForGoal(_ name: String) -> String {
        switch name {
        case "goal_flower": return "leaf.fill"
        case "goal_pear": return "fork.knife"
        case "goal_avocado": return "flame.fill"
        case "goal_bars": return "chart.bar.fill"
        case "goal_water": return "drop.fill"
        default: return "star.fill"
        }
    }
}

// MARK: - Preview

#if DEBUG
struct OnboardingPlanReadyView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = OnboardingViewModel()
        vm.userData.firstName = "田中"
        vm.nutritionPlan = NutritionPlan.calculate(for: vm.userData)
        return OnboardingPlanReadyView(viewModel: vm)
            .background(Color(hex: "F5F0E8"))
    }
}
#endif
