//
//  GoalProgressDetailView.swift
//  FUUD
//
//  目標進捗詳細ページ
//  カレンダービューと達成統計
//

import SwiftUI

@available(iOS 16.0, *)
struct GoalProgressDetailView: View {
    @StateObject private var mealService = MealLogService.shared
    @StateObject private var personalizer = NutritionPersonalizer.shared

    @State private var currentMonth = Date()
    @State private var achievedDates: Set<Date> = []

    private let calendar = Calendar.current
    private let daysOfWeek = ["日", "月", "火", "水", "木", "金", "土"]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: VirgilSpacing.lg) {
                // 進捗サマリー
                progressSummaryCard

                // カレンダー
                calendarCard

                // 統計
                statisticsCard
            }
            .padding(VirgilSpacing.md)
        }
        .background(OrbBackground())
        .navigationTitle("目標進捗")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            generateAchievedDates()
        }
    }

    // MARK: - Progress Summary Card

    private var progressSummaryCard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("進捗")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text("\(daysInProgram)日目")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.virgilTextPrimary)

                    if let totalDays = totalProgramDays {
                        Text("/ \(totalDays)日間")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.virgilTextSecondary)
                    }
                }

                // Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 12)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(hex: "00C853"))
                            .frame(width: geometry.size.width * progressPercentage, height: 12)
                            .animation(.easeOut(duration: 0.5), value: progressPercentage)
                    }
                }
                .frame(height: 12)

                Text("\(Int(progressPercentage * 100))% 完了")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.virgilTextSecondary)
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    // MARK: - Calendar Card

    private var calendarCard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // Month Navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)
                }

                Spacer()

                Text(monthYearString)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.virgilTextPrimary)

                Spacer()

                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)
                }
            }

            // Days of Week Header
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: VirgilSpacing.xs) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.virgilTextSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: VirgilSpacing.xs) {
                ForEach(daysInMonth, id: \.self) { date in
                    if let date = date {
                        CalendarDayCell(
                            date: date,
                            isAchieved: isDateAchieved(date),
                            isToday: calendar.isDateInToday(date),
                            isFuture: date > Date()
                        )
                    } else {
                        Color.clear
                            .frame(height: 36)
                    }
                }
            }

            // Legend
            HStack(spacing: VirgilSpacing.md) {
                legendItem(color: Color(hex: "00C853"), label: "達成")
                legendItem(color: Color.gray.opacity(0.3), label: "未達成")
            }
            .padding(.top, VirgilSpacing.sm)
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    private func legendItem(color: Color, label: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(label)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.virgilTextSecondary)
        }
    }

    // MARK: - Statistics Card

    private var statisticsCard: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("統計")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            VStack(spacing: VirgilSpacing.sm) {
                statRow(label: "達成日数", value: "\(achievedDaysCount)日", highlight: true)
                statRow(label: "連続達成", value: "\(currentStreak)日")
                statRow(label: "最長連続達成", value: "\(longestStreak)日")
                statRow(label: "達成率", value: "\(achievementRate)%", highlight: true)
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }

    private func statRow(label: String, value: String, highlight: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.virgilTextSecondary)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: highlight ? .bold : .medium))
                .foregroundColor(highlight ? Color(hex: "00C853") : .virgilTextPrimary)
        }
    }

    // MARK: - Computed Properties

    private var daysInProgram: Int {
        // プログラム開始日からの経過日数（デモ用）
        14
    }

    private var totalProgramDays: Int? {
        // プログラム合計日数（デモ用）
        45
    }

    private var progressPercentage: Double {
        guard let total = totalProgramDays, total > 0 else { return 0 }
        return min(Double(daysInProgram) / Double(total), 1.0)
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年 M月"
        return formatter.string(from: currentMonth)
    }

    private var daysInMonth: [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstDay)
        var days: [Date?] = Array(repeating: nil, count: firstWeekday - 1)

        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay) {
                days.append(date)
            }
        }

        return days
    }

    private var achievedDaysCount: Int {
        achievedDates.count
    }

    private var currentStreak: Int {
        var streak = 0
        var date = Date()

        while isDateAchieved(date) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = previousDay
        }

        return streak
    }

    private var longestStreak: Int {
        // デモ用：簡易計算
        max(currentStreak, 7)
    }

    private var achievementRate: Int {
        guard daysInProgram > 0 else { return 0 }
        return Int((Double(achievedDaysCount) / Double(daysInProgram)) * 100)
    }

    // MARK: - Helper Methods

    private func previousMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    private func nextMonth() {
        if let newMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = newMonth
        }
    }

    private func isDateAchieved(_ date: Date) -> Bool {
        let normalizedDate = calendar.startOfDay(for: date)
        return achievedDates.contains(normalizedDate)
    }

    private func generateAchievedDates() {
        // デモデータ：過去14日間でランダムに達成日を生成
        var dates: Set<Date> = []
        for daysAgo in 0..<14 {
            if Bool.random() || daysAgo < 5 { // 最近5日は必ず達成
                if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) {
                    dates.insert(calendar.startOfDay(for: date))
                }
            }
        }
        achievedDates = dates
    }
}

// MARK: - Calendar Day Cell

struct CalendarDayCell: View {
    let date: Date
    let isAchieved: Bool
    let isToday: Bool
    let isFuture: Bool

    private let calendar = Calendar.current

    var body: some View {
        ZStack {
            if isAchieved && !isFuture {
                Circle()
                    .fill(Color(hex: "00C853"))
                    .frame(width: 32, height: 32)
            } else if !isFuture {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 32, height: 32)
            }

            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 13, weight: isToday ? .bold : .regular))
                .foregroundColor(textColor)

            if isToday {
                Circle()
                    .stroke(Color.virgilTextPrimary, lineWidth: 2)
                    .frame(width: 32, height: 32)
            }
        }
        .frame(height: 36)
    }

    private var textColor: Color {
        if isFuture {
            return .virgilTextSecondary.opacity(0.5)
        }
        if isAchieved {
            return .white
        }
        return .virgilTextPrimary
    }
}

// MARK: - Preview

#if DEBUG
@available(iOS 16.0, *)
struct GoalProgressDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            GoalProgressDetailView()
        }
    }
}
#endif
