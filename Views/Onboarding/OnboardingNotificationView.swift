//
//  OnboardingNotificationView.swift
//  FUUD
//
//  Lifesum風 通知許可画面
//

import SwiftUI

struct OnboardingNotificationView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @State private var showingSystemDialog = false

    private let backgroundColor = Color(hex: "F5F0E8")
    private let primaryColor = Color(hex: "4CD964")

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Illustration
            illustrationView
                .padding(.horizontal, 40)

            Spacer().frame(height: 40)

            // Title
            VStack(spacing: 16) {
                Text("通知で目標達成をサポート")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                // Mock system dialog
                mockSystemDialog
            }
            .padding(.horizontal, 24)

            // Note
            Text("設定でいつでもリマインダーをオフにできます。")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "6B7280"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 16)

            Spacer()

            // Buttons
            VStack(spacing: 12) {
                OnboardingPrimaryButton("続ける") {
                    requestNotificationPermission()
                }

                OnboardingSecondaryButton("今はしない") {
                    viewModel.completeOnboarding()
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    @ViewBuilder
    private var illustrationView: some View {
        if let _ = UIImage(named: "onboarding_notification") {
            Image("onboarding_notification")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 200)
        } else {
            // プレースホルダー
            ZStack {
                Circle()
                    .fill(primaryColor.opacity(0.1))
                    .frame(width: 180, height: 180)

                VStack(spacing: 8) {
                    Image(systemName: "bell.badge.fill")
                        .font(.system(size: 60))
                        .foregroundColor(primaryColor)

                    Image(systemName: "figure.run")
                        .font(.system(size: 40))
                        .foregroundColor(primaryColor.opacity(0.6))
                }
            }
            .frame(height: 200)
        }
    }

    // MARK: - Mock System Dialog

    private var mockSystemDialog: some View {
        VStack(spacing: 12) {
            Text("\"FUUD\"は通知を送信します。")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)

            Text("通知には、アラート、サウンド、\nアイコンバッジが含まれる場合があります。\nこれらは設定で構成できます。")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: "6B7280"))
                .multilineTextAlignment(.center)

            Divider()

            HStack(spacing: 0) {
                Button(action: {}) {
                    Text("許可しない")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "007AFF"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }

                Divider()
                    .frame(height: 30)

                Button(action: {}) {
                    Text("許可")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "007AFF"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }

    // MARK: - Notification Permission

    private func requestNotificationPermission() {
        Task {
            let granted = await viewModel.requestNotificationPermission()
            print("Notification permission: \(granted)")
            await MainActor.run {
                viewModel.completeOnboarding()
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct OnboardingNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingNotificationView(viewModel: OnboardingViewModel())
            .background(Color(hex: "F5F0E8"))
    }
}
#endif
