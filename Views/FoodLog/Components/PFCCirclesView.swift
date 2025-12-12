//
//  PFCCirclesView.swift
//  FUUD
//
//  Lifesum風PFCサークル表示
//

import SwiftUI

struct PFCCirclesView: View {
    let carbsPercentage: Double
    let proteinPercentage: Double
    let fatPercentage: Double
    let carbsGrams: Double
    let proteinGrams: Double
    let fatGrams: Double

    private let carbsColor = Color(hex: "FFCB05")    // 黄色
    private let proteinColor = Color(hex: "9C27B0")  // 紫
    private let fatColor = Color(hex: "FF6B6B")      // ピンク/赤

    var body: some View {
        HStack(spacing: 0) {
            Spacer()

            // Carbs
            PFCCircle(
                percentage: carbsPercentage,
                grams: carbsGrams,
                label: "糖質",
                color: carbsColor
            )

            Spacer()

            // Protein
            PFCCircle(
                percentage: proteinPercentage,
                grams: proteinGrams,
                label: "タンパク質",
                color: proteinColor
            )

            Spacer()

            // Fat
            PFCCircle(
                percentage: fatPercentage,
                grams: fatGrams,
                label: "脂質",
                color: fatColor
            )

            Spacer()
        }
        .padding(.vertical, VirgilSpacing.md)
        .background(Color(.systemBackground).opacity(0.8))
        .cornerRadius(16)
    }
}

// MARK: - PFC Circle

struct PFCCircle: View {
    let percentage: Double
    let grams: Double
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            // Circle with percentage
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                    .frame(width: 60, height: 60)

                // Progress circle
                Circle()
                    .trim(from: 0, to: min(percentage / 100, 1.0))
                    .stroke(color, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))

                // Percentage text
                Text("\(Int(percentage))%")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
            }

            // Label
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)

            // Grams
            Text(String(format: "%.1fg", grams))
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Compact Version for List Items

struct PFCDotsView: View {
    let carbs: Double
    let protein: Double
    let fat: Double
    let fiber: Double

    private let carbsColor = Color(hex: "FFCB05")
    private let proteinColor = Color(hex: "9C27B0")
    private let fatColor = Color(hex: "FF6B6B")
    private let fiberColor = Color(hex: "8BC34A")

    var body: some View {
        HStack(spacing: 6) {
            dotWithValue(color: carbsColor, value: carbs)
            dotWithValue(color: proteinColor, value: protein)
            dotWithValue(color: fatColor, value: fat)
            dotWithValue(color: fiberColor, value: fiber)
        }
    }

    private func dotWithValue(color: Color, value: Double) -> some View {
        HStack(spacing: 2) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text("\(Int(value))g")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct PFCCirclesView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            PFCCirclesView(
                carbsPercentage: 22,
                proteinPercentage: 27,
                fatPercentage: 51,
                carbsGrams: 31.1,
                proteinGrams: 39.4,
                fatGrams: 32.7
            )
            .padding()

            PFCDotsView(carbs: 5, protein: 10, fat: 3, fiber: 2)
        }
        .background(Color(.secondarySystemBackground))
    }
}
#endif
