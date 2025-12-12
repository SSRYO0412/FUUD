//
//  OnboardingView.swift
//  AWStest
//
//  健康プロファイルのオンボーディング画面
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    @State private var sections = HealthProfileSections()
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    let totalSteps = 5
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // プログレスバー
                let progress = max(0, min(1, Double(currentStep + 1) / Double(totalSteps)))
                ProgressView(value: progress.isNaN ? 0 : progress)
                    .padding()
                
                // ステップごとの画面
                TabView(selection: $currentStep) {
                    PhysicalInfoView(section: $sections.physical)
                        .tag(0)
                    
                    LifestyleInfoView(section: $sections.lifestyle)
                        .tag(1)
                    
                    HealthStatusView(section: $sections.healthStatus)
                        .tag(2)
                    
                    GoalsView(section: $sections.goals)
                        .tag(3)
                    
                    PreferencesView(section: $sections.preferences)
                        .tag(4)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                // ナビゲーションボタン
                HStack {
                    if currentStep > 0 {
                        Button("戻る") {
                            withAnimation {
                                currentStep -= 1
                            }
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if currentStep < totalSteps - 1 {
                        Button("次へ") {
                            withAnimation {
                                currentStep += 1
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        Button(action: saveProfile) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Text("完了")
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isLoading)
                    }
                }
                .padding()
            }
            .navigationTitle("健康プロファイル設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("スキップ") {
                        dismiss()
                    }
                }
            }
            .alert("エラー", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func saveProfile() {
        isLoading = true
        
        Task {
            do {
                let consent = HealthProfile.ConsentInfo(
                    dataUsage: true,
                    marketing: false
                )
                
                // 保存前のデータ確認
                print("💾 Saving profile with sections:")
                print("   Physical: height=\(sections.physical?.height ?? 0), weight=\(sections.physical?.weight ?? 0)")
                print("   Lifestyle: \(sections.lifestyle != nil ? "設定済み" : "未設定")")
                print("   HealthStatus: \(sections.healthStatus != nil ? "設定済み" : "未設定")")
                print("   Goals: \(sections.goals != nil ? "設定済み" : "未設定")")
                print("   Preferences: \(sections.preferences != nil ? "設定済み" : "未設定")")
                
                try await HealthProfileService.shared.createProfile(
                    sections: sections,
                    consent: consent
                )
                
                await MainActor.run {
                    isLoading = false
                    dismiss()
                }
            } catch {
                let appError = ErrorManager.shared.convertToAppError(error)
                ErrorManager.shared.logError(appError, context: "OnboardingView.saveProfile")
                
                await MainActor.run {
                    isLoading = false
                    errorMessage = ErrorManager.shared.userFriendlyMessage(for: appError)
                    showError = true
                }
            }
        }
    }
}

// MARK: - 各ステップのビュー

struct PhysicalInfoView: View {
    @Binding var section: PhysicalSection?
    @State private var height: String = ""
    @State private var weight: String = ""
    
    init(section: Binding<PhysicalSection?>) {
        self._section = section
        if let existingSection = section.wrappedValue {
            let heightString = existingSection.height != nil ? String(existingSection.height!) : ""
            let weightString = existingSection.weight != nil ? String(existingSection.weight!) : ""
            self._height = State(initialValue: heightString)
            self._weight = State(initialValue: weightString)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("身体情報")
                .font(.largeTitle)
                .bold()
                .padding(.bottom)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("身長")
                    .font(.headline)
                TextField("170", text: $height)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: height) { _ in
                        updatePhysicalSection()
                    }
                Text("cm")
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("体重")
                    .font(.headline)
                TextField("65", text: $weight)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: weight) { _ in
                        updatePhysicalSection()
                    }
                Text("kg")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            updatePhysicalSection()
        }
    }
    
    private func updatePhysicalSection() {
        var physical = PhysicalSection()
        
        if let h = Double(height), !h.isNaN && h.isFinite && h > 0 {
            physical.height = h
            print("📏 Height saved: \(h) cm")
        }
        
        if let w = Double(weight), !w.isNaN && w.isFinite && w > 0 {
            physical.weight = w
            print("⚖️ Weight saved: \(w) kg")
        }
        
        // BMI自動計算
        if let h = physical.height, let w = physical.weight, h > 0 {
            let heightInMeters = h / 100.0
            physical.bmi = w / (heightInMeters * heightInMeters)
            print("📊 BMI calculated: \(physical.bmi ?? 0)")
        }
        
        section = physical
        print("📋 PhysicalSection updated: height=\(physical.height ?? 0), weight=\(physical.weight ?? 0)")
    }
}

