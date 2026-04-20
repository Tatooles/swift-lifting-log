import XCTest
@testable import LiftingLog

final class ExercisePickerSuggestionsTests: XCTestCase {
    func testReturnsRecentExercisesExcludingAlreadyAddedOnes() {
        let suggestions = ExercisePickerSuggestions.build(
            recentExercises: [
                ExerciseDefinition(id: UUID(), name: "Bench Press"),
                ExerciseDefinition(id: UUID(), name: "Back Squat"),
                ExerciseDefinition(id: UUID(), name: "Romanian Deadlift"),
            ],
            exerciseHistory: [
                ExerciseDefinition(id: UUID(), name: "Bench Press"),
                ExerciseDefinition(id: UUID(), name: "Pendlay Row"),
            ],
            existingExerciseNames: ["Bench Press"],
            searchText: ""
        )

        XCTAssertEqual(suggestions.recentExercises.map(\.name), [
            "Back Squat",
            "Romanian Deadlift",
        ])
        XCTAssertEqual(suggestions.matchingExercises.map(\.name), [
            "Pendlay Row",
        ])
        XCTAssertNil(suggestions.customExerciseName)
    }

    func testOffersCustomExerciseWhenSearchHasNoExactMatch() {
        let suggestions = ExercisePickerSuggestions.build(
            recentExercises: [
                ExerciseDefinition(id: UUID(), name: "Bench Press"),
            ],
            exerciseHistory: [
                ExerciseDefinition(id: UUID(), name: "Back Squat"),
            ],
            existingExerciseNames: [],
            searchText: "Cable Fly"
        )

        XCTAssertEqual(suggestions.matchingExercises.map(\.name), [])
        XCTAssertEqual(suggestions.customExerciseName, "Cable Fly")
    }

    func testDoesNotOfferCustomExerciseForExistingWorkoutExercise() {
        let suggestions = ExercisePickerSuggestions.build(
            recentExercises: [
                ExerciseDefinition(id: UUID(), name: "Incline Press"),
            ],
            exerciseHistory: [
                ExerciseDefinition(id: UUID(), name: "Cable Fly"),
            ],
            existingExerciseNames: [" Bench Press "],
            searchText: "bench press"
        )

        XCTAssertEqual(suggestions.recentExercises.map(\.name), [])
        XCTAssertEqual(suggestions.matchingExercises.map(\.name), [])
        XCTAssertNil(suggestions.customExerciseName)
    }
}
