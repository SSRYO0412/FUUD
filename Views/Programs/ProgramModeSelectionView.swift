//
//  ProgramModeSelectionView.swift
//  FUUD
//
//  Lifesum-style Program Mode Selection View
//  通常版 / pro版（血液検査ベース）選択画面
//

import SwiftUI

struct ProgramModeSelectionView: View {
    let program: DietProgram
    let selectedDuration: Int
    let onStart: (ProgramEnrollment) -> Void

    @Environment(\.presentationMode) var presentationMode
    @StateObject private var bloodTestService = BloodTestService.shared
    @State private var selectedMode: ProgramMode = .standard
    @State private var showRoadmapDetail = false
    @State private var showBloodTestRequiredAlert = false

    var body: some View {
        ZStack {
            // Full-screen dark green background
            Color.lifesumDarkGreen
                .ignoresSafeArea()

            VStack(spacing: VirgilSpacing.xl) {
                // Header
                headerSection

                Spacer()

                // Mode Selection Cards
                modeSelectionSection

                // Description based on selection
                descriptionSection

                Spacer()

                // Continue Button
                continueButtonSection

                // Footer note
                footerNote
            }
            .padding(.horizontal, VirgilSpacing.lg)
            .padding(.vertical, VirgilSpacing.xl)
        }
        .navigationBarHidden(true)
        .alert("血液検査が必要です", isPresented: $showBloodTestRequiredAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("pro版をご利用いただくには、血液検査データが必要です。検査を購入するか、通常版をお選びください。")
        }
        .background(
            NavigationLink(
                destination: ProgramRoadmapDetailView(
                    program: program,
                    selectedDuration: selectedDuration,
                    mode: selectedMode,
                    onStart: { enrollment in
                        presentationMode.wrappedValue.dismiss()
                        onStart(enrollment)
                    }
                ),
                isActive: $showRoadmapDetail
            ) { EmptyView() }
        )
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: VirgilSpacing.md) {
            // Back button row
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()

                // Program name badge
                Text(program.nameJa.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.7))
                    .tracking(1)
            }

            // Duration badge
            Text("\(selectedDuration)日コース")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .padding(.top, VirgilSpacing.sm)

            // Main title
            Text("コースタイプを選択")
                .font(.system(size: 28, weight: .regular, design: .serif))
                .foregroundColor(.white)
                .padding(.top, VirgilSpacing.md)
        }
    }

    // MARK: - Mode Selection Section

    private var modeSelectionSection: some View {
        VStack(spacing: VirgilSpacing.md) {
            ForEach(ProgramMode.allCases, id: \.self) { mode in
                ModeSelectionCard(
                    mode: mode,
                    isSelected: selectedMode == mode,
                    hasBloodData: bloodTestService.bloodData != nil
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedMode = mode
                    }
                }
            }
        }
    }

    // MARK: - Description Section

    private var descriptionSection: some View {
        VStack(spacing: VirgilSpacing.sm) {
            Text(selectedMode.description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, VirgilSpacing.lg)
                .animation(.easeInOut(duration: 0.2), value: selectedMode)

            if selectedMode == .pro {
                proModeDetailDescription
            }
        }
    }

    private var proModeDetailDescription: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
            if bloodTestService.bloodData != nil {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.green)
                    Text("血液検査データが利用可能です")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            } else {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                    Text("血液検査データがありません")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.top, VirgilSpacing.sm)
    }

    // MARK: - Continue Button Section

    private var continueButtonSection: some View {
        Button {
            handleContinue()
        } label: {
            Text("CONTINUE")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.lifesumDarkGreen)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.white)
                .cornerRadius(28)
        }
    }

    // MARK: - Footer Note

    private var footerNote: some View {
        Text("設定は後から変更できます。")
            .font(.caption)
            .foregroundColor(.white.opacity(0.5))
    }

    // MARK: - Helper Functions

    private func handleContinue() {
        if selectedMode == .pro && bloodTestService.bloodData == nil {
            showBloodTestRequiredAlert = true
        } else {
            showRoadmapDetail = true
        }
    }
}

// MARK: - Mode Selection Card

struct ModeSelectionCard: View {
    let mode: ProgramMode
    let isSelected: Bool
    let hasBloodData: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: VirgilSpacing.md) {
                // Radio Button
                Circle()
                    .strokeBorder(isSelected ? Color.white : Color.white.opacity(0.3), lineWidth: 2)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.white : Color.clear)
                            .padding(4)
                    )
                    .frame(width: 24, height: 24)

                // Content
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: VirgilSpacing.sm) {
                        Text(mode.displayName)
                            .font(.headline)
                            .foregroundColor(.white)

                        if mode == .pro {
                            Text("血液検査あり")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }

                    Text(modeSubtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                // Pro mode indicator
                if mode == .pro {
                    Image(systemName: hasBloodData ? "checkmark.circle.fill" : "lock.fill")
                        .font(.system(size: 16))
                        .foregroundColor(hasBloodData ? .green : .white.opacity(0.5))
                }
            }
            .padding(VirgilSpacing.md)
            .background(isSelected ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.white : Color.white.opacity(0.2), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var modeSubtitle: String {
        switch mode {
        case .standard:
            return "検査なしで高タンパク習慣を身につける"
        case .pro:
            return "血液データで個別最適化アドバイス"
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ProgramModeSelectionView(
            program: DietProgramCatalog.programs[0],
            selectedDuration: 45
        ) { _ in }
    }
}