struct LifestyleInfoView: View {
    @Binding var section: LifestyleSection?
    @State private var smokingStatus = LifestyleSection.SmokingInfo.SmokingStatus.never
    @State private var alcoholFrequency = LifestyleSection.AlcoholInfo.AlcoholFrequency.never
    @State private var exerciseFrequency = "never"
    @State private var exerciseDuration = 30.0
    @State private var sleepHours: Double = 7.0
    
    let exerciseOptions = [
        ("never", "運動しない"),
        ("occasionally", "たまに"),
        ("weekly", "週に数回"),
        ("daily", "毎日")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("ライフスタイル")
                .font(.largeTitle)
                .bold()
                .padding(.bottom)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("喫煙")
                    .font(.headline)
                Picker("喫煙状況", selection: $smokingStatus) {
                    ForEach(LifestyleSection.SmokingInfo.SmokingStatus.allCases, id: \.self) { status in
                        Text(status.displayName).tag(status)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("飲酒")
                    .font(.headline)
                Picker("飲酒頻度", selection: $alcoholFrequency) {
                    ForEach(LifestyleSection.AlcoholInfo.AlcoholFrequency.allCases, id: \.self) { freq in
                        Text(freq.displayName).tag(freq)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("運動")
                    .font(.headline)
                Picker("運動頻度", selection: $exerciseFrequency) {
                    ForEach(exerciseOptions, id: \.0) { option in
                        Text(option.1).tag(option.0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                if exerciseFrequency != "never" {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("運動時間（分）")
                            .font(.subheadline)
                        HStack {
                            Slider(value: $exerciseDuration, in: 10...120, step: 10)
                            Text("\(Int(exerciseDuration))分")
                                .frame(width: 60)
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("睡眠時間")
                    .font(.headline)
                HStack {
                    Slider(value: $sleepHours, in: 4...12, step: 0.5)
                    Text("\(sleepHours.isNaN ? 7.0 : sleepHours, specifier: "%.1f")時間")
                        .frame(width: 80)
                }
            }
            
            Spacer()
        }
        .padding()
        .onDisappear {
            // 値を保存
            var lifestyle = LifestyleSection()
            lifestyle.smoking = LifestyleSection.SmokingInfo(status: smokingStatus)
            lifestyle.alcohol = LifestyleSection.AlcoholInfo(frequency: alcoholFrequency)
            lifestyle.exercise = LifestyleSection.ExerciseInfo(
                frequency: exerciseFrequency,
                types: nil,
                duration: exerciseFrequency != "never" ? Int(exerciseDuration) : nil
            )
            let validSleepHours = sleepHours.isNaN || !sleepHours.isFinite ? 7.0 : max(4.0, min(12.0, sleepHours))
            lifestyle.sleep = LifestyleSection.SleepInfo(averageHours: validSleepHours)
            section = lifestyle
        }
    }
}

struct HealthStatusView: View {
    @Binding var section: HealthStatusSection?
    @State private var selectedIssues: Set<String> = []
    @State private var selectedAllergies: Set<String> = []
    @State private var hasMedications = false
    
    let commonIssues = [
        "疲労感", "ストレス", "体重管理",
        "睡眠不足", "運動不足", "肩こり・腰痛"
    ]
    
    let commonAllergies = [
        "花粉症", "食物アレルギー", "動物アレルギー",
        "ダニ・ハウスダスト", "薬物アレルギー"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("現在の健康状態")
                .font(.largeTitle)
                .bold()
                .padding(.bottom)
            
            Text("気になる症状を選択してください（複数選択可）")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 15) {
                ForEach(commonIssues, id: \.self) { issue in
                    Button(action: {
                        if selectedIssues.contains(issue) {
                            selectedIssues.remove(issue)
                        } else {
                            selectedIssues.insert(issue)
                        }
                    }) {
                        Text(issue)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 10)
                            .background(selectedIssues.contains(issue) ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedIssues.contains(issue) ? .white : .primary)
                            .cornerRadius(20)
                    }
                }
            }
            
            Text("アレルギー情報（該当するものを選択）")
                .font(.headline)
                .padding(.top)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 10) {
                ForEach(commonAllergies, id: \.self) { allergy in
                    Button(action: {
                        if selectedAllergies.contains(allergy) {
                            selectedAllergies.remove(allergy)
                        } else {
                            selectedAllergies.insert(allergy)
                        }
                    }) {
                        Text(allergy)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedAllergies.contains(allergy) ? Color.orange : Color.gray.opacity(0.2))
                            .foregroundColor(selectedAllergies.contains(allergy) ? .white : .primary)
                            .cornerRadius(15)
                    }
                }
            }
            
            Toggle("現在服用中の薬がある", isOn: $hasMedications)
                .font(.headline)
                .padding(.top)
            
            Spacer()
        }
        .padding()
        .onDisappear {
            // 値を保存
            var status = HealthStatusSection()
            status.currentIssues = Array(selectedIssues)
            status.allergies = Array(selectedAllergies)
            status.hasMedications = hasMedications
            section = status
        }
    }
}

struct GoalsView: View {
    @Binding var section: GoalsSection?
    @State private var primaryGoal = "health_maintenance"
    @State private var targetWeight = ""
    @State private var timeframe = "3_months"
    
    let goals = [
        ("weight_loss", "体重を減らす"),
        ("muscle_gain", "筋肉をつける"),
        ("health_maintenance", "健康維持"),
        ("stress_reduction", "ストレス軽減"),
        ("better_sleep", "睡眠改善")
    ]
    
    let timeframes = [
        ("1_month", "1ヶ月"),
        ("3_months", "3ヶ月"),
        ("6_months", "6ヶ月"),
        ("1_year", "1年")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("健康目標")
                .font(.largeTitle)
                .bold()
                .padding(.bottom)
            
            Text("主な目標を選択してください")
                .font(.headline)
            
            ForEach(goals, id: \.0) { goal in
                Button(action: {
                    primaryGoal = goal.0
                }) {
                    HStack {
                        Image(systemName: primaryGoal == goal.0 ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(primaryGoal == goal.0 ? .blue : .gray)
                        Text(goal.1)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            
            if primaryGoal == "weight_loss" || primaryGoal == "muscle_gain" {
                VStack(alignment: .leading, spacing: 10) {
                    Text("目標体重")
                        .font(.headline)
                    TextField("例: 60", text: $targetWeight)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Text("kg")
                        .foregroundColor(.secondary)
                }
                .padding(.top)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("目標期間")
                    .font(.headline)
                Picker("期間", selection: $timeframe) {
                    ForEach(timeframes, id: \.0) { frame in
                        Text(frame.1).tag(frame.0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.top)
            
            Spacer()
        }
        .padding()
        .onDisappear {
            // 値を保存
            var goalsSection = GoalsSection(primary: primaryGoal)
            goalsSection.timeframe = timeframe
            
            if let targetWeightValue = Double(targetWeight), targetWeightValue > 0 {
                goalsSection.targetWeight = targetWeightValue
            }
            
            section = goalsSection
        }
    }
}

// MARK: - Preferences View

struct PreferencesView: View {
    @Binding var section: PreferencesSection?
    @State private var communicationStyle = "friendly"
    @State private var reminderFrequency = "weekly"
    @State private var selectedInterests: Set<String> = []
    
    let communicationStyles = [
        ("friendly", "親しみやすい"),
        ("professional", "専門的"),
        ("casual", "カジュアル")
    ]
    
    let reminderOptions = [
        ("never", "通知しない"),
        ("weekly", "週1回"),
        ("daily", "毎日")
    ]
    
    let healthInterests = [
        "栄養・食事", "運動・フィットネス", "メンタルヘルス",
        "睡眠改善", "ストレス管理", "予防医学"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("設定・お好み")
                .font(.largeTitle)
                .bold()
                .padding(.bottom)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("コミュニケーションスタイル")
                    .font(.headline)
                Picker("スタイル", selection: $communicationStyle) {
                    ForEach(communicationStyles, id: \.0) { style in
                        Text(style.1).tag(style.0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("リマインダー頻度")
                    .font(.headline)
                Picker("頻度", selection: $reminderFrequency) {
                    ForEach(reminderOptions, id: \.0) { option in
                        Text(option.1).tag(option.0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("興味のある健康分野")
                    .font(.headline)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 10) {
                    ForEach(healthInterests, id: \.self) { interest in
                        Button(action: {
                            if selectedInterests.contains(interest) {
                                selectedInterests.remove(interest)
                            } else {
                                selectedInterests.insert(interest)
                            }
                        }) {
                            Text(interest)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(selectedInterests.contains(interest) ? Color.green : Color.gray.opacity(0.2))
                                .foregroundColor(selectedInterests.contains(interest) ? .white : .primary)
                                .cornerRadius(15)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .onDisappear {
            // 値を保存
            var preferences = PreferencesSection()
            preferences.communicationStyle = communicationStyle
            preferences.reminderFrequency = reminderFrequency
            preferences.interests = Array(selectedInterests)
            section = preferences
        }
    }
}
