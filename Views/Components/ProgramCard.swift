//
//  ProgramCard.swift
//  FUUD
//
//  Program card component for catalog list view
//

import SwiftUI

struct ProgramCard: View {
    let program: DietProgram
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: VirgilSpacing.md) {
                // Left: Icon & Category
                categoryIcon

                // Center: Program Info
                VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
                    // Title
                    Text(program.nameJa)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    // English Name
                    Text(program.nameEn)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)

                    // Description
                    Text(program.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    // Meta Info
                    HStack(spacing: VirgilSpacing.md) {
                        // Difficulty
                        HStack(spacing: VirgilSpacing.xs) {
                            difficultyIcon
                            Text(program.difficulty.displayNameJa)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }

                        // Goal
                        HStack(spacing: VirgilSpacing.xs) {
                            goalIcon
                            Text(program.targetGoal.displayNameJa)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Spacer()

                // Right: Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(VirgilSpacing.md)
            .liquidGlassCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Category Icon

    private var categoryIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: VirgilSpacing.radiusMedium)
                .fill(categoryColor.opacity(0.15))
                .frame(width: 56, height: 56)

            Image(systemName: program.category.iconName)
                .font(.system(size: 24))
                .foregroundColor(categoryColor)
        }
    }

    private var categoryColor: Color {
        switch program.category {
        case .biohacking: return .purple
        case .balanced: return .green
        case .fasting: return .orange
        case .highProtein: return .blue
        case .lowCarb: return .teal
        }
    }

    // MARK: - Difficulty Icon

    private var difficultyIcon: some View {
        HStack(spacing: 2) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(index < difficultyLevel ? difficultyColor : Color.gray.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
    }

    private var difficultyLevel: Int {
        switch program.difficulty {
        case .beginner: return 1
        case .intermediate: return 2
        case .advanced: return 3
        }
    }

    private var difficultyColor: Color {
        switch program.difficulty {
        case .beginner: return .green
        case .intermediate: return .yellow
        case .advanced: return .red
        }
    }

    // MARK: - Goal Icon

    private var goalIcon: some View {
        Image(systemName: goalIconName)
            .font(.caption2)
            .foregroundColor(goalColor)
    }

    private var goalIconName: String {
        switch program.targetGoal {
        case .lose: return "arrow.down.circle.fill"
        case .maintain: return "equal.circle.fill"
        case .gain: return "arrow.up.circle.fill"
        }
    }

    private var goalColor: Color {
        switch program.targetGoal {
        case .lose: return .blue
        case .maintain: return .green
        case .gain: return .orange
        }
    }
}

// MARK: - Compact Program Card (for Home View sections)

struct CompactProgramCard: View {
    let program: DietProgram
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: VirgilSpacing.sm) {
                // Icon
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: program.category.iconName)
                        .font(.system(size: 16))
                        .foregroundColor(categoryColor)
                }

                // Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(program.nameJa)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Text(program.category.displayNameJa)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(VirgilSpacing.sm)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(VirgilSpacing.radiusMedium)
        }
        .buttonStyle(.plain)
    }

    private var categoryColor: Color {
        switch program.category {
        case .biohacking: return .purple
        case .balanced: return .green
        case .fasting: return .orange
        case .highProtein: return .blue
        case .lowCarb: return .teal
        }
    }
}

// MARK: - Preview

#Preview("Program Card") {
    VStack(spacing: VirgilSpacing.md) {
        ProgramCard(
            program: DietProgramCatalog.programs[0],
            onTap: {}
        )

        ProgramCard(
            program: DietProgramCatalog.programs[1],
            onTap: {}
        )
    }
    .padding()
}

#Preview("Compact Card") {
    VStack(spacing: VirgilSpacing.sm) {
        CompactProgramCard(
            program: DietProgramCatalog.programs[0],
            onTap: {}
        )

        CompactProgramCard(
            program: DietProgramCatalog.programs[1],
            onTap: {}
        )
    }
    .padding()
}
