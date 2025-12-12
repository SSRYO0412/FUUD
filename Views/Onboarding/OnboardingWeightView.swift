//
//  OnboardingWeightView.swift
//  FUUD
//
//  Lifesum風 体重入力画面
//

import SwiftUI

struct OnboardingWeightView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var weightValue: Double

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        _weightValue = State(initialValue: viewModel.userData.weightKg ?? 65)
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
            Text("現在の体重を教えてください")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 40)

            // Weight picker
            VStack(spacing: 8) {
                Text(formatWeight(weightValue))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.primary)

                Picker("", selection: $weightValue) {
                    ForEach(Array(stride(from: weightRange.lowerBound, through: weightRange.upperBound, by: 0.5)), id: \.self) { value in
                        Text(formatWeight(value)).tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .onChange(of: weightValue) { newValue in
                    viewModel.userData.weightKg = newValue
                }
            }

            Spacer()

            // Next button
            OnboardingPrimaryButton("NEXT", isEnabled: true) {
                viewModel.userData.weightKg = weightValue
                viewModel.nextStep()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear {
            if viewModel.userData.weightKg == nil {
                viewModel.userData.weightKg = weightValue
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
}

// MARK: - Preview

#if DEBUG
struct OnboardingWeightView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingWeightView(viewModel: OnboardingViewModel())
            .background(Color(hex: "F5F0E8"))
    }
}
#endif
