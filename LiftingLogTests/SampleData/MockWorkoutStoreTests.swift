import XCTest
@testable import LiftingLog

final class MockWorkoutStoreTests: XCTestCase {
    func testWorkoutHistoryIsSortedNewestFirst() {
        let store = makeStore()

        let dates = store.workouts.map(\.date)
        XCTAssertEqual(dates, dates.sorted(by: >))
    }

    func testRecentExerciseSuggestionsAreUniqueAndOrdered() {
        let store = makeStore()

        XCTAssertEqual(store.recentExercises.prefix(3).map(\.name), [
            "Bench Press",
            "Back Squat",
            "Romanian Deadlift",
        ])
    }

    func testExerciseHistoryIsDerivedFromLoggedWorkouts() {
        let store = makeStore()

        XCTAssertEqual(store.exerciseHistory.map(\.name), [
            "Bench Press",
            "Weighted Pull-Up",
            "Back Squat",
            "Romanian Deadlift",
            "Incline Dumbbell Press",
        ])
    }

    private func makeStore() -> MockWorkoutStore {
        MockWorkoutStore.sample
    }
}
