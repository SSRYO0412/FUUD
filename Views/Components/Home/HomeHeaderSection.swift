//
//  HomeHeaderSection.swift
//  FUUD
//
//  Lifesumスタイルのヘッダーセクション
//

import SwiftUI

struct HomeHeaderSection: View {
    @StateObject private var programService = DietProgramService.shared

    var body: some View {
        VStack(spacing: VirgilSpacing.xs) {
            // App Name - Lifesum style centered
            Text("FUUD")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundColor(.virgilTextPrimary)

            // Program name if enrolled
            if let enrollment = programService.enrolledProgram {
                Text(programDisplayText(enrollment))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.virgilTextSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, VirgilSpacing.sm)
    }

    // MARK: - Helper Methods

    private func programDisplayText(_ enrollment: ProgramEnrollment) -> String {
        let program = DietProgramCatalog.programs.first { $0.id == enrollment.programId }
        let programName = program?.nameJa ?? enrollment.programId

        // Calculate remaining days using parsed date
        guard let endDate = enrollment.endDateParsed else {
            return programName
        }

        let remainingDays = Calendar.current.dateComponents([.day], from: Date(), to: endDate).day ?? 0

        if remainingDays > 0 {
            return "\(programName) (\(remainingDays)日)"
        } else {
            return programName
        }
    }
}

// MARK: - Preview

#if DEBUG
struct HomeHeaderSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.secondarySystemBackground).ignoresSafeArea()

            HomeHeaderSection()
                .padding()
        }
    }
}
#endif
