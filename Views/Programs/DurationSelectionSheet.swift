//
//  DurationSelectionSheet.swift
//  FUUD
//
//  Lifesum-style duration selection sheet
//

import SwiftUI

struct DurationSelectionSheet: View {
    let program: DietProgram
    let onStart: (ProgramEnrollment) -> Void

    @Environment(\.presentationMode) var presentationMode
    @StateObject private var programService = DietProgramService.shared
    @State private var selectedDuration: Int = 45
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showReplaceConfirmation = false

    private let durations: [(days: Int, title: String, subtitle: String, recommended: Bool)] = [
        (30, "30日コース", "4週間で基礎を固める", false),
        (45, "45日コース", "6週間でしっかり成果を出す", true),
        (90, "90日コース", "12週間で習慣化", false)
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Dark Green Header
                headerSection

                ScrollView {
                    VStack(spacing: VirgilSpacing.xl) {
                        // Duration Options
                        durationOptionsSection

                        // Roadmap Preview
                        roadmapPreviewSection

                        // Start Button
                        startButtonSection
                    }
                    .padding(.horizontal, VirgilSpacing.md)
                    .padding(.top, VirgilSpacing.lg)
                    .padding(.bottom, VirgilSpacing.xl4)
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemBackground))
        }
        .navigationViewStyle(.stack)
        .alert("エラー", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .confirmationDialog(
            "プログラムの変更",
            isPresented: $showReplaceConfirmation,
            titleVisibility: .visible
        ) {
            Button("新しいプログラムを開始", role: .destructive) {
                Task {
                    await replaceProgram()
                }
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("現在のプログラムを終了して、新しいプログラムを開始しますか？")
        }
        .task {
            // シート表示時に既存プログラムを取得
            await programService.fetchEnrolledProgram()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: VirgilSpacing.md) {
            // Safe area spacer
            Color.clear.frame(height: 20)

            // Close button row
            HStack {
                Spacer()
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, VirgilSpacing.md)

            // Title
            VStack(spacing: VirgilSpacing.xs) {
                Text("コース期間を選択")
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundColor(.white)

                Text(program.nameJa)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.bottom, VirgilSpacing.md)
        }
        .frame(maxWidth: .infinity)
        .background(
            Color.lifesumDarkGreen
                .clipShape(RoundedCorner(radius: 24, corners: [.bottomLeft, .bottomRight]))
        )
    }

    // MARK: - Duration Options Section

    private var durationOptionsSection: some View {
        VStack(spacing: VirgilSpacing.sm) {
            ForEach(durations, id: \.days) { duration in
                DurationOptionCard(
                    days: duration.days,
                    title: duration.title,
                    subtitle: duration.subtitle,
                    isRecommended: duration.recommended,
                    isSelected: selectedDuration == duration.days
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedDuration = duration.days
                    }
                }
            }
        }
    }

    // MARK: - Roadmap Preview Section

    private var roadmapPreviewSection: some View {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: selectedDuration, to: startDate) ?? startDate
        let weeks = selectedDuration / 7

        return VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("ロードマップ")
                .font(.headline)
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
                // Start Date
                HStack(spacing: VirgilSpacing.sm) {
                    Image(systemName: "calendar")
                        .foregroundColor(.lifesumDarkGreen)
                        .frame(width: 24)
                    Text("開始日: \(formatDate(startDate))")
                        .font(.subheadline)
                }

                // End Date
                HStack(spacing: VirgilSpacing.sm) {
                    Image(systemName: "flag.checkered")
                        .foregroundColor(.lifesumDarkGreen)
                        .frame(width: 24)
                    Text("終了日: \(formatDate(endDate))")
                        .font(.subheadline)
                }

                // Duration
                HStack(spacing: VirgilSpacing.sm) {
                    Image(systemName: "clock")
                        .foregroundColor(.lifesumDarkGreen)
                        .frame(width: 24)
                    Text("期間: \(selectedDuration)日間 (\(weeks)週間)")
                        .font(.subheadline)
                }
            }
            .padding(VirgilSpacing.md)
            .background(Color.lifesumCream)
            .cornerRadius(12)
        }
    }

    // MARK: - Start Button Section

    private var startButtonSection: some View {
        Button {
            Task {
                // 既存プログラムがあるかチェック
                if programService.isEnrolled {
                    showReplaceConfirmation = true
                } else {
                    await startProgram()
                }
            }
        } label: {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("START PROGRAM")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.lifesumDarkGreen)
            .cornerRadius(28)
        }
        .disabled(isLoading)
    }

    // MARK: - Helper Functions

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    private func startProgram() async {
        isLoading = true

        let success = await programService.enrollProgram(
            program.id,
            duration: selectedDuration,
            startDate: Date()
        )

        isLoading = false

        if success, let enrollment = programService.enrolledProgram {
            // 通知を送信してProgramTabRootViewを更新
            NotificationCenter.default.post(name: .programEnrollmentChanged, object: nil)
            presentationMode.wrappedValue.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onStart(enrollment)
            }
        } else {
            // エラー時の処理
            errorMessage = programService.errorMessage ?? "プログラムの開始に失敗しました"
            showError = true
        }
    }

    private func replaceProgram() async {
        isLoading = true

        // 1. 既存プログラムをキャンセル
        let cancelled = await programService.cancelEnrollment()

        if cancelled {
            // 2. 新しいプログラムを開始
            await startProgram()
        } else {
            isLoading = false
            errorMessage = programService.errorMessage ?? "プログラムの終了に失敗しました"
            showError = true
        }
    }
}

// MARK: - Duration Option Card

struct DurationOptionCard: View {
    let days: Int
    let title: String
    let subtitle: String
    let isRecommended: Bool
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: VirgilSpacing.md) {
                // Radio Button
                Circle()
                    .strokeBorder(isSelected ? Color.lifesumDarkGreen : Color.gray.opacity(0.3), lineWidth: 2)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.lifesumDarkGreen : Color.clear)
                            .padding(4)
                    )
                    .frame(width: 24, height: 24)

                // Content
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: VirgilSpacing.sm) {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)

                        if isRecommended {
                            Text("おすすめ")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.lifesumDarkGreen)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.lifesumDarkGreen.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .padding(VirgilSpacing.md)
            .background(isSelected ? Color.lifesumCream : Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.lifesumDarkGreen : Color.gray.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    DurationSelectionSheet(program: DietProgramCatalog.programs[0]) { _ in }
}
