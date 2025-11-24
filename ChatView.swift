//
//  ChatView.swift
//  AWStest
//
//  AI相談チャット - iOS 26 Liquid Glass Design
//

import SwiftUI

struct ChatView: View {
    @State private var message = ""
    @State private var chatHistory: [ChatMessage] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedTopic = "general_health"
    @State private var requestedGeneRequests: [GeneRequest] = [] // AIが要求した遺伝子データ（2段階抽出対応）

    let topics = [
        ("general_health", "一般的な健康"),
        ("nutrition", "栄養"),
        ("exercise", "運動"),
        ("lifestyle", "ライフスタイル")
    ]

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "FAFAFA"), Color(hex: "F0F0F0")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Background Orbs
            OrbBackground()

            VStack(spacing: 0) {
                // トピック選択（カスタムタブ風）
                TopicSelector(topics: topics, selectedTopic: $selectedTopic)
                    .padding(.horizontal, VirgilSpacing.md)
                    .padding(.top, VirgilSpacing.sm)


                // チャット履歴
                ScrollView {
                    VStack(spacing: VirgilSpacing.md) {
                        ForEach(Array(chatHistory.enumerated()), id: \.offset) { index, chat in
                            if chat.role == "user" {
                                HStack {
                                    Spacer(minLength: 50)
                                    UserMessageBubble(content: chat.content)
                                }
                            } else {
                                HStack {
                                    AIMessageBubble(content: chat.content)
                                    Spacer(minLength: 50)
                                }
                            }
                        }

                        // タイピングインジケーター
                        if isLoading {
                            HStack {
                                TypingIndicator()
                                Spacer(minLength: 50)
                            }
                        }
                    }
                    .padding(.horizontal, VirgilSpacing.md)
                    .padding(.top, VirgilSpacing.md)
                }

                // エラーメッセージ
                if let error = errorMessage {
                    Text(error)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "ED1C24"))
                        .padding(VirgilSpacing.sm)
                        .virgilGlassCard()
                        .padding(.horizontal, VirgilSpacing.md)
                }

                // 入力フィールド
                ChatInputField(
                    message: $message,
                    isLoading: isLoading,
                    onSend: sendMessage
                )
                .padding(.horizontal, VirgilSpacing.md)
                .padding(.bottom, VirgilSpacing.md)
            }
        }
        .navigationTitle("TUUN.ai")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func sendMessage() {
        let userMessage = message
        message = ""
        errorMessage = nil
        isLoading = true

        Task {
            do {
                // ✅ 送信前に初回判定（chatHistoryに追加する前）
                let isFirstMessage = chatHistory.isEmpty

                // ✅ 改善版APIを呼び出し（この時点のchatHistoryは最新メッセージを含まない）
                let response = try await ChatService.shared.sendEnhancedMessage(
                    userMessage,
                    topic: selectedTopic,
                    conversationHistory: chatHistory,
                    requestedGeneRequests: requestedGeneRequests,
                    isFirstMessage: isFirstMessage
                )

                await MainActor.run {
                    // ✅ 送信成功後に履歴追加（ユーザーメッセージ + AI応答）
                    let userTimestamp = ISO8601DateFormatter().string(from: Date())
                    let userChatMessage = ChatMessage(role: "user", content: userMessage, timestamp: userTimestamp)
                    chatHistory.append(userChatMessage)

                    let aiTimestamp = ISO8601DateFormatter().string(from: Date())
                    let aiChatMessage = ChatMessage(role: "assistant", content: response, timestamp: aiTimestamp)
                    chatHistory.append(aiChatMessage)

                    // AI応答から遺伝子データ要求を検出（次回送信用）
                    requestedGeneRequests = ChatService.shared.extractRequestedGeneCategories(from: response)

                    isLoading = false
                }
            } catch {
                let appError = ErrorManager.shared.convertToAppError(error)
                ErrorManager.shared.logError(appError, context: "ChatView.sendMessage")

                await MainActor.run {
                    errorMessage = ErrorManager.shared.userFriendlyMessage(for: appError)
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Topic Selector

struct TopicSelector: View {
    let topics: [(String, String)]
    @Binding var selectedTopic: String

    var body: some View {
        HStack(spacing: VirgilSpacing.xs) {
            ForEach(topics, id: \.0) { topic in
                Button {
                    selectedTopic = topic.0
                } label: {
                    Text(topic.1)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(selectedTopic == topic.0 ? .white : .virgilTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, VirgilSpacing.sm)
                        .background(selectedTopic == topic.0 ? Color.black : Color.clear)
                        .cornerRadius(VirgilSpacing.radiusMedium)
                }
            }
        }
        .padding(VirgilSpacing.xs)
        .background(Color.white.opacity(0.08))
        .cornerRadius(VirgilSpacing.radiusLarge)
        .overlay(
            RoundedRectangle(cornerRadius: VirgilSpacing.radiusLarge)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Message Bubbles

struct UserMessageBubble: View {
    let content: String

    var body: some View {
        Text(content)
            .font(.system(size: 13, weight: .regular))
            .foregroundColor(.white)
            .padding(VirgilSpacing.md)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .opacity(0.4)

                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(hex: "0088CC").opacity(0.6))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        Color.white.opacity(0.3),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)
    }
}

struct AIMessageBubble: View {
    let content: String

    var body: some View {
        Text(content)
            .font(.system(size: 13, weight: .regular))
            .foregroundColor(.virgilTextPrimary)
            .padding(VirgilSpacing.md)
            .virgilGlassCard()
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var animationPhase = 0

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color.virgilTextSecondary)
                    .frame(width: 8, height: 8)
                    .opacity(animationPhase == index ? 1.0 : 0.3)
            }
        }
        .padding(VirgilSpacing.md)
        .virgilGlassCard()
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                withAnimation {
                    animationPhase = (animationPhase + 1) % 3
                }
            }
        }
    }
}

// MARK: - Chat Input Field

struct ChatInputField: View {
    @Binding var message: String
    let isLoading: Bool
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: VirgilSpacing.sm) {
            TextField("メッセージを入力...", text: $message)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.virgilTextPrimary)
                .padding(VirgilSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .opacity(0.95)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.4))
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.5
                        )
                )
                .disabled(isLoading)

            Button(action: onSend) {
                ZStack {
                    Circle()
                        .fill(message.isEmpty ? Color.gray : Color(hex: "0088CC"))
                        .frame(width: 44, height: 44)
                        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 2)

                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .disabled(message.isEmpty || isLoading)
        }
    }
}
