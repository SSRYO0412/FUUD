//
//  TuuningIntelligenceView.swift
//  AWStest
//
//  Tuuning Intelligence AIメッセージ表示
//

import SwiftUI

struct TuuningIntelligenceView: View {
    @State private var currentMessageIndex = 0
    @State private var isRefreshing = false

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 12) {
                    Text("✨")
                        .font(.system(size: 16))

                    Text("TUUNING INTELLIGENCE")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.virgilTextSecondary)
                        
                }

                Spacer()

                // Refresh Button
                Button(action: refreshIntelligence) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)
                        .frame(width: 24, height: 24)
                        .background(Color.white.opacity(0.5))
                        .clipShape(Circle())
                        .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                }
            }

            // Message Text
            Text(currentMessage)
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.virgilTextPrimary)
                .lineSpacing(1.6)
                .frame(minHeight: 80, alignment: .topLeading)
                .opacity(isRefreshing ? 0.3 : 1.0)

            // AI Indicator (top-right pulsing dot)
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "9333EA"), Color(hex: "EC4899")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 6, height: 6)
                .shadow(color: Color(hex: "9333EA").opacity(0.5), radius: 12)
                .modifier(PulsingModifier())
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding([.top, .trailing], 16)
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "9333EA").opacity(0.06),
                    Color(hex: "EC4899").opacity(0.06)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "9333EA").opacity(0.15), lineWidth: 1)
        )
        .cornerRadius(12)
        .onAppear {
            startAutoRefresh()
        }
    }

    private var currentMessage: String {
        TuuningIntelligence.messages[currentMessageIndex] // [DUMMY] 実際のAI分析結果に置き換え
    }

    private func refreshIntelligence() {
        isRefreshing = true

        withAnimation(.linear(duration: 0.8)) {
            // Spin animation handled by rotationEffect
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // [DUMMY] 実際のAI APIコールに置き換え
            currentMessageIndex = (currentMessageIndex + 1) % TuuningIntelligence.messages.count
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isRefreshing = false
        }
    }

    private func startAutoRefresh() {
        // [DUMMY] 30秒ごとの自動更新、実際はAPI更新タイミングに合わせる
        Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentMessageIndex = (currentMessageIndex + 1) % TuuningIntelligence.messages.count
            }
        }
    }
}

#if DEBUG
struct TuuningIntelligenceView_Previews: PreviewProvider {
    static var previews: some View {
        TuuningIntelligenceView()
            .padding()
            .background(Color.white)
    }
}
#endif
