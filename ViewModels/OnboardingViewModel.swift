//
//  OnboardingViewModel.swift
//  FUUD
//
//  Lifesum風オンボーディング ViewModel
//

import Foundation
import SwiftUI
import Combine

@MainActor
class OnboardingViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var currentStep: OnboardingStep = .welcome
    @Published var userData = OnboardingUserData()
    @Published var nutritionPlan: NutritionPlan?

    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false

    // Auth state (Cognitoと連携)
    @Published var isAuthenticated = false

    // Completion callback
    var onComplete: (() -> Void)?

    // MARK: - Private Properties

    private let userDefaultsKey = "onboardingUserData"

    // MARK: - Computed Properties

    var progressPercentage: Double {
        guard let index = currentStep.progressIndex else { return 0 }
        return Double(index + 1) / Double(OnboardingStep.progressStepCount)
    }

    var showProgressBar: Bool {
        return currentStep.progressIndex != nil
    }

    var canProceed: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .goal:
            return userData.goal != nil
        case .gender:
            return userData.gender != nil
        case .birthdate:
            return userData.birthdate != nil
        case .height:
            return userData.heightCm != nil
        case .weight:
            return userData.weightKg != nil
        case .targetWeight:
            return userData.targetWeightKg != nil || !userData.isTargetWeightRequired
        case .auth:
            return isAuthenticated
        default:
            return true
        }
    }

    // MARK: - Initialization

    init() {
        loadSavedData()
    }

    // MARK: - Navigation

    func nextStep() {
        guard canProceed else { return }

        switch currentStep {
        case .welcome:
            currentStep = .goal
        case .goal:
            currentStep = .gender
        case .gender:
            currentStep = .birthdate
        case .birthdate:
            currentStep = .height
        case .height:
            currentStep = .weight
        case .weight:
            if userData.isTargetWeightRequired {
                currentStep = .targetWeight
            } else {
                currentStep = .auth
            }
        case .targetWeight:
            currentStep = .auth
        case .auth:
            currentStep = .loading
            startPlanGeneration()
        case .loading:
            currentStep = .planReady
        case .planReady:
            // サブスクをスキップして完了へ（将来的にはpremiumへ）
            currentStep = .complete
        case .premium:
            currentStep = .complete
        case .complete:
            currentStep = .notification
        case .notification:
            completeOnboarding()
        }

        saveData()
    }

    func previousStep() {
        switch currentStep {
        case .goal:
            currentStep = .welcome
        case .gender:
            currentStep = .goal
        case .birthdate:
            currentStep = .gender
        case .height:
            currentStep = .birthdate
        case .weight:
            currentStep = .height
        case .targetWeight:
            currentStep = .weight
        case .auth:
            if userData.isTargetWeightRequired {
                currentStep = .targetWeight
            } else {
                currentStep = .weight
            }
        default:
            break
        }
    }

    func goToLogin() {
        // ログイン画面へ（既存のAuthenticationViewを使用）
        // この場合、オンボーディングをスキップ
    }

    // MARK: - Plan Generation

    private func startPlanGeneration() {
        Task {
            // ローディングアニメーション用に2秒待機
            try? await Task.sleep(nanoseconds: 2_000_000_000)

            // 栄養プランを計算
            nutritionPlan = NutritionPlan.calculate(for: userData)

            // プロファイルをサーバーに保存
            await saveProfileToServer()

            // 次のステップへ
            currentStep = .planReady
        }
    }

    private func saveProfileToServer() async {
        do {
            let sections = convertToHealthProfileSections()
            let consent = HealthProfile.ConsentInfo(dataUsage: true, marketing: false)
            try await HealthProfileService.shared.createProfile(sections: sections, consent: consent)
            print("✅ Profile saved to server")
        } catch {
            print("⚠️ Failed to save profile: \(error)")
            // エラーでも続行（後で再送可能）
        }
    }

    private func convertToHealthProfileSections() -> HealthProfileSections {
        var sections = HealthProfileSections()

        // Physical
        var physical = PhysicalSection()
        physical.height = userData.heightCm
        physical.weight = userData.weightKg
        physical.bmi = userData.bmi
        sections.physical = physical

        // Goals
        var primaryGoal: String = "maintenance"
        switch userData.goal {
        case .loseWeight:
            primaryGoal = "weightLoss"
        case .maintainWeight:
            primaryGoal = "maintenance"
        case .gainWeight:
            primaryGoal = "muscleGain"
        case .none:
            primaryGoal = "maintenance"
        }
        var goals = GoalsSection(primary: primaryGoal)
        goals.targetWeight = userData.targetWeightKg
        sections.goals = goals

        return sections
    }

    // MARK: - Completion

    func skipPremium() {
        currentStep = .complete
    }

    func completeOnboarding() {
        // オンボーディング完了フラグを保存
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        // 完了コールバック
        onComplete?()
    }

    // MARK: - Auth Integration

    func handleAuthSuccess() {
        isAuthenticated = true
        nextStep()
    }

    // MARK: - Notification Permission

    func requestNotificationPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            return granted
        } catch {
            print("⚠️ Notification permission error: \(error)")
            return false
        }
    }

    // MARK: - Persistence

    private func saveData() {
        if let encoded = try? JSONEncoder().encode(userData) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadSavedData() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(OnboardingUserData.self, from: data) {
            userData = decoded
        }
    }

    func clearData() {
        userData = OnboardingUserData()
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}

// MARK: - Input Helpers

extension OnboardingViewModel {
    // Height in current unit
    var displayHeight: Double {
        guard let cm = userData.heightCm else { return 170 }
        if userData.preferredHeightUnit == .cm {
            return cm
        } else {
            // Convert to feet (whole number)
            return cm / 30.48
        }
    }

    func setHeight(_ value: Double) {
        if userData.preferredHeightUnit == .cm {
            userData.heightCm = value
        } else {
            // value is in feet, convert to cm
            userData.heightCm = value * 30.48
        }
    }

    // Weight in current unit
    var displayWeight: Double {
        guard let kg = userData.weightKg else { return 65 }
        return userData.preferredWeightUnit.convert(kg, to: userData.preferredWeightUnit) == kg
            ? kg
            : kg * 2.20462
    }

    func setWeight(_ value: Double) {
        if userData.preferredWeightUnit == .kg {
            userData.weightKg = value
        } else {
            userData.weightKg = value / 2.20462
        }
    }

    // Target weight in current unit
    var displayTargetWeight: Double {
        guard let kg = userData.targetWeightKg else {
            // デフォルト値（現在の体重から目標に応じて調整）
            let currentKg = userData.weightKg ?? 65
            switch userData.goal {
            case .loseWeight:
                return userData.preferredWeightUnit == .kg ? currentKg - 5 : (currentKg - 5) * 2.20462
            case .gainWeight:
                return userData.preferredWeightUnit == .kg ? currentKg + 5 : (currentKg + 5) * 2.20462
            default:
                return userData.preferredWeightUnit == .kg ? currentKg : currentKg * 2.20462
            }
        }
        return userData.preferredWeightUnit == .kg ? kg : kg * 2.20462
    }

    func setTargetWeight(_ value: Double) {
        if userData.preferredWeightUnit == .kg {
            userData.targetWeightKg = value
        } else {
            userData.targetWeightKg = value / 2.20462
        }
    }
}
