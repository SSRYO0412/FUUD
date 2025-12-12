//
//  OnboardingBirthdateView.swift
//  FUUD
//
//  Lifesum風 生年月日選択画面
//

import SwiftUI

struct OnboardingBirthdateView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var selectedDate: Date

    init(viewModel: OnboardingViewModel) {
        self.viewModel = viewModel
        // デフォルト: 25歳
        let defaultDate = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
        _selectedDate = State(initialValue: viewModel.userData.birthdate ?? defaultDate)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with back button
            HStack {
                OnboardingBackButton {
                    viewModel.previousStep()
                }
                Spacer()
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
            Text("生年月日を教えてください")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)

            Spacer().frame(height: 40)

            // Date picker
            DatePicker(
                "",
                selection: $selectedDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .onChange(of: selectedDate) { newValue in
                viewModel.userData.birthdate = newValue
            }

            Spacer()

            // Next button
            OnboardingPrimaryButton("NEXT", isEnabled: true) {
                viewModel.userData.birthdate = selectedDate
                viewModel.nextStep()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .onAppear {
            if viewModel.userData.birthdate == nil {
                viewModel.userData.birthdate = selectedDate
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct OnboardingBirthdateView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingBirthdateView(viewModel: OnboardingViewModel())
            .background(Color(hex: "F5F0E8"))
    }
}
#endif
