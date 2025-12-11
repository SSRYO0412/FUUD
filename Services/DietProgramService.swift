//
//  DietProgramService.swift
//  FUUD
//
//  Service for diet program management (v1: local catalog + backend enrollment)
//

import Foundation
import Combine

class DietProgramService: ObservableObject {
    static let shared = DietProgramService()

    // MARK: - Published Properties

    @Published var enrolledProgram: ProgramEnrollment?
    @Published var recommendedPrograms: [DietProgram] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Local Catalog

    /// Program catalog (local Swift constants)
    var programCatalog: [DietProgram] {
        DietProgramCatalog.programs
    }

    // MARK: - Private Properties

    private let networkManager = NetworkManager.shared
    private var cancellables = Set<AnyCancellable>()

    private init() {
        // Generate initial recommendations
        generateRecommendations()
    }

    // MARK: - Local Computation

    /// Generate recommended programs based on blood/gene data
    func generateRecommendations() {
        // TODO: Integrate with BloodTestService and GeneDataService when available
        // For now, return featured programs

        recommendedPrograms = DietProgramCatalog.featuredPrograms
    }

    /// Calculate program score based on user's biomarkers
    func calculateProgramScore(_ program: DietProgram) -> Int {
        var score = 50  // Base score

        // Boost score based on recommend conditions
        // TODO: Implement when BloodTestService is available
        // for condition in program.recommendConditions {
        //     let biomarkerValue = bloodTestService.getValue(for: condition.biomarker)
        //     if meets(condition, value: biomarkerValue) {
        //         score += condition.scoreBoost
        //     }
        // }

        // Reduce score for contraindications
        // TODO: Implement when user health profile is available
        // for contraindication in program.contraindications {
        //     if user.hasCondition(contraindication.condition) {
        //         if contraindication.severity == .prohibited {
        //             return -1000  // Exclude from recommendations
        //         }
        //         score -= 30
        //     }
        // }

        return score
    }

    /// Generate roadmap for a program
    func generateRoadmap(for program: DietProgram, duration: Int, startDate: Date = Date()) -> [RoadmapWeek] {
        let totalWeeks = duration / 7
        var roadmap: [RoadmapWeek] = []

        for weekIndex in 0..<totalWeeks {
            let phaseIndex = min(weekIndex, program.phases.count - 1)
            let phase = program.phases[phaseIndex]
            let weekStartDate = Calendar.current.date(byAdding: .day, value: weekIndex * 7, to: startDate) ?? startDate

            roadmap.append(RoadmapWeek(
                weekNumber: weekIndex + 1,
                startDate: weekStartDate,
                phaseName: phase.name,
                phaseNameEn: phase.nameEn,
                focusPoints: phase.focusPoints,
                calorieMultiplier: phase.calorieMultiplier,
                pfcOverride: phase.pfcOverride
            ))
        }

        return roadmap
    }

    /// Get current phase for enrollment
    func getCurrentPhase(for enrollment: ProgramEnrollment) -> ProgramPhase? {
        guard let program = DietProgramCatalog.find(by: enrollment.programId) else {
            return nil
        }

        let currentWeek = enrollment.currentWeek
        let phaseIndex = min(currentWeek - 1, program.phases.count - 1)

        return program.phases.indices.contains(phaseIndex) ? program.phases[phaseIndex] : nil
    }

    // MARK: - API Methods

    /// Enroll in a program
    @MainActor
    func enrollProgram(_ programId: String, duration: Int, startDate: Date = Date()) async -> Bool {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        // Prepare request body
        let dateFormatter = ISO8601DateFormatter()
        let body: [String: Any] = [
            "program_id": programId,
            "duration": duration,
            "start_date": dateFormatter.string(from: startDate)
        ]

        // Create endpoint URL
        let endpoint = ConfigurationManager.shared.apiEndpoints.fuudBase + "/api/v1/programs/\(programId)/enroll"

        do {
            let config = NetworkManager.RequestConfig(
                url: endpoint,
                method: .POST,
                body: body,
                requiresAuth: true
            )

            let response: EnrollmentResponse = try await networkManager.sendRequest(config: config, responseType: EnrollmentResponse.self)
            self.enrolledProgram = response.enrollment

            return true
        } catch {
            self.errorMessage = "プログラムの登録に失敗しました: \(error.localizedDescription)"
            print("Enrollment error: \(error)")
            return false
        }
    }

