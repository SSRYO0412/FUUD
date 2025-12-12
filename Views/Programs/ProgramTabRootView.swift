//
//  ProgramTabRootView.swift
//  FUUD
//
//  Programタブのルートビュー
//  プログラム進行中 → ProgramContainerView を直接表示
//  未登録 → ProgramCatalogView を表示
//

import SwiftUI

struct ProgramTabRootView: View {
    @StateObject private var programService = DietProgramService.shared
    @State private var isLoading = true

    var body: some View {
        Group {
            if isLoading {
                // ローディング中
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                    Text("読み込み中...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 8)
                }
            } else if let enrollment = programService.enrolledProgram,
                      let program = DietProgramCatalog.find(by: enrollment.programId) {
                // プログラム進行中: ProgramContainerViewを直接表示
                ProgramContainerView(program: program, isRootView: true)
            } else {
                // 未登録: ProgramCatalogViewを表示
                ProgramCatalogView()
            }
        }
        .task {
            await loadEnrollment()
        }
        .onReceive(NotificationCenter.default.publisher(for: .programEnrollmentChanged)) { _ in
            Task {
                await loadEnrollment()
            }
        }
    }

    private func loadEnrollment() async {
        isLoading = true
        await programService.fetchEnrolledProgram()
        isLoading = false
    }
}

// MARK: - Notification Name Extension

extension Notification.Name {
    static let programEnrollmentChanged = Notification.Name("programEnrollmentChanged")
}

// MARK: - Preview

#Preview {
    NavigationView {
        ProgramTabRootView()
    }
}
