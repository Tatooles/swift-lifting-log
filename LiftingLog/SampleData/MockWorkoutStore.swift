import Foundation
import Observation

@Observable
final class MockWorkoutStore {
    var workouts: [Workout] {
        didSet {
            exerciseHistory = Self.makeExerciseHistory(from: workouts)
        }
    }

    var recentExercises: [ExerciseDefinition]
    private(set) var exerciseHistory: [ExerciseDefinition]

    init(workouts: [Workout], recentExercises: [ExerciseDefinition]) {
        let sortedWorkouts = workouts.sorted { $0.date > $1.date }

        self.workouts = sortedWorkouts
        self.recentExercises = recentExercises
        self.exerciseHistory = Self.makeExerciseHistory(from: sortedWorkouts)
    }

    func insertWorkout(_ workout: Workout) {
        workouts.append(workout)
        workouts.sort { $0.date > $1.date }
    }

    static var sample: MockWorkoutStore {
        MockWorkoutStore(
            workouts: SampleFixtures.workouts,
            recentExercises: SampleFixtures.exerciseDefinitions
        )
    }

    private static func makeExerciseHistory(from workouts: [Workout]) -> [ExerciseDefinition] {
        var seenExerciseNames = Set<String>()
        var exerciseHistory: [ExerciseDefinition] = []

        for workout in workouts {
            for exercise in workout.exercises where seenExerciseNames.insert(exercise.name).inserted {
                exerciseHistory.append(
                    ExerciseDefinition(id: UUID(), name: exercise.name)
                )
            }
        }

        return exerciseHistory
    }
}
