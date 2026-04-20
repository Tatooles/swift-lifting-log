import Foundation

enum SampleFixtures {
    static let workouts: [Workout] = [
        Workout(
            id: UUID(),
            name: "Lower Strength",
            date: Date.now.addingTimeInterval(-172_800),
            duration: 5_100,
            exercises: [
                LoggedExercise(
                    id: UUID(),
                    name: "Back Squat",
                    sets: [
                        LoggedSet(id: UUID(), repsText: "5", weightText: "315", rpe: 8.0, notes: "", isComplete: true),
                        LoggedSet(id: UUID(), repsText: "5", weightText: "315", rpe: 8.5, notes: "", isComplete: true),
                    ],
                    notes: "Stayed braced well."
                ),
                LoggedExercise(
                    id: UUID(),
                    name: "Romanian Deadlift",
                    sets: [
                        LoggedSet(id: UUID(), repsText: "8", weightText: "225", rpe: 7.5, notes: "", isComplete: true),
                        LoggedSet(id: UUID(), repsText: "8", weightText: "225", rpe: 8.0, notes: "", isComplete: true),
                    ],
                    notes: ""
                ),
            ]
        ),
        Workout(
            id: UUID(),
            name: "Upper Hypertrophy",
            date: Date.now.addingTimeInterval(-259_200),
            duration: 4_200,
            exercises: [
                LoggedExercise(
                    id: UUID(),
                    name: "Incline Dumbbell Press",
                    sets: [
                        LoggedSet(id: UUID(), repsText: "10", weightText: "70", rpe: 8.0, notes: "", isComplete: true),
                        LoggedSet(id: UUID(), repsText: "10", weightText: "70", rpe: 8.5, notes: "", isComplete: true),
                    ],
                    notes: "Last set was close to failure."
                ),
            ]
        ),
        Workout(
            id: UUID(),
            name: "Upper Strength",
            date: Date.now.addingTimeInterval(-86_400),
            duration: 4_500,
            exercises: [
                LoggedExercise(
                    id: UUID(),
                    name: "Bench Press",
                    sets: [
                        LoggedSet(id: UUID(), repsText: "5", weightText: "225", rpe: 8.0, notes: "", isComplete: true),
                        LoggedSet(id: UUID(), repsText: "5", weightText: "225", rpe: 8.5, notes: "", isComplete: true),
                    ],
                    notes: "Good bar speed."
                ),
                LoggedExercise(
                    id: UUID(),
                    name: "Weighted Pull-Up",
                    sets: [
                        LoggedSet(id: UUID(), repsText: "6", weightText: "45", rpe: 8.0, notes: "", isComplete: true),
                    ],
                    notes: ""
                ),
            ]
        ),
    ]

    static let exerciseDefinitions: [ExerciseDefinition] = [
        ExerciseDefinition(id: UUID(), name: "Bench Press"),
        ExerciseDefinition(id: UUID(), name: "Back Squat"),
        ExerciseDefinition(id: UUID(), name: "Romanian Deadlift"),
        ExerciseDefinition(id: UUID(), name: "Overhead Press"),
        ExerciseDefinition(id: UUID(), name: "Weighted Pull-Up"),
    ]
}
