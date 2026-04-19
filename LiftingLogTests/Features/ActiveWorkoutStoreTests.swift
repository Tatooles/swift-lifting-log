import XCTest
@testable import LiftingLog

final class ActiveWorkoutStoreTests: XCTestCase {
    func testExpandingExerciseCollapsesThePreviouslyExpandedExercise() throws {
        let store = MockWorkoutStore.sample
        let activeStore = ActiveWorkoutStore(store: store)
        activeStore.addExercise(named: "Bench Press")
        activeStore.addExercise(named: "Back Squat")

        let firstID = try XCTUnwrap(activeStore.draft.exercises.first?.id)
        let secondID = try XCTUnwrap(activeStore.draft.exercises.last?.id)

        activeStore.toggleExpandedExercise(firstID)
        activeStore.toggleExpandedExercise(secondID)

        XCTAssertEqual(activeStore.expandedExerciseID, secondID)
    }

    func testTappingExpandedExerciseKeepsItExpanded() throws {
        let store = MockWorkoutStore.sample
        let activeStore = ActiveWorkoutStore(store: store)
        activeStore.addExercise(named: "Bench Press")

        let exerciseID = try XCTUnwrap(activeStore.draft.exercises.first?.id)

        activeStore.toggleExpandedExercise(exerciseID)
        activeStore.toggleExpandedExercise(exerciseID)

        XCTAssertEqual(activeStore.expandedExerciseID, exerciseID)
    }

    func testUpdateWorkoutDateMutatesTheDraftDate() {
        let store = MockWorkoutStore.sample
        let originalDate = Date(timeIntervalSince1970: 2_000)
        let updatedDate = Date(timeIntervalSince1970: 5_000)
        let activeStore = ActiveWorkoutStore(store: store, now: originalDate)

        activeStore.updateWorkoutDate(updatedDate)

        XCTAssertEqual(activeStore.draft.date, updatedDate)
    }

    func testFinishWorkoutPreservesNewestFirstOrdering() {
        let store = MockWorkoutStore(
            workouts: [
                Workout(
                    id: UUID(),
                    name: "Later Workout",
                    date: Date(timeIntervalSince1970: 3_000),
                    duration: 0,
                    exercises: []
                ),
                Workout(
                    id: UUID(),
                    name: "Earlier Workout",
                    date: Date(timeIntervalSince1970: 1_000),
                    duration: 0,
                    exercises: []
                )
            ],
            recentExercises: MockWorkoutStore.sample.recentExercises
        )
        let activeStore = ActiveWorkoutStore(store: store, now: Date(timeIntervalSince1970: 2_000))
        activeStore.addExercise(named: "Bench Press")
        if let benchID = activeStore.draft.exercises.first?.id {
            activeStore.updateEditableSet(
                for: benchID,
                repsText: "5",
                weightText: "225",
                rpe: .some(8),
                notes: ""
            )
            activeStore.completePendingSet(for: benchID)
        }

        XCTAssertTrue(activeStore.finishWorkout(now: Date(timeIntervalSince1970: 2_100)))

        XCTAssertEqual(store.workouts.map(\.name), [
            "Later Workout",
            "Blank Workout",
            "Earlier Workout",
        ])
    }

    func testFinishWorkoutSkipsSavingWhenNoSetsAreComplete() throws {
        let store = MockWorkoutStore(workouts: [], recentExercises: [])
        let activeStore = ActiveWorkoutStore(store: store, now: Date(timeIntervalSince1970: 2_000))
        activeStore.addExercise(named: "Bench Press")

        let benchID = try XCTUnwrap(activeStore.draft.exercises.first?.id)
        activeStore.updateEditableSet(
            for: benchID,
            repsText: "5",
            weightText: "225",
            rpe: .some(8),
            notes: ""
        )

        XCTAssertFalse(activeStore.finishWorkout(now: Date(timeIntervalSince1970: 2_100)))
        XCTAssertNil(activeStore.finishedWorkout)
        XCTAssertTrue(store.workouts.isEmpty)
    }

    func testFinishWorkoutPersistsOnlyCompletedSets() throws {
        let store = MockWorkoutStore(workouts: [], recentExercises: [])
        let activeStore = ActiveWorkoutStore(store: store, now: Date(timeIntervalSince1970: 2_000))
        activeStore.addExercise(named: "Bench Press")
        activeStore.addExercise(named: "Deadlift")

        let benchID = try XCTUnwrap(activeStore.draft.exercises.first?.id)
        let deadliftID = try XCTUnwrap(activeStore.draft.exercises.last?.id)

        activeStore.updateEditableSet(
            for: benchID,
            repsText: "5",
            weightText: "225",
            rpe: .some(8),
            notes: ""
        )
        activeStore.completePendingSet(for: benchID)
        activeStore.updateEditableSet(
            for: benchID,
            repsText: "3",
            weightText: "245",
            rpe: .some(9),
            notes: "pending"
        )

        activeStore.updateEditableSet(
            for: deadliftID,
            repsText: "5",
            weightText: "315",
            notes: ""
        )

        XCTAssertTrue(activeStore.finishWorkout(now: Date(timeIntervalSince1970: 2_100)))

        let savedWorkout = try XCTUnwrap(activeStore.finishedWorkout)
        XCTAssertEqual(savedWorkout.exercises.map(\.name), ["Bench Press"])
        XCTAssertEqual(savedWorkout.exercises[0].sets.count, 1)
        XCTAssertTrue(savedWorkout.exercises[0].sets.allSatisfy(\.isComplete))
        XCTAssertEqual(savedWorkout.exercises[0].sets[0].weightText, "225")
    }