    /// Fetch currently enrolled program
    @MainActor
    func fetchEnrolledProgram() async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        let endpoint = ConfigurationManager.shared.apiEndpoints.fuudBase + "/api/v1/programs/enrolled"

        do {
            let config = NetworkManager.RequestConfig(
                url: endpoint,
                method: .GET,
                requiresAuth: true
            )

            let response: EnrollmentResponse = try await networkManager.sendRequest(config: config, responseType: EnrollmentResponse.self)
            self.enrolledProgram = response.enrollment
        } catch {
            // No enrolled program or error
            self.enrolledProgram = nil

            // Only set error message for non-404 errors
            if let urlError = error as? URLError, urlError.code != .badServerResponse {
                self.errorMessage = "登録中のプログラムの取得に失敗しました"
            }
        }
    }

    /// Cancel enrollment
    @MainActor
    func cancelEnrollment() async -> Bool {
        guard enrolledProgram != nil else { return false }

        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        let endpoint = ConfigurationManager.shared.apiEndpoints.fuudBase + "/api/v1/programs/enrolled"

        do {
            let config = NetworkManager.RequestConfig(
                url: endpoint,
                method: .DELETE,
                requiresAuth: true
            )

            _ = try await networkManager.sendRequest(config: config, responseType: EmptyResponse.self)
            self.enrolledProgram = nil

            return true
        } catch {
            self.errorMessage = "プログラムのキャンセルに失敗しました"
            return false
        }
    }

    // MARK: - Helper Methods

    /// Check if user is currently enrolled in any program
    var isEnrolled: Bool {
        enrolledProgram?.isActive ?? false
    }

    /// Get program by ID
    func getProgram(by id: String) -> DietProgram? {
        DietProgramCatalog.find(by: id)
    }

    /// Get current enrolled program details
    var currentProgramDetails: DietProgram? {
        guard let enrollment = enrolledProgram else { return nil }
        return getProgram(by: enrollment.programId)
    }

    /// Calculate adjusted calories for current phase
    func getAdjustedCalories(baseCalories: Int) -> Int {
        guard let enrollment = enrolledProgram,
              let phase = getCurrentPhase(for: enrollment) else {
            return baseCalories
        }

        return Int(Double(baseCalories) * phase.calorieMultiplier)
    }

    /// Get PFC ratio for current phase
    func getCurrentPFC() -> PFCRatio {
        guard let enrollment = enrolledProgram,
              let phase = getCurrentPhase(for: enrollment) else {
            return .balanced
        }

        return phase.pfcOverride ?? currentProgramDetails?.basePFC ?? .balanced
    }
}

// MARK: - Demo/Testing Support

extension DietProgramService {
    /// Create a demo enrollment for testing
    func createDemoEnrollment(programId: String = "low-carb-28", duration: Int = 45) {
        let dateFormatter = ISO8601DateFormatter()
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .day, value: duration, to: startDate) ?? startDate

        enrolledProgram = ProgramEnrollment(
            id: "demo-\(UUID().uuidString.prefix(8))",
            userId: "demo-user",
            programId: programId,
            duration: duration,
            startDate: dateFormatter.string(from: startDate),
            endDate: dateFormatter.string(from: endDate),
            status: .active,
            enrolledAt: dateFormatter.string(from: Date())
        )
    }

    /// Clear demo enrollment
    func clearDemoEnrollment() {
        enrolledProgram = nil
    }
}
