//
//  AIInsightCard.swift
//  FUUD
//
//  Lifesum風AIインサイトカード
//

import SwiftUI

struct AIInsightCard: View {
    @StateObject private var personalizer = NutritionPersonalizer.shared
    @StateObject private var mealService = MealLogService.shared

    var body: some View {
        HStack(alignment: .top, spacing: VirgilSpacing.sm) {
            // Emoji indicator
            Text(insightEmoji)
                .font(.system(size: 20))

            // Insight message
            Text(insightMessage)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.virgilTextPrimary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(VirgilSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.lifesumCream.opacity(0.5))
        .cornerRadius(12)
    }

    // MARK: - Computed Properties

    private var insightEmoji: String {
        let totals = mealService.todayTotals
        let targetCalories = personalizer.adjustedCalories?.adjustedTarget ?? 1800
        let proteinTarget = personalizer.pfcBalance.proteinGrams(for: targetCalories)

        // Determine insight based on current progress
        let calorieProgress = Double(totals.calories) / Double(targetCalories)
        let proteinProgress = Double(totals.protein) / Double(proteinTarget)

        if proteinProgress >= 0.9 {
            return "💪"
        } else if calorieProgress > 1.1 {
            return "⚠️"
        } else if calorieProgress >= 0.8 {
            return "🎯"
        } else {
            return "✨"
        }
    }

    private var insightMessage: String {
        let totals = mealService.todayTotals
        let targetCalories = personalizer.adjustedCalories?.adjustedTarget ?? 1800
        let proteinTarget = personalizer.pfcBalance.proteinGrams(for: targetCalories)
        let carbsTarget = personalizer.pfcBalance.carbsGrams(for: targetCalories)
        let fatTarget = personalizer.pfcBalance.fatGrams(for: targetCalories)

        let calorieProgress = Double(totals.calories) / Double(targetCalories)
        let proteinProgress = Double(totals.protein) / Double(proteinTarget)
        let carbsProgress = Double(totals.carbs) / Double(carbsTarget)
        let fatProgress = Double(totals.fat) / Double(fatTarget)

        // Generate contextual insight
        if totals.calories == 0 {
            return "今日の食事をまだ記録していません。朝食から始めましょう！"
        }

        if calorieProgress > 1.1 {
            return "今日のカロリー目標を超えました。明日は少し控えめにすると良いかもしれません。"
        }

        if proteinProgress >= 1.0 {
            return "タンパク質の目標を達成しました！筋肉の維持・成長に最適です。"
        }

        if proteinProgress >= 0.8 && calorieProgress < 0.9 {
            return "タンパク質の摂取量が目標に近づいています！この調子で続けましょう。"
        }

        if carbsProgress > 1.2 && fatProgress < 0.7 {
            return "糖質が多めです。脂質とのバランスを意識してみましょう。"
        }

        if calorieProgress >= 0.7 && calorieProgress < 0.9 {
            return "順調に進んでいます。あと少しで今日の目標達成です！"
        }

        if calorieProgress < 0.5 {
            return "まだ余裕があります。バランスの良い食事を心がけましょう。"
        }

        return "良い調子です！バランスの取れた食事を続けていきましょう。"
    }
}

// MARK: - Preview

#if DEBUG
struct AIInsightCard_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.secondarySystemBackground).ignoresSafeArea()

            AIInsightCard()
                .padding()
        }
    }
}
#endif
