//
//  ChatMessageBubble.swift
//  FUUD
//
//  Lifesum風チャットバブルUI
//

import SwiftUI

// MARK: - Food Log Chat Message Model

struct FoodLogChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    var parsedMeal: ParsedMeal?
    var isLoading: Bool

    init(content: String, isUser: Bool, timestamp: Date = Date(), parsedMeal: ParsedMeal? = nil, isLoading: Bool = false) {
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.parsedMeal = parsedMeal
        self.isLoading = isLoading
    }
}

// MARK: - Chat Message Bubble View

struct ChatMessageBubble: View {
    let message: FoodLogChatMessage
    var onMealTap: ((ParsedMeal) -> Void)?

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if !message.isUser {
                // AI icon
                Image(systemName: "sparkles")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(width: 24, height: 24)
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 8) {
                if message.isLoading {
                    // Loading state
                    HStack(spacing: 4) {
                        LoadingDots()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                } else {
                    // Message content
                    Text(message.content)
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(message.isUser ? .primary : .secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            message.isUser
                                ? Color(.systemGray6)
                                : Color.clear
                        )
                        .cornerRadius(16)
                }

                // Parsed meal card
                if let meal = message.parsedMeal {
                    MealCardView(meal: meal)
                        .onTapGesture {
                            onMealTap?(meal)
                        }
                }
            }

            if message.isUser {
                Spacer(minLength: 40)
            }
        }
        .frame(maxWidth: .infinity, alignment: message.isUser ? .trailing : .leading)
    }
}

// MARK: - Loading Dots Animation

struct LoadingDots: View {
    @State private var animationOffset: CGFloat = 0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.secondary)
                    .frame(width: 8, height: 8)
                    .offset(y: animationOffset(for: index))
            }
        }
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 0.5)
                    .repeatForever(autoreverses: true)
            ) {
                animationOffset = -5
            }
        }
    }

    private func animationOffset(for index: Int) -> CGFloat {
        let delay = Double(index) * 0.15
        return animationOffset * cos(delay * .pi)
    }
}

// MARK: - User Input Bubble

struct UserInputBubble: View {
    let text: String

    var body: some View {
        HStack {
            Spacer(minLength: 60)

            Text(text)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(16)
        }
    }
}

// MARK: - Preview

#if DEBUG
struct ChatMessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            ChatMessageBubble(
                message: FoodLogChatMessage(
                    content: "何を食べましたか？",
                    isUser: false
                )
            )

            ChatMessageBubble(
                message: FoodLogChatMessage(
                    content: "牛肉の炒め物、わかめスープ、冷奴、アボカドときゅうりのサラダ",
                    isUser: true
                )
            )

            ChatMessageBubble(
                message: FoodLogChatMessage(
                    content: "",
                    isUser: false,
                    isLoading: true
                )
            )
        }
        .padding()
        .background(Color(hex: "F5F0E8"))
    }
}
#endif
