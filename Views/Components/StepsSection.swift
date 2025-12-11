//
//  StepsSection.swift
//  FUUD
//
//  HealthKit歩数セクション
//

import SwiftUI

struct StepsSection: View {
    @StateObject private var healthKit = HealthKitService.shared

    private let stepGoal: Int = 10000

    private var currentSteps: Int {
        Int(healthKit.healthData?.stepCount ?? 0)
    }

    private var burnedCalories: Int {
        Int(healthKit.healthData?.activeEnergyBurned ?? 0)
    }

    private var progress: Double {
        guard stepGoal > 0 else { return 0 }
        return min(Double(currentSteps) / Double(stepGoal), 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // Header
            HStack(spacing: VirgilSpacing.xs) {
                Image(systemName: "figure.walk")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.virgilTextSecondary)

                Text("歩数")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.virgilTextSecondary)
            }

            // Steps Display
            VStack(spacing: VirgilSpacing.sm) {
                // Main Count
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(formattedSteps(currentSteps))
                        .font(.system(size: 32, weight: .black))
                        .foregroundColor(.virgilTextPrimary)

                    Text("/ \(formattedSteps(stepGoal)) 歩")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.virgilTextSecondary)
                }

                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 12)

                        // Progress
                        RoundedRectangle(cornerRadius: 6)
                            .fill(progressColor)
                            .frame(width: geometry.size.width * progress, height: 12)
                            .animation(.easeOut(duration: 0.5), value: progress)
                    }
                }
                .frame(height: 12)

                // Burned Calories
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "FF6B6B"))

                    Text("\(burnedCalories) kcal 消費")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.virgilTextSecondary)

                    Spacer()

                    // Achievement badge when goal reached
                    if progress >= 1.0 {
                        HStack(spacing: 2) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "00C853"))

                            Text("達成!")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color(hex: "00C853"))
                        }
                    }
                }
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
        .onAppear {
            Task {
                do {
                    try await healthKit.requestAuthorization()
                    await healthKit.fetchAllHealthData()
                } catch {
                    print("❌ StepsSection HealthKit error: \(error)")
                }
            }
        }
    }

    // MARK: - Helper Methods

    private var progressColor: Color {
        if progress >= 1.0 {
            return Color(hex: "00C853")  // 緑（達成）
        } else if progress >= 0.7 {
            return Color(hex: "4ECDC4")  // ティール（もうすぐ）
        } else {
            return Color(hex: "0088CC")  // 青（進行中）
        }
    }

    private func formattedSteps(_ steps: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: steps)) ?? "\(steps)"
    }
}

// MARK: - Preview

#if DEBUG
struct StepsSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.secondarySystemBackground).ignoresSafeArea()

            StepsSection()
                .padding()
        }
    }
}
#endif