    func testClearingEditableSetRPERemovesThePreviousValue() throws {
        let store = MockWorkoutStore(workouts: [], recentExercises: [])
        let activeStore = ActiveWorkoutStore(store: store)
        activeStore.addExercise(named: "Bench Press")

        let benchID = try XCTUnwrap(activeStore.draft.exercises.first?.id)

        activeStore.updateEditableSet(
            for: benchID,
            repsText: "5",
            weightText: "225",
            rpe: .some(8),
            notes: ""
        )
        XCTAssertEqual(activeStore.editableSet(for: benchID).rpe, 8)

        activeStore.updateEditableSet(
            for: benchID,
            rpe: .some(nil)
        )

        XCTAssertNil(activeStore.editableSet(for: benchID).rpe)
    }

    func testAddExerciseRejectsDuplicatesIgnoringCaseAndWhitespace() {
        let store = MockWorkoutStore.sample
        let activeStore = ActiveWorkoutStore(store: store)

        activeStore.addExercise(named: "Bench Press")
        activeStore.addExercise(named: "  bench press  ")

        XCTAssertEqual(activeStore.draft.exercises.map(\.name), ["Bench Press"])
    }

    func testActiveWorkoutStoreExposesTheSharedBackingStoreSuggestions() {
        let store = MockWorkoutStore.sample
        let activeStore = ActiveWorkoutStore(store: store)

        XCTAssertEqual(
            activeStore.backingStore.recentExercises.prefix(3).map(\.name),
            store.recentExercises.prefix(3).map(\.name)
        )
    }

    func testPriorPerformanceSummaryReturnsTheMostRecentMatchingExercise() throws {
        let olderWorkout = Workout(
            id: UUID(),
            name: "Older Push",
            date: Date(timeIntervalSince1970: 1_000),
            duration: 3_600,
            exercises: [
                LoggedExercise(
                    id: UUID(),
                    name: "Bench Press",
                    sets: [
                        LoggedSet(
                            id: UUID(),
                            repsText: "5",
                            weightText: "205",
                            rpe: 8.0,
                            notes: "",
                            isComplete: true
                        )
                    ],
                    notes: ""
                )
            ]
        )
        let newerWorkout = Workout(
            id: UUID(),
            name: "Newer Push",
            date: Date(timeIntervalSince1970: 2_000),
            duration: 3_900,
            exercises: [
                LoggedExercise(
                    id: UUID(),
                    name: "Bench Press",
                    sets: [
                        LoggedSet(
                            id: UUID(),
                            repsText: "4",
                            weightText: "225",
                            rpe: 8.5,
                            notes: "Last rep slowed.",
                            isComplete: true
                        )
                    ],
                    notes: ""
                )
            ]
        )

        let activeStore = ActiveWorkoutStore(
            store: MockWorkoutStore(
                workouts: [olderWorkout, newerWorkout],
                recentExercises: []
            )
        )

        let summary = try XCTUnwrap(activeStore.priorPerformanceSummary(for: "Bench Press"))

        XCTAssertEqual(summary.workoutName, "Newer Push")
        XCTAssertEqual(summary.setSummary, "4 reps x 225")
        XCTAssertEqual(summary.rpeSummary, "RPE 8.5")
        XCTAssertEqual(summary.notePreview, "Last rep slowed.")
    }

    func testExerciseHistoryEntriesFilterToTheRequestedExerciseInNewestFirstOrder() {
        let olderWorkout = Workout(
            id: UUID(),
            name: "Upper A",
            date: Date(timeIntervalSince1970: 1_000),
            duration: 3_600,
            exercises: [
                LoggedExercise(
                    id: UUID(),
                    name: "Bench Press",
                    sets: [
                        LoggedSet(
                            id: UUID(),
                            repsText: "5",
                            weightText: "205",
                            rpe: 8.0,
                            notes: "",
                            isComplete: true
                        )
                    ],
                    notes: ""
                )
            ]
        )
        let newerWorkout = Workout(
            id: UUID(),
            name: "Upper B",
            date: Date(timeIntervalSince1970: 2_000),
            duration: 3_900,
            exercises: [
                LoggedExercise(
                    id: UUID(),
                    name: "Bench Press",
                    sets: [
                        LoggedSet(
                            id: UUID(),
                            repsText: "4",
                            weightText: "225",
                            rpe: 8.5,
                            notes: "",
                            isComplete: true
                        )
                    ],
                    notes: ""
                ),
                LoggedExercise(
                    id: UUID(),
                    name: "Weighted Pull-Up",
                    sets: [
                        LoggedSet(
                            id: UUID(),
                            repsText: "6",
                            weightText: "45",
                            rpe: 8.0,
                            notes: "",
                            isComplete: true
                        )
                    ],
                    notes: ""
                )
            ]
        )

        let activeStore = ActiveWorkoutStore(
            store: MockWorkoutStore(
                workouts: [olderWorkout, newerWorkout],
                recentExercises: []
            )
        )

        let history = activeStore.exerciseHistoryEntries(for: "Bench Press")

        XCTAssertEqual(history.map(\.workoutName), ["Upper B", "Upper A"])
        XCTAssertEqual(history.map(\.exercise.name), ["Bench Press", "Bench Press"])
    }
}
