//
//  MorningCheckInSection.swift
//  FUUD
//
//  朝の問診セクション（プレースホルダー）
//  Phase 6-UI: TodayProgramView用
//

import SwiftUI

struct MorningCheckInSection: View {
    let dayContext: DayContext
    let onCheckIn: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // Section Title
            Text("MORNING CHECK-IN")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)

            // Content
            if dayContext.isEmpty {
                // 未入力: チェックインボタン
                checkInButton
            } else {
                // 入力済み: サマリー表示
                checkInSummary
            }
        }
        .padding(.horizontal, VirgilSpacing.md)
    }

    // MARK: - Check In Button

    private var checkInButton: some View {
        Button(action: onCheckIn) {
            HStack(spacing: VirgilSpacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.lifesumDarkGreen.opacity(0.1))
                        .frame(width: 48, height: 48)

                    Image(systemName: "sun.horizon.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.lifesumDarkGreen)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("今朝の調子を教えてください")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text("睡眠・エネルギー・食欲をチェック")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(VirgilSpacing.md)
            .background(Color.lifesumCream)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Check In Summary

    private var checkInSummary: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.lifesumDarkGreen)

                Text("チェックイン完了")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.lifesumDarkGreen)

                Spacer()

                Button(action: onCheckIn) {
                    Text("編集")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Summary Items
            HStack(spacing: VirgilSpacing.md) {
                if let sleep = dayContext.sleepQuality {
                    summaryItem(icon: sleep.icon, label: sleep.displayName)
                }

                if let energy = dayContext.energyLevel {
                    summaryItem(icon: energy.icon, label: energy.displayName)
                }

                if let appetite = dayContext.appetiteLevel {
                    summaryItem(icon: appetite.icon, label: appetite.displayName)
                }
            }
        }
        .padding(VirgilSpacing.md)
        .background(Color.lifesumDarkGreen.opacity(0.05))
        .cornerRadius(12)
    }

    private func summaryItem(icon: String, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.lifesumDarkGreen)

            Text(label)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.white)
        .cornerRadius(4)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        // 未入力状態
        MorningCheckInSection(
            dayContext: .empty,
            onCheckIn: {}
        )

        Divider()

        // 入力済み状態
        MorningCheckInSection(
            dayContext: DayContext(
                sleepQuality: .good,
                energyLevel: .normal,
                appetiteLevel: .normal,
                stressLevel: nil,
                notes: nil,
                recordedAt: Date()
            ),
            onCheckIn: {}
        )
    }
    .padding()
    .background(Color(.systemBackground))
}
