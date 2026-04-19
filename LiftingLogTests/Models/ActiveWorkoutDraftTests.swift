import XCTest
@testable import LiftingLog

final class ActiveWorkoutDraftTests: XCTestCase {
    func testMaterializesDraftSetWhenWeightIsEntered() throws {
        var draft = ActiveWorkoutDraft.makeEmpty()
        draft.addExercise(named: "Bench Press")
        let exerciseID = try XCTUnwrap(draft.exercises.first?.id)

        draft.updateDraftSet(
            for: exerciseID,
            repsText: "",
            weightText: "225",
            rpe: nil,
            notes: ""
        )

        XCTAssertEqual(draft.exercises[0].loggedSets.count, 1)
        XCTAssertEqual(draft.exercises[0].loggedSets[0].weightText, "225")
        XCTAssertFalse(draft.exercises[0].loggedSets[0].isComplete)
        XCTAssertEqual(draft.exercises[0].draftSet.weightText, "")
    }

    func testUpdatesTheMaterializedDraftSetInsteadOfAppendingAnotherOne() throws {
        var draft = ActiveWorkoutDraft.makeEmpty()
        draft.addExercise(named: "Bench Press")
        let exerciseID = try XCTUnwrap(draft.exercises.first?.id)

        draft.updateDraftSet(
            for: exerciseID,
            repsText: "",
            weightText: "225",
            rpe: nil,
            notes: ""
        )

        let firstSetID = try XCTUnwrap(draft.exercises[0].loggedSets.first?.id)

        draft.updateDraftSet(
            for: exerciseID,
            repsText: "5",
            weightText: "225",
            rpe: 8,
            notes: "top set"
        )

        XCTAssertEqual(draft.exercises[0].loggedSets.count, 1)
        XCTAssertEqual(draft.exercises[0].loggedSets[0].id, firstSetID)
        XCTAssertEqual(draft.exercises[0].loggedSets[0].repsText, "5")
        XCTAssertEqual(draft.exercises[0].loggedSets[0].weightText, "225")
        XCTAssertEqual(draft.exercises[0].loggedSets[0].rpe, 8)
        XCTAssertEqual(draft.exercises[0].loggedSets[0].notes, "top set")
        XCTAssertFalse(draft.exercises[0].loggedSets[0].isComplete)
    }

    func testLeavesBlankDraftSetUnpersisted() throws {
        var draft = ActiveWorkoutDraft.makeEmpty()
        draft.addExercise(named: "Squat")
        let exerciseID = try XCTUnwrap(draft.exercises.first?.id)

        draft.updateDraftSet(
            for: exerciseID,
            repsText: "",
            weightText: "",
            rpe: nil,
            notes: ""
        )

        XCTAssertTrue(draft.exercises[0].loggedSets.isEmpty)
    }

    func testRemovesMaterializedDraftSetWhenClearedBackToBlank() throws {
        var draft = ActiveWorkoutDraft.makeEmpty()
        draft.addExercise(named: "Deadlift")
        let exerciseID = try XCTUnwrap(draft.exercises.first?.id)

        draft.updateDraftSet(
            for: exerciseID,
            repsText: "3",
            weightText: "315",
            rpe: 9,
            notes: "top set"
        )

        let materializedSetID = try XCTUnwrap(draft.exercises[0].loggedSets.first?.id)

        draft.updateDraftSet(
            for: exerciseID,
            repsText: "",
            weightText: "",
            rpe: nil,
            notes: ""
        )

        XCTAssertTrue(draft.exercises[0].loggedSets.isEmpty)
        XCTAssertNil(draft.exercises[0].loggedSets.first(where: { $0.id == materializedSetID }))
    }

    func testTreatsWhitespaceOnlyFieldsAsBlankDraftInput() throws {
        var draft = ActiveWorkoutDraft.makeEmpty()
        draft.addExercise(named: "Press")
        let exerciseID = try XCTUnwrap(draft.exercises.first?.id)

        draft.updateDraftSet(
            for: exerciseID,
            repsText: "   ",
            weightText: "  ",
            rpe: nil,
            notes: "   "
        )

        XCTAssertTrue(draft.exercises[0].loggedSets.isEmpty)
    }
}
