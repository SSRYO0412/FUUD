//
//  OnboardingTargetWeightView.swift
//  FUUD
//
//  Lifesum風 目標体重入力画面
//

import SwiftUI

struct OnboardingTargetWeightView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var targetWeightValue: Double

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        // 現在の体重から目標に応じてデフォルト値を設定
        let currentWeight = viewModel.userData.weightKg ?? 65
        let defaultTarget: Double
        if let goal = viewModel.userData.goal {
            switch goal {
            case .loseWeight:
                defaultTarget = max(40, currentWeight - 5)
            case .gainWeight:
                defaultTarget = min(150, currentWeight + 5)
            case .maintainWeight:
                defaultTarget = currentWeight
            }
        } else {
            defaultTarget = currentWeight
        }
        _targetWeightValue = State(initialValue: viewModel.userData.targetWeightKg ?? defaultTarget)
    }

    private let weightRange: ClosedRange<Double> = 30...200

    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            HStack {
                OnboardingBackButton {
                    viewModel.previousStep()
                }
                Spacer()

                // Unit toggle
                Picker("", selection: $viewModel.userData.preferredWeightUnit) {
                    Text("kg").tag(WeightUnit.kg)
                    Text("lbs").tag(WeightUnit.lbs)
                }
                .pickerStyle(.segmented)
                .frame(width: 100)
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)

            Spacer().frame(height: 40)

            // Encouragement message
            if !viewModel.currentStep.encouragementMessage.isEmpty {
                Text(viewModel.currentStep.encouragementMessage)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "6B7280"))
                    .padding(.bottom, 8)
            }

            // Title
            Text("目標体重を教えてください")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            // Current vs target info
            if let currentWeight = viewModel.userData.weightKg {
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("現在")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "6B7280"))
                        Text(formatWeight(currentWeight))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                    }

                    Image(systemName: "arrow.right")
                        .foregroundColor(Color(hex: "4CD964"))

                    VStack(spacing: 4) {
                        Text("目標")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "6B7280"))
                        Text(formatWeight(targetWeightValue))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "4CD964"))
                    }
                }
                .padding(.top, 16)
            }

            Spacer().frame(height: 40)

            // Weight picker
            VStack(spacing: 8) {
                Text(formatWeight(targetWeightValue))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(Color(hex: "4CD964"))

                Picker("", selection: $targetWeightValue) {
                    ForEach(Array(stride(from: weightRange.lowerBound, through: weightRange.upperBound, by: 0.5)), id: \.self) { value in
                        Text(formatWeight(value)).tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .onChange(of: targetWeightValue) { newValue in
                    viewModel.userData.targetWeightKg = newValue
                }

                // Weight difference
                if let currentWeight = viewModel.userData.weightKg {
                    let diff = targetWeightValue - currentWeight
                    let sign = diff >= 0 ? "+" : ""
                    Text("\(sign)\(formatWeightDiff(diff))")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "6B7280"))
                }
            }

            Spacer()

            // Next button
            OnboardingPrimaryButton("NEXT", isEnabled: true) {
                viewModel.userData.targetWeightKg = targetWeightValue
                viewModel.nextStep()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear {
            if viewModel.userData.targetWeightKg == nil {
                viewModel.userData.targetWeightKg = targetWeightValue
            }
        }
    }

    private func formatWeight(_ kg: Double) -> String {
        if viewModel.userData.preferredWeightUnit == .kg {
            return String(format: "%.1f kg", kg)
        } else {
            let lbs = kg * 2.20462
            return String(format: "%.1f lbs", lbs)
        }
    }

    private func formatWeightDiff(_ kg: Double) -> String {
        if viewModel.userData.preferredWeightUnit == .kg {
            return String(format: "%.1f kg", kg)
        } else {
            let lbs = kg * 2.20462
            return String(format: "%.1f lbs", lbs)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct OnboardingTargetWeightView_Previews: PreviewProvider {
    static var previews: some View {
        let vm = OnboardingViewModel()
        vm.userData.goal = .loseWeight
        vm.userData.weightKg = 70
        return OnboardingTargetWeightView(viewModel: vm)
            .background(Color(hex: "F5F0E8"))
    }
}
#endif
