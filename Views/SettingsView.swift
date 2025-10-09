//
//  SettingsView.swift
//  AWStest
//
//  設定画面 - Virgilデザイン
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var cognitoService: SimpleCognitoService
    @State private var showingLogoutAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: VirgilSpacing.lg) {
                    accountSection
                    dataManagementSection
                    privacySection
                    supportSection
                    appInfoSection
                    logoutButton
                }
                .padding(VirgilSpacing.md)
            }
            .background(Color.virgilBackground.ignoresSafeArea())
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
            .alert("ログアウト", isPresented: $showingLogoutAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("ログアウト", role: .destructive) {
                    Task {
                        await cognitoService.signOut()
                    }
                }
            } message: {
                Text("アカウントからログアウトしますか？")
            }
        }
    }

    // MARK: - Account Section

    private var accountSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            HStack(spacing: VirgilSpacing.md) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.virgilInfo)

                VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
                    Text("ユーザーアカウント")
                        .font(.virgilBodySmall)
                        .foregroundColor(.virgilTextSecondary)

                    if let userEmail = cognitoService.currentUserEmail {
                        Text(userEmail)
                            .font(.virgilBodyLarge)
                            .foregroundColor(.virgilTextPrimary)
                    }
                }

                Spacer()
            }
        }
        .padding(VirgilSpacing.md)
        .virgilGlassCard()
    }

    // MARK: - Data Management Section

    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("データ管理")
                .font(.virgilHeading3)
                .foregroundColor(.virgilTextPrimary)
                .padding(.horizontal, VirgilSpacing.sm)

            VStack(spacing: VirgilSpacing.sm) {
                SettingsRow(
                    icon: "square.and.arrow.up",
                    title: "遺伝子データをエクスポート",
                    color: .virgilSuccess
                )

                SettingsRow(
                    icon: "doc.text",
                    title: "血液検査データをエクスポート",
                    color: .virgilError
                )

                SettingsRow(
                    icon: "arrow.triangle.2.circlepath",
                    title: "データ同期",
                    color: .virgilInfo
                )
            }
        }
    }

    // MARK: - Privacy Section

    private var privacySection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("プライバシーとセキュリティ")
                .font(.virgilHeading3)
                .foregroundColor(.virgilTextPrimary)
                .padding(.horizontal, VirgilSpacing.sm)

            VStack(spacing: VirgilSpacing.sm) {
                SettingsRow(
                    icon: "hand.raised",
                    title: "プライバシーポリシー",
                    color: .virgilWarning
                )

                SettingsRow(
                    icon: "doc.text",
                    title: "利用規約",
                    color: .virgilInfo
                )

                SettingsRow(
                    icon: "lock",
                    title: "データの取り扱いについて",
                    color: .virgilPrimary
                )
            }
        }
    }

    // MARK: - Support Section

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("サポート")
                .font(.virgilHeading3)
                .foregroundColor(.virgilTextPrimary)
                .padding(.horizontal, VirgilSpacing.sm)

            VStack(spacing: VirgilSpacing.sm) {
                SettingsRow(
                    icon: "questionmark.circle",
                    title: "ヘルプ",
                    color: .virgilInfo
                )

                SettingsRow(
                    icon: "envelope",
                    title: "お問い合わせ",
                    color: .virgilPrimary
                )

                SettingsRow(
                    icon: "heart",
                    title: "フィードバックを送信",
                    color: .virgilError
                )
            }
        }
    }

    // MARK: - App Info Section

    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("アプリ情報")
                .font(.virgilHeading3)
                .foregroundColor(.virgilTextPrimary)
                .padding(.horizontal, VirgilSpacing.sm)

            VStack(spacing: 0) {
                HStack {
                    Text("バージョン")
                        .font(.virgilBodyLarge)
                        .foregroundColor(.virgilTextPrimary)
                    Spacer()
                    Text("1.0.0") // [DUMMY] リリース時に実ビルド番号へ更新予定
                        .font(.virgilBodySmall)
                        .foregroundColor(.virgilTextSecondary)
                }
                .padding(VirgilSpacing.md)

                Divider()
                    .padding(.horizontal, VirgilSpacing.md)

                HStack {
                    Text("ビルド")
                        .font(.virgilBodyLarge)
                        .foregroundColor(.virgilTextPrimary)
                    Spacer()
                    Text("1") // [DUMMY] 実際のビルド番号に差し替え予定
                        .font(.virgilBodySmall)
                        .foregroundColor(.virgilTextSecondary)
                }
                .padding(VirgilSpacing.md)
            }
            .virgilGlassCard()
        }
    }

    // MARK: - Logout Button

    private var logoutButton: some View {
        Button {
            showingLogoutAlert = true
        } label: {
            Text("ログアウト")
                .font(.virgilBodyLarge)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(VirgilSpacing.md)
                .background(Color.virgilError)
                .cornerRadius(VirgilSpacing.radiusMedium)
        }
        .padding(.horizontal, VirgilSpacing.md)
    }
}

// MARK: - Settings Row Component

private struct SettingsRow: View {
    let icon: String
    let title: String
    let color: Color

    var body: some View {
        HStack(spacing: VirgilSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: VirgilSpacing.iconSizeMedium))
                .foregroundColor(color)
                .frame(width: 44, height: 44)

            Text(title)
                .font(.virgilBodyLarge)
                .foregroundColor(.virgilTextPrimary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.virgilTextSecondary)
        }
        .padding(VirgilSpacing.md)
        .virgilGlassCard()
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SimpleCognitoService.shared)
    }
}
#endif
