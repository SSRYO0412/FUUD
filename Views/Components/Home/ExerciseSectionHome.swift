//
//  ExerciseSectionHome.swift
//  FUUD
//
//  Lifesum風の運動セクション
//

import SwiftUI

struct ExerciseSectionHome: View {
    @StateObject private var healthKit = HealthKitService.shared

    private var burnedCalories: Int {
        Int(healthKit.healthData?.activeEnergyBurned ?? 0)
    }

    private var exerciseMinutes: Int {
        Int(healthKit.healthData?.exerciseTime ?? 0)
    }

    private var stepCount: Int {
        Int(healthKit.healthData?.stepCount ?? 0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            // Header row
            HStack {
                // Exercise icon and title
                HStack(spacing: VirgilSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "E8F5E9"))
                            .frame(width: 40, height: 40)

                        Image(systemName: "figure.walk")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "66BB6A"))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Exercise")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.virgilTextPrimary)

                        Text("Walking, Active Energy")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(.virgilTextSecondary)
                    }
                }

                Spacer()

                // Add button
                Button(action: {
                    // Future: Add exercise manually
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)
                        .frame(width: 28, height: 28)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }

            // Stats row
            HStack(spacing: VirgilSpacing.lg) {
                // Burned calories
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "FF6B6B"))

                    Text("-\(burnedCalories) kcal")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.virgilTextSecondary)
                }

                // Exercise time
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 11))
                        .foregroundColor(.virgilTextSecondary)

                    Text("\(exerciseMinutes)min")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.virgilTextSecondary)
                }

                // Steps
                HStack(spacing: 4) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 11))
                        .foregroundColor(.virgilTextSecondary)

                    Text(formattedSteps)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.virgilTextSecondary)
                }
            }
            .padding(.leading, 52)  // Align with text after icon
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    private var formattedSteps: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return "\(formatter.string(from: NSNumber(value: stepCount)) ?? "\(stepCount)") steps"
    }
}

// MARK: - Preview

#if DEBUG
struct ExerciseSectionHome_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.secondarySystemBackground).ignoresSafeArea()

            ExerciseSectionHome()
                .padding()
        }
    }
}
#endif
