import Foundation

struct Workout: Identifiable, Hashable {
    let id: UUID
    var name: String
    var date: Date
    var duration: TimeInterval
    var exercises: [LoggedExercise]
}

struct LoggedExercise: Identifiable, Hashable {
    let id: UUID
    var name: String
    var sets: [LoggedSet]
    var notes: String
}

struct LoggedSet: Identifiable, Hashable {
    let id: UUID
    var repsText: String
    var weightText: String
    var rpe: Double?
    var notes: String
    var isComplete: Bool
}
