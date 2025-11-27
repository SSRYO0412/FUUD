//
//  ProfileView.swift
//  AWStest
//
//  PROFILE画面 - HTML版完全一致
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var cognitoService: SimpleCognitoService
    @ObservedObject var demoModeManager = DemoModeManager.shared
    @State private var showingLogoutAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.secondarySystemBackground)
                    .ignoresSafeArea()

                // Orb Background Animation
                OrbBackground()

                ScrollView {
                    VStack(spacing: VirgilSpacing.md) {
                        accountSection
                        dataManagementSection
                        privacySection
                        supportSection
                        demoModeSection
                        appInfoSection
                        logoutButton
                    }
                    .padding(.horizontal, VirgilSpacing.md)
                    .padding(.top, VirgilSpacing.sm)
                }
            }
            .navigationTitle("profile")
            .floatingChatButton()
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
                    .foregroundColor(Color(hex: "#0088CC"))

                VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
                    Text("USER ACCOUNT")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.gray)

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
        .liquidGlassCard()
    }

    // MARK: - Data Management Section

    private var dataManagementSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("DATA MANAGEMENT")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.horizontal, VirgilSpacing.sm)

            VStack(spacing: VirgilSpacing.sm) {
                ProfileRow(icon: "square.and.arrow.up", title: "Export Gene Data", color: Color(hex: "#00C853"))
                ProfileRow(icon: "doc.text", title: "Export Blood Data", color: Color(hex: "#ED1C24"))
                ProfileRow(icon: "arrow.triangle.2.circlepath", title: "Sync Data", color: Color(hex: "#0088CC"))
            }
        }
    }

    // MARK: - Privacy Section

    private var privacySection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("PRIVACY & SECURITY")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.horizontal, VirgilSpacing.sm)

            VStack(spacing: VirgilSpacing.sm) {
                ProfileRow(icon: "hand.raised", title: "Privacy Policy", color: Color(hex: "#FFCB05"))
                ProfileRow(icon: "doc.text", title: "Terms of Service", color: Color(hex: "#0088CC"))
                ProfileRow(icon: "lock", title: "Data Handling", color: Color.black)
            }
        }
    }

    // MARK: - Support Section

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("SUPPORT")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.horizontal, VirgilSpacing.sm)

            VStack(spacing: VirgilSpacing.sm) {
                ProfileRow(icon: "questionmark.circle", title: "Help", color: Color(hex: "#0088CC"))
                ProfileRow(icon: "envelope", title: "Contact Us", color: Color.black)
                ProfileRow(icon: "heart", title: "Send Feedback", color: Color(hex: "#ED1C24"))
            }
        }
    }

    // MARK: - Demo Mode Section

    private var demoModeSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("DEMO MODE")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.horizontal, VirgilSpacing.sm)

            HStack {
                VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
                    Text("デモモード")
                        .font(.virgilBodyLarge)
                        .foregroundColor(.virgilTextPrimary)
                    Text("デモ用のサンプルデータを表示")
                        .font(.virgilBodySmall)
                        .foregroundColor(.virgilTextSecondary)
                }

                Spacer()

                Toggle("", isOn: $demoModeManager.isDemoMode)
                    .labelsHidden()
            }
            .padding(VirgilSpacing.md)
            .liquidGlassCard()
        }
    }

    // MARK: - App Info Section

    private var appInfoSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("APP INFO")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.horizontal, VirgilSpacing.sm)

            VStack(spacing: 0) {
                HStack {
                    Text("Version")
                        .font(.virgilBodyLarge)
                        .foregroundColor(.virgilTextPrimary)
                    Spacer()
                    Text("1.0.0") // [DUMMY] 実際のアプリバージョンに置き換え予定
                        .font(.virgilBodySmall)
                        .foregroundColor(.virgilTextSecondary)
                }
                .padding(VirgilSpacing.md)

                Divider()
                    .padding(.horizontal, VirgilSpacing.md)

                HStack {
                    Text("Build")
                        .font(.virgilBodyLarge)
                        .foregroundColor(.virgilTextPrimary)
                    Spacer()
                    Text("1") // [DUMMY] 正式ビルド番号で更新予定
                        .font(.virgilBodySmall)
                        .foregroundColor(.virgilTextSecondary)
                }
                .padding(VirgilSpacing.md)
            }
            .liquidGlassCard()
        }
    }

    // MARK: - Logout Button

    private var logoutButton: some View {
        Button {
            showingLogoutAlert = true
        } label: {
            Text("SIGN OUT")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(VirgilSpacing.md)
                .background(Color(hex: "#ED1C24"))
                .cornerRadius(VirgilSpacing.radiusMedium)
        }
        .padding(.horizontal, VirgilSpacing.md)
    }
}

// MARK: - Profile Row Component

private struct ProfileRow: View {
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
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.virgilTextPrimary)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.virgilTextSecondary)
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }
}

// MARK: - Preview

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(SimpleCognitoService.shared)
    }
}
#endif
