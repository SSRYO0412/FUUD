//
//  FoodLogViewModel.swift
//  FUUD
//
//  AI食品登録ViewModel（モックデータ含む）
//

import Foundation
import SwiftUI

enum FoodLogState {
    case idle
    case userInput
    case analyzing
    case completed
    case tracked
}

@MainActor
class FoodLogViewModel: ObservableObject {
    @Published var state: FoodLogState = .idle
    @Published var messages: [FoodLogChatMessage] = []
    @Published var currentInput: String = ""
    @Published var selectedMealType: MealType = .dinner
    @Published var parsedMeal: ParsedMeal?

    // Suggestions
    let mealSuggestions: [String] = [
        "麻婆豆腐",
        "ラーメン",
        "カレーライス",
        "親子丼",
        "焼き魚定食",
        "サラダチキン"
    ]

    init() {
        // 初期メッセージ
        messages.append(FoodLogChatMessage(
            content: "何を食べましたか？",
            isUser: false
        ))
    }

    // MARK: - Actions

    func sendMessage() {
        guard !currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userMessage = currentInput
        currentInput = ""

        // Add user message
        messages.append(FoodLogChatMessage(
            content: userMessage,
            isUser: true
        ))

        state = .analyzing

        // Add loading message
        messages.append(FoodLogChatMessage(
            content: "解析中...",
            isUser: false,
            isLoading: true
        ))

        // Simulate AI analysis delay
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds

            // Remove loading message
            messages.removeLast()

            // Generate mock parsed meal
            let meal = generateMockMeal(from: userMessage)
            parsedMeal = meal

            // Add AI response with meal card
            messages.append(FoodLogChatMessage(
                content: "和食の\(selectedMealType.displayName)セットを解析しました。食材と分量を推定しました。",
                isUser: false,
                parsedMeal: meal
            ))

            state = .completed
        }
    }

    func selectSuggestion(_ suggestion: String) {
        currentInput = suggestion
        sendMessage()
    }

    func trackMeal() {
        state = .tracked

        messages.append(FoodLogChatMessage(
            content: "食事を記録しました！",
            isUser: false
        ))
    }

    func reset() {
        state = .idle
        messages = [FoodLogChatMessage(
            content: "何を食べましたか？",
            isUser: false
        )]
        currentInput = ""
        parsedMeal = nil
    }

    // MARK: - Mock Data Generation

    private func generateMockMeal(from input: String) -> ParsedMeal {
        // モックデータ：入力に基づいて和定食セットを返す
        let items: [FoodItem] = [
            FoodItem(
                name: "牛肉（スライス、炒め）",
                amount: 120,
                unit: "g",
                calories: 300,
                carbs: 0,
                protein: 31.2,
                fat: 20.4,
                fiber: 0,
                sugar: 0,
                sodium: 65,
                isProcessed: false
            ),
            FoodItem(
                name: "わかめスープ",
                amount: 1,
                unit: "杯",
                calories: 30,
                carbs: 3,
                protein: 2,
                fat: 1,
                fiber: 1,
                sugar: 0,
                sodium: 450,
                isProcessed: false
            ),
            FoodItem(
                name: "冷奴",
                amount: 150,
                unit: "g",
                calories: 84,
                carbs: 2.3,
                protein: 7.8,
                fat: 4.9,
                fiber: 0.9,
                sugar: 0.5,
                sodium: 7,
                isProcessed: false
            ),
            FoodItem(
                name: "冷奴用醤油",
                amount: 5,
                unit: "g",
                calories: 3,
                carbs: 0.5,
                protein: 0.3,
                fat: 0,
                fiber: 0,
                sugar: 0.2,
                sodium: 290,
                isProcessed: true
            ),
            FoodItem(
                name: "きゅうり（生）",
                amount: 40,
                unit: "g",
                calories: 6,
                carbs: 1.2,
                protein: 0.4,
                fat: 0,
                fiber: 0.4,
                sugar: 0.7,
                sodium: 1,
                isProcessed: false
            ),
            FoodItem(
                name: "アボカド",
                amount: 50,
                unit: "g",
                calories: 94,
                carbs: 3.5,
                protein: 1,
                fat: 9.3,
                fiber: 2.6,
                sugar: 0.3,
                sodium: 4,
                isProcessed: false
            ),
            FoodItem(
                name: "サラダドレッシング（ごま油風味）",
                amount: 10,
                unit: "g",
                calories: 18,
                carbs: 1,
                protein: 0.2,
                fat: 1.5,
                fiber: 0,
                sugar: 0.5,
                sodium: 180,
                isProcessed: true
            ),
            FoodItem(
                name: "青ネギ（生）",
                amount: 5,
                unit: "g",
                calories: 2,
                carbs: 0.4,
                protein: 0.1,
                fat: 0,
                fiber: 0.1,
                sugar: 0.2,
                sodium: 0,
                isProcessed: false
            ),
            FoodItem(
                name: "炒め調味料（醤油・みりん・砂糖・油）",
                amount: 20,
                unit: "g",
                calories: 24,
                carbs: 5,
                protein: 1,
                fat: 0.5,
                fiber: 0,
                sugar: 3,
                sodium: 520,
                isProcessed: true
            )
        ]

        return ParsedMeal(
            name: "和定食セット",
            description: input,
            mealType: selectedMealType,
            servings: 1,
            date: Date(),
            items: items
        )
    }
}

// MARK: - Singleton for sharing

extension FoodLogViewModel {
    static let shared = FoodLogViewModel()
}
