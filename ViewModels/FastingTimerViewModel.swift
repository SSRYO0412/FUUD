//
//  FastingTimerViewModel.swift
//  FUUD
//
//  Fasting Timer ViewModel - Lifesum style
//

import Foundation
import Combine

@MainActor
class FastingTimerViewModel: ObservableObject {
    static let shared = FastingTimerViewModel()

    // MARK: - Published Properties

    @Published var selectedPlan: FastingPlan = .ratio12_12
    @Published var state: FastingState = .idle
    @Published var currentSession: FastingSession?

    // Timer
    @Published var elapsedTime: TimeInterval = 0
    @Published var remainingTime: TimeInterval = 0

    // MARK: - Private Properties

    private var timer: AnyCancellable?
    private let userDefaultsKey = "fastingTimerState"

    // MARK: - Computed Properties

    var fastingStartTime: Date? {
        switch state {
        case .fasting(let startDate):
            return startDate
        case .eating(_, let fastEndDate):
            return Calendar.current.date(byAdding: .hour, value: -selectedPlan.fastingHours, to: fastEndDate)
        default:
            return nil
        }
    }

    var fastingEndTime: Date? {
        guard let start = fastingStartTime else { return nil }
        return Calendar.current.date(byAdding: .hour, value: selectedPlan.fastingHours, to: start)
    }

    var eatingEndTime: Date? {
        guard let start = fastingStartTime else { return nil }
        return Calendar.current.date(byAdding: .hour, value: 24, to: start)
    }

    var progress: Double {
        switch state {
        case .fasting:
            let totalFastingSeconds = Double(selectedPlan.fastingHours * 3600)
            return min(elapsedTime / totalFastingSeconds, 1.0)
        case .eating:
            let totalEatingSeconds = Double(selectedPlan.eatingHours * 3600)
            return min(elapsedTime / totalEatingSeconds, 1.0)
        default:
            return 0
        }
    }

    var ketosisPhase: KetosisPhase {
        guard case .fasting = state else { return .notStarted }
        let hours = elapsedTime / 3600
        return KetosisPhase.phase(for: hours)
    }

    var formattedElapsedTime: String {
        return formatTimeInterval(elapsedTime)
    }

    var formattedRemainingTime: String {
        return formatTimeInterval(remainingTime)
    }

    var statusMessage: String {
        switch state {
        case .idle:
            return "断食を開始しましょう"
        case .fasting:
            return "断食中です"
        case .eating:
            return "食事時間です"
        }
    }

    var statusSubMessage: String {
        switch state {
        case .idle:
            return ""
        case .fasting:
            return ketosisPhase.displayName
        case .eating:
            return "バランスの良い食事を"
        }
    }

    // MARK: - Initialization

    init() {
        loadState()
        startTimer()
    }

    // MARK: - Public Methods

    func startFasting(at date: Date = Date()) {
        state = .fasting(startDate: date)
        currentSession = FastingSession(plan: selectedPlan, startDate: date)
        saveState()
        updateTimerValues()
    }

    func endFasting(at date: Date = Date()) {
        guard case .fasting(let startDate) = state else { return }

        state = .eating(startDate: date, fastEndDate: date)
        currentSession?.actualFastEndDate = date

        // Calculate remaining eating window
        let fastStartTime = startDate
        let plannedEatingEnd = Calendar.current.date(byAdding: .hour, value: 24, to: fastStartTime) ?? date

        if date < plannedEatingEnd {
            // Still within the planned cycle
            elapsedTime = 0
            remainingTime = plannedEatingEnd.timeIntervalSince(date)
        }

        saveState()
    }

    func startNextFast() {
        // End current eating window and start new fast
        currentSession?.endDate = Date()
        startFasting()
    }

    func cancelFasting() {
        state = .idle
        currentSession = nil
        elapsedTime = 0
        remainingTime = 0
        saveState()
    }

    func changePlan(to plan: FastingPlan) {
        selectedPlan = plan
        saveState()
    }

    // MARK: - Private Methods

    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimerValues()
            }
    }

    private func updateTimerValues() {
        switch state {
        case .idle:
            elapsedTime = 0
            remainingTime = 0

        case .fasting(let startDate):
            elapsedTime = Date().timeIntervalSince(startDate)
            let totalFastingSeconds = Double(selectedPlan.fastingHours * 3600)
            remainingTime = max(0, totalFastingSeconds - elapsedTime)

            // Auto-transition to eating window if fasting time completed
            if elapsedTime >= totalFastingSeconds {
                endFasting(at: Date())
            }

        case .eating(let startDate, _):
            elapsedTime = Date().timeIntervalSince(startDate)
            let totalEatingSeconds = Double(selectedPlan.eatingHours * 3600)
            remainingTime = max(0, totalEatingSeconds - elapsedTime)
        }
    }

    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }

    // MARK: - Persistence

    private func saveState() {
        let data = FastingTimerData(
            selectedPlan: selectedPlan,
            state: state,
            currentSession: currentSession
        )
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }

    private func loadState() {
        guard let data = UserDefaults.standard.data(forKey: userDefaultsKey),
              let decoded = try? JSONDecoder().decode(FastingTimerData.self, from: data) else {
            return
        }
        selectedPlan = decoded.selectedPlan
        state = decoded.state
        currentSession = decoded.currentSession
    }
}

// MARK: - Persistence Model

private struct FastingTimerData: Codable {
    let selectedPlan: FastingPlan
    let state: FastingState
    let currentSession: FastingSession?
}

// MARK: - Date Formatting Helpers

extension FastingTimerViewModel {
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E, d M月, HH:mm"
        return formatter.string(from: date)
    }

    func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")

        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "'Today', HH:mm"
        } else {
            formatter.dateFormat = "E, d M月"
        }
        return formatter.string(from: date)
    }
}
