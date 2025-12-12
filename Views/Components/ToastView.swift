//
//  ToastView.swift
//  AWStest
//
//  コピー完了通知トースト - Virgil Design System準拠
//

import SwiftUI

/// コピー完了時に表示されるトースト通知
/// [DUMMY] 現状は固定メッセージ、将来的に動的メッセージ対応予定
struct ToastView: View {
    let message: String
    @Binding var isShowing: Bool

    var body: some View {
        VStack {
            Spacer()

            if isShowing {
                HStack(spacing: VirgilSpacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "00C853"))

                    Text(message)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.virgilTextPrimary)
                }
                .padding(.horizontal, VirgilSpacing.md)
                .padding(.vertical, VirgilSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: VirgilSpacing.radiusMedium)
                        .fill(.ultraThinMaterial)
                        .opacity(0.95)
                        .overlay(
                            RoundedRectangle(cornerRadius: VirgilSpacing.radiusMedium)
                                .fill(Color.white.opacity(0.4))
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: VirgilSpacing.radiusMedium)
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
                .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 4)
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear {
                    // 3秒後に自動で非表示
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        withAnimation {
                            isShowing = false
                        }
                    }
                }
            }
        }
        .padding(.bottom, VirgilSpacing.lg)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isShowing)
    }
}

// MARK: - View Modifier Extension

extension View {
    /// トースト通知を表示するモディファイア
    /// [DUMMY] 使用例: .showToast(message: "コピーしました", isShowing: $showToast)
    func showToast(message: String, isShowing: Binding<Bool>) -> some View {
        self.overlay(
            ToastView(message: message, isShowing: isShowing)
                .zIndex(999) // 最前面に表示
        )
    }
}
