//
//  FoodLogViewModel.swift
//  FUUD
//
//  AI食品登録ViewModel
//  food-parse API を使用して自然文を栄養データに変換する
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

        Task {
            do {
                // API呼び出し
                let parseResult = try await FoodParseService.shared.parseFood(
                    text: userMessage,
                    mealType: selectedMealType.rawValue
                )

                // Remove loading message
                messages.removeLast()

                // Convert to FoodItem array
                let items = parseResult.items.map { FoodItem(from: $0) }

                // Create ParsedMeal
                let meal = ParsedMeal(
                    name: parseResult.originalText,
                    description: userMessage,
                    mealType: selectedMealType,
                    servings: 1,
                    date: Date(),
                    items: items
                )

                parsedMeal = meal

                // AI response message with source info
                let sourceInfo = parseResult.source != "estimated"
                    ? "（栄養データ: \(parseResult.source)）"
                    : "（栄養データ: 推定値）"

                messages.append(FoodLogChatMessage(
                    content: "\(items.count)品目を解析しました。\(sourceInfo)",
                    isUser: false,
                    parsedMeal: meal
                ))

                state = .completed

            } catch {
                // Remove loading message
                messages.removeLast()

                // Error message
                messages.append(FoodLogChatMessage(
                    content: "解析に失敗しました: \(error.localizedDescription)",
                    isUser: false
                ))

                state = .idle
                print("❌ FoodLogViewModel: Parse error - \(error)")
            }
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
}

// MARK: - Singleton for sharing

extension FoodLogViewModel {
    static let shared = FoodLogViewModel()
}
