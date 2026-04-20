import XCTest
@testable import LiftingLog

final class LiftingLogTests: XCTestCase {
    func testHostedAppBundleHasExpectedIdentifier() throws {
        let hostedAppBundle = try XCTUnwrap(
            Bundle.allBundles.first { $0.bundleIdentifier == "com.kevintatooles.LiftingLog" },
            "Expected the app host bundle to be loaded alongside the test bundle"
        )

        XCTAssertEqual(hostedAppBundle.bundleIdentifier, "com.kevintatooles.LiftingLog")
        XCTAssertEqual(hostedAppBundle.executableURL?.lastPathComponent, "LiftingLog")
    }
}

final class StartWorkoutFlowStateTests: XCTestCase {
    func testCompletingWorkoutTransitionsFromActiveFlowToCompletionState() throws {
        let flowState = StartWorkoutFlowState()
        let store = MockWorkoutStore(workouts: [], recentExercises: [])

        flowState.beginBlankWorkout(in: store)
        let activeWorkoutStore = try XCTUnwrap(flowState.activeWorkoutStore)

        activeWorkoutStore.addExercise(named: "Bench Press")
        let exerciseID = try XCTUnwrap(activeWorkoutStore.draft.exercises.first?.id)
        activeWorkoutStore.updateEditableSet(
            for: exerciseID,
            repsText: "5",
            weightText: "225",
            rpe: .some(8)
        )
        activeWorkoutStore.updateExerciseNotes(for: exerciseID, notes: "Moved well.")
        activeWorkoutStore.completePendingSet(for: exerciseID)
        XCTAssertTrue(activeWorkoutStore.finishWorkout(now: Date(timeIntervalSince1970: 2_100)))

        flowState.showCompletion(for: activeWorkoutStore)

        XCTAssertNil(flowState.activeWorkoutStore)
        XCTAssertEqual(flowState.completedWorkout?.name, "Blank Workout")
        XCTAssertEqual(flowState.completedWorkout?.exercises.first?.notes, "Moved well.")
    }
}

final class WorkoutDetailDisplayTests: XCTestCase {
    func testWeightOnlySetUsesFallbackRepsText() {
        let set = LoggedSet(
            id: UUID(),
            repsText: "",
            weightText: "225",
            rpe: nil,
            notes: "",
            isComplete: true
        )

        XCTAssertEqual(set.repsDisplayText, "? reps")
    }
}

final class RPETextMapperTests: XCTestCase {
    func testFormatsRPEForFieldDisplay() {
        XCTAssertEqual(RPETextMapper.text(for: 8.5), "8.5")
        XCTAssertEqual(RPETextMapper.text(for: 8.0), "8")
        XCTAssertEqual(RPETextMapper.text(for: nil), "")
    }

    func testParsesBlankOrInvalidTextAsNil() {
        XCTAssertNil(RPETextMapper.value(from: ""))
        XCTAssertNil(RPETextMapper.value(from: "  "))
        XCTAssertNil(RPETextMapper.value(from: "abc"))
    }

    func testParsesDecimalRPEText() {
        XCTAssertEqual(RPETextMapper.value(from: "8.5"), 8.5)
        XCTAssertEqual(RPETextMapper.value(from: "9"), 9.0)
    }
}
