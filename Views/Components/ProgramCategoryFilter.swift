//
//  ProgramCategoryFilter.swift
//  FUUD
//
//  Category and goal filter chips for program catalog
//

import SwiftUI

struct ProgramCategoryFilter: View {
    @Binding var selectedCategory: ProgramCategory?
    @Binding var selectedGoal: GoalType?

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            // Category Filter
            categoryFilterRow

            // Goal Filter
            goalFilterRow
        }
    }

    // MARK: - Category Filter Row

    private var categoryFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: VirgilSpacing.sm) {
                // All Categories
                FilterChip(
                    title: "すべて",
                    icon: "square.grid.2x2",
                    isSelected: selectedCategory == nil,
                    color: .gray
                ) {
                    selectedCategory = nil
                }

                // Category chips
                ForEach(ProgramCategory.allCases) { category in
                    FilterChip(
                        title: category.displayNameJa,
                        icon: category.iconName,
                        isSelected: selectedCategory == category,
                        color: categoryColor(category)
                    ) {
                        if selectedCategory == category {
                            selectedCategory = nil
                        } else {
                            selectedCategory = category
                        }
                    }
                }
            }
        }
    }

    // MARK: - Goal Filter Row

    private var goalFilterRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: VirgilSpacing.sm) {
                // All Goals
                FilterChip(
                    title: "全ての目標",
                    icon: "target",
                    isSelected: selectedGoal == nil,
                    color: .gray
                ) {
                    selectedGoal = nil
                }

                // Goal chips
                ForEach(GoalType.allCases, id: \.rawValue) { goal in
                    FilterChip(
                        title: goal.displayNameJa,
                        icon: goalIcon(goal),
                        isSelected: selectedGoal == goal,
                        color: goalColor(goal)
                    ) {
                        if selectedGoal == goal {
                            selectedGoal = nil
                        } else {
                            selectedGoal = goal
                        }
                    }
                }
            }
        }
    }

    // MARK: - Helper Functions

    private func categoryColor(_ category: ProgramCategory) -> Color {
        switch category {
        case .biohacking: return .purple
        case .balanced: return .green
        case .fasting: return .orange
        case .highProtein: return .blue
        case .lowCarb: return .teal
        }
    }

    private func goalIcon(_ goal: GoalType) -> String {
        switch goal {
        case .lose: return "arrow.down.circle"
        case .maintain: return "equal.circle"
        case .gain: return "arrow.up.circle"
        }
    }

    private func goalColor(_ goal: GoalType) -> Color {
        switch goal {
        case .lose: return .blue
        case .maintain: return .green
        case .gain: return .orange
        }
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: VirgilSpacing.xs) {
                Image(systemName: icon)
                    .font(.caption)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, VirgilSpacing.sm)
            .padding(.vertical, VirgilSpacing.xs + 2)
            .foregroundColor(isSelected ? .white : color)
            .background(
                Capsule()
                    .fill(isSelected ? color : color.opacity(0.1))
            )
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.3), lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Standalone Category Badge

struct CategoryBadge: View {
    let category: ProgramCategory

    var body: some View {
        HStack(spacing: VirgilSpacing.xs) {
            Image(systemName: category.iconName)
                .font(.caption2)

            Text(category.displayNameJa)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(.white)
        .padding(.horizontal, VirgilSpacing.sm)
        .padding(.vertical, VirgilSpacing.xs)
        .background(categoryColor)
        .cornerRadius(VirgilSpacing.radiusSmall)
    }

    private var categoryColor: Color {
        switch category {
        case .biohacking: return .purple
        case .balanced: return .green
        case .fasting: return .orange
        case .highProtein: return .blue
        case .lowCarb: return .teal
        }
    }
}

// MARK: - Difficulty Badge

struct DifficultyBadge: View {
    let difficulty: ProgramDifficulty

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(index < difficultyLevel ? difficultyColor : Color.gray.opacity(0.3))
                    .frame(width: 6, height: 6)
            }

            Text(difficulty.displayNameJa)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    private var difficultyLevel: Int {
        switch difficulty {
        case .beginner: return 1
        case .intermediate: return 2
        case .advanced: return 3
        }
    }

    private var difficultyColor: Color {
        switch difficulty {
        case .beginner: return .green
        case .intermediate: return .yellow
        case .advanced: return .red
        }
    }
}

// MARK: - Goal Badge

struct GoalBadge: View {
    let goal: GoalType

    var body: some View {
        HStack(spacing: VirgilSpacing.xs) {
            Image(systemName: iconName)
                .font(.caption2)

            Text(goal.displayNameJa)
                .font(.caption2)
                .fontWeight(.medium)
        }
        .foregroundColor(goalColor)
        .padding(.horizontal, VirgilSpacing.sm)
        .padding(.vertical, VirgilSpacing.xs)
        .background(goalColor.opacity(0.1))
        .cornerRadius(VirgilSpacing.radiusSmall)
    }

    private var iconName: String {
        switch goal {
        case .lose: return "arrow.down.circle.fill"
        case .maintain: return "equal.circle.fill"
        case .gain: return "arrow.up.circle.fill"
        }
    }

    private var goalColor: Color {
        switch goal {
        case .lose: return .blue
        case .maintain: return .green
        case .gain: return .orange
        }
    }
}

// MARK: - Preview

#Preview("Category Filter") {
    struct PreviewWrapper: View {
        @State var category: ProgramCategory?
        @State var goal: GoalType?

        var body: some View {
            VStack(spacing: VirgilSpacing.lg) {
                ProgramCategoryFilter(
                    selectedCategory: $category,
                    selectedGoal: $goal
                )

                Divider()

                Text("Selected: \(category?.displayNameJa ?? "All")")
                Text("Goal: \(goal?.displayNameJa ?? "All")")
            }
            .padding()
        }
    }

    return PreviewWrapper()
}

#Preview("Badges") {
    VStack(spacing: VirgilSpacing.md) {
        HStack(spacing: VirgilSpacing.sm) {
            CategoryBadge(category: .biohacking)
            CategoryBadge(category: .fasting)
            CategoryBadge(category: .lowCarb)
        }

        HStack(spacing: VirgilSpacing.sm) {
            DifficultyBadge(difficulty: .beginner)
            DifficultyBadge(difficulty: .intermediate)
            DifficultyBadge(difficulty: .advanced)
        }

        HStack(spacing: VirgilSpacing.sm) {
            GoalBadge(goal: .lose)
            GoalBadge(goal: .maintain)
            GoalBadge(goal: .gain)
        }
    }
    .padding()
}
