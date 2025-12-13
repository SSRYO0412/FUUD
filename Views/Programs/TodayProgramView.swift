//
//  TodayProgramView.swift
//  FUUD
//
//  TODAYタブのコンテンツ
//  Phase 6-UI: 今日のプログラム画面
//

import SwiftUI

struct TodayProgramView: View {
    @ObservedObject var viewModel: TodayProgramViewModel

    var onCheckIn: () -> Void = {}
    var onMealTap: ((MealRecommendation) -> Void)?
    var onWeightLog: () -> Void = {}
    var onMealReview: () -> Void = {}
    var onActivityLog: () -> Void = {}

    var body: some View {
        ScrollView {
            VStack(spacing: VirgilSpacing.xl) {
                // Morning Check-In Section
                MorningCheckInSection(
                    morningPlan: viewModel.morningPlan,
                    onCheckIn: onCheckIn
                )

                // Today's Goals Section
                TodayGoalsSection(
                    targetCalories: viewModel.targetCalories,
                    proteinGrams: viewModel.proteinGrams,
                    fatGrams: viewModel.fatGrams,
                    carbsGrams: viewModel.carbsGrams,
                    pfc: viewModel.currentPFC
                )

                // Meal Recommendations Section
                MealRecommendSection(
                    mealPlan: viewModel.mealPlan,
                    onMealTap: onMealTap
                )

                // Today's Focus Section (if applicable)
                if viewModel.currentPhase != nil {
                    TodayFocusSection(
                        phase: viewModel.currentPhase,
                        program: viewModel.program
                    )
                }

                // Checklist Section
                TodayChecklistSection(
                    items: Binding(
                        get: { viewModel.checklist },
                        set: { viewModel.checklist = $0 }
                    ),
                    onToggle: { item in
                        viewModel.toggleChecklistItem(item)
                    }
                )

                // Daily Log Section
                DailyLogSection(
                    onWeightLog: onWeightLog,
                    onMealReview: onMealReview,
                    onActivityLog: onActivityLog
                )

                // 他のプログラムに変更ボタン
                NavigationLink(destination: ProgramCatalogView()) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                        Text("他のプログラムに変更")
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.lifesumDarkGreen)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.lifesumDarkGreen.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal, VirgilSpacing.md)
            }
            .padding(.top, VirgilSpacing.lg)
            .padding(.bottom, VirgilSpacing.xl4)
        }
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @StateObject private var viewModel = TodayProgramViewModel()

        var body: some View {
            TodayProgramView(viewModel: viewModel)
                .onAppear {
                    viewModel.setupDemoData()
                }
        }
    }

    return PreviewWrapper()
        .background(Color(.systemBackground))
}
