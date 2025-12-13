//
//  ProgramContainerView.swift
//  FUUD
//
//  タブ切り替えの親View（TODAY / PROGRESS）
//  Phase 6-UI: TodayProgramView + ProgramProgressViewを統合
//

import SwiftUI

struct ProgramContainerView: View {
    let program: DietProgram
    var isRootView: Bool = false  // ProgramTabRootViewから来た場合はtrue

    @StateObject private var viewModel = TodayProgramViewModel()
    @StateObject private var programService = DietProgramService.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab: ProgramTab = .today
    @State private var showingCheckInSheet = false
    @State private var morningPlan: MorningPlan = MorningPlan.loadToday() ?? .empty

    private var enrollment: ProgramEnrollment? {
        programService.enrolledProgram
    }

    private var currentDay: Int {
        enrollment?.currentDay ?? 1
    }

    private var totalDays: Int {
        enrollment?.duration ?? 45
    }

    private var progressPercentage: Double {
        enrollment?.progressPercentage ?? 0
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Background
            Color(.systemBackground)

            // Content (switches based on tab)
            VStack(spacing: 0) {
                // Spacer for header
                Color.clear.frame(height: 270)

                // Tab Content
                tabContent
            }

            // Fixed Header with Tabs
            ProgramTabHeader(
                programName: program.nameJa,
                currentDay: currentDay,
                totalDays: totalDays,
                progressPercentage: progressPercentage,
                selectedTab: $selectedTab,
                showBackButton: !isRootView,
                onBack: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
        .task {
            await viewModel.loadAllData()
        }
        .sheet(isPresented: $showingCheckInSheet) {
            if #available(iOS 16.0, *) {
                MorningCheckInSheet(
                    morningPlan: $morningPlan,
                    onSave: { plan in
                        viewModel.updateMorningPlan(plan)
                    }
                )
                .presentationDetents([.large])
            } else {
                MorningCheckInSheet(
                    morningPlan: $morningPlan,
                    onSave: { plan in
                        viewModel.updateMorningPlan(plan)
                    }
                )
            }
        }
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .today:
            TodayProgramView(
                viewModel: viewModel,
                onCheckIn: {
                    showingCheckInSheet = true
                },
                onMealTap: { meal in
                    // TODO: Meal detail navigation
                    print("Meal tapped: \(meal.title)")
                },
                onWeightLog: {
                    // TODO: Weight log navigation
                    print("Weight log tapped")
                },
                onMealReview: {
                    // TODO: Meal review navigation
                    print("Meal review tapped")
                },
                onActivityLog: {
                    // TODO: Activity log navigation
                    print("Activity log tapped")
                }
            )

        case .progress:
            ProgramProgressView(
                program: program,
                onCancel: {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ProgramContainerView(
            program: DietProgramCatalog.programs.first!
        )
    }
}
