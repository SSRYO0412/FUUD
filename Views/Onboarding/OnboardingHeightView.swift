//
//  OnboardingHeightView.swift
//  FUUD
//
//  Lifesum風 身長入力画面
//

import SwiftUI

struct OnboardingHeightView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var heightValue: Double

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        _heightValue = State(initialValue: viewModel.userData.heightCm ?? 170)
    }

    private let heightRange: ClosedRange<Double> = 100...250

    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            HStack {
                OnboardingBackButton {
                    viewModel.previousStep()
                }
                Spacer()

                // Unit toggle
                Picker("", selection: $viewModel.userData.preferredHeightUnit) {
                    Text("cm").tag(HeightUnit.cm)
                    Text("ft/in").tag(HeightUnit.ftIn)
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
            Text("身長を教えてください")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 40)

            // Height picker
            VStack(spacing: 8) {
                Text(formatHeight(heightValue))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.primary)

                Picker("", selection: $heightValue) {
                    ForEach(Array(stride(from: heightRange.lowerBound, through: heightRange.upperBound, by: 1)), id: \.self) { value in
                        Text(formatHeight(value)).tag(value)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                .onChange(of: heightValue) { newValue in
                    viewModel.userData.heightCm = newValue
                }
            }

            Spacer()

            // Next button
            OnboardingPrimaryButton("NEXT", isEnabled: true) {
                viewModel.userData.heightCm = heightValue
                viewModel.nextStep()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear {
            if viewModel.userData.heightCm == nil {
                viewModel.userData.heightCm = heightValue
            }
        }
    }

    private func formatHeight(_ cm: Double) -> String {
        if viewModel.userData.preferredHeightUnit == .cm {
            return "\(Int(cm)) cm"
        } else {
            let totalInches = cm / 2.54
            let feet = Int(totalInches / 12)
            let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
            return "\(feet)' \(inches)\""
        }
    }
}

// MARK: - Preview

#if DEBUG
struct OnboardingHeightView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingHeightView(viewModel: OnboardingViewModel())
            .background(Color(hex: "F5F0E8"))
    }
}
#endif
