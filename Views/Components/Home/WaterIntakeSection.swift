//
//  WaterIntakeSection.swift
//  FUUD
//
//  Lifesum風の水分摂取セクション
//

import SwiftUI

struct WaterIntakeSection: View {
    @State private var waterGlasses: Int = 0
    @AppStorage("waterIntakeGlasses") private var savedGlasses: Int = 0

    private let targetGlasses: Int = 8  // 8 glasses = approx 2L
    private let glassVolume: Double = 0.25  // 250ml per glass

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            // Header
            HStack {
                Text("Water (\(String(format: "%.1f", Double(waterGlasses) * glassVolume)) L)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.virgilTextPrimary)

                Spacer()

                // More options button
                Button(action: {
                    // Future: Show water settings
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.virgilTextSecondary)
                }
            }

            // Water glasses visualization
            HStack(spacing: VirgilSpacing.xs) {
                ForEach(0..<targetGlasses, id: \.self) { index in
                    WaterGlassIcon(isFilled: index < waterGlasses)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                // Toggle glass: if tapping filled glass at this position, unfill from here
                                // if tapping empty glass, fill up to here
                                if index < waterGlasses {
                                    waterGlasses = index
                                } else {
                                    waterGlasses = index + 1
                                }
                                savedGlasses = waterGlasses
                            }
                        }
                }

                Spacer()

                // Add button
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        if waterGlasses < targetGlasses {
                            waterGlasses += 1
                            savedGlasses = waterGlasses
                        }
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)
                        .frame(width: 28, height: 28)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
        .onAppear {
            // Load saved value, but reset if it's a new day
            let today = Calendar.current.startOfDay(for: Date())
            let lastSavedDate = UserDefaults.standard.object(forKey: "waterLastSavedDate") as? Date ?? Date.distantPast
            let lastSavedDay = Calendar.current.startOfDay(for: lastSavedDate)

            if today > lastSavedDay {
                // New day, reset water intake
                waterGlasses = 0
                savedGlasses = 0
                UserDefaults.standard.set(today, forKey: "waterLastSavedDate")
            } else {
                waterGlasses = savedGlasses
            }
        }
    }
}

// MARK: - Water Glass Icon

struct WaterGlassIcon: View {
    let isFilled: Bool

    var body: some View {
        Image(systemName: isFilled ? "cup.and.saucer.fill" : "cup.and.saucer")
            .font(.system(size: 22))
            .foregroundColor(isFilled ? Color(hex: "4FC3F7") : Color.gray.opacity(0.3))
            .scaleEffect(isFilled ? 1.0 : 0.9)
            .animation(.spring(response: 0.3), value: isFilled)
    }
}

// MARK: - Preview

#if DEBUG
struct WaterIntakeSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.secondarySystemBackground).ignoresSafeArea()

            WaterIntakeSection()
                .padding()
        }
    }
}
#endif
