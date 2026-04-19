import Foundation
import Observation

@Observable
final class ActiveWorkoutStore: Identifiable {
    let id = UUID()

    let backingStore: MockWorkoutStore

    var draft: ActiveWorkoutDraft
    var expandedExerciseID: UUID?
    var startedAt: Date
    var finishedWorkout: Workout?

    var recentExercises: [ExerciseDefinition] {
        backingStore.recentExercises
    }

    var exerciseHistory: [ExerciseDefinition] {
        backingStore.exerciseHistory
    }

    var canFinishWorkout: Bool {
        draft.exercises.contains { exercise in
            exercise.loggedSets.contains(where: \.isComplete)
        }
    }

    init(store: MockWorkoutStore, now: Date = .now) {
        self.backingStore = store
        self.draft = .makeEmpty(now: now)
        self.startedAt = now
    }

    @discardableResult
    func addExercise(named name: String) -> Bool {
        let normalizedName = Self.normalizeExerciseName(name)
        guard !normalizedName.isEmpty else {
            return false
        }

        guard !draft.exercises.contains(where: {
            Self.normalizeExerciseName($0.name) == normalizedName
        }) else {
            return false
        }

        draft.addExercise(named: name.trimmingCharacters(in: .whitespacesAndNewlines))
        expandedExerciseID = draft.exercises.last?.id
        return true
    }

    func removeExercise(_ id: UUID) {
        draft.exercises.removeAll { $0.id == id }

        if expandedExerciseID == id {
            expandedExerciseID = draft.exercises.last?.id
        }
    }

    func toggleExpandedExercise(_ id: UUID) {
        expandedExerciseID = id
    }

    func updateWorkoutDate(_ date: Date) {
        draft.date = date
    }

    func editableSet(for exerciseID: UUID) -> DraftSet {
        guard let exercise = draft.exercises.first(where: { $0.id == exerciseID }) else {
            return DraftSet()
        }

        if let pendingSet = exercise.loggedSets.last(where: { !$0.isComplete }) {
            return DraftSet(
                repsText: pendingSet.repsText,
                weightText: pendingSet.weightText,
                rpe: pendingSet.rpe,
                notes: pendingSet.notes
            )
        }

        return exercise.draftSet
    }

    func completedSets(for exerciseID: UUID) -> [LoggedSet] {
        draft.exercises
            .first(where: { $0.id == exerciseID })?
            .loggedSets
            .filter(\.isComplete) ?? []
    }

    func exerciseHistoryEntries(for exerciseName: String) -> [ExerciseHistoryEntry] {
        let normalizedName = Self.normalizeExerciseName(exerciseName)

        return backingStore.workouts.compactMap { workout in
            guard let exercise = workout.exercises.first(where: {
                Self.normalizeExerciseName($0.name) == normalizedName
            }) else {
                return nil
            }

            return ExerciseHistoryEntry(
                workoutID: workout.id,
                workoutName: workout.name,
                date: workout.date,
                duration: workout.duration,
                exercise: exercise
            )
        }
    }

    func priorPerformanceSummary(for exerciseName: String) -> ExercisePerformanceSummary? {
        guard let entry = exerciseHistoryEntries(for: exerciseName).first,
              let set = entry.exercise.sets.last ?? entry.exercise.sets.first
        else {
            return nil
        }

        let notePreview: String? = if !set.notes.isEmpty {
            set.notes
        } else if !entry.exercise.notes.isEmpty {
            entry.exercise.notes
        } else {
            nil
        }

        return ExercisePerformanceSummary(
            workoutName: entry.workoutName,
            date: entry.date,
            setSummary: Self.setSummary(for: set),
            rpeSummary: set.rpe.map {
                "RPE \($0.formatted(.number.precision(.fractionLength(1))))"
            },
            notePreview: notePreview
        )
    }

    func updateEditableSet(
        for exerciseID: UUID,
        repsText: String? = nil,
        weightText: String? = nil,
        rpe: Double?? = nil,
        notes: String? = nil
    ) {
        let current = editableSet(for: exerciseID)

        draft.updateDraftSet(
            for: exerciseID,
            repsText: repsText ?? current.repsText,
            weightText: weightText ?? current.weightText,
            rpe: rpe ?? current.rpe,
            notes: notes ?? current.notes
        )
    }

    func completePendingSet(for exerciseID: UUID) {
        guard let exerciseIndex = draft.exercises.firstIndex(where: { $0.id == exerciseID }),
              let setIndex = draft.exercises[exerciseIndex].loggedSets.lastIndex(where: { !$0.isComplete })
        else {
            return
        }

        draft.exercises[exerciseIndex].loggedSets[setIndex].isComplete = true
    }

    @discardableResult
    func finishWorkout(now: Date = .now) -> Bool {
        guard finishedWorkout == nil, canFinishWorkout else {
            return false
        }

        let completedExercises = draft.exercises.compactMap { exercise -> LoggedExercise? in
            let completedSets = exercise.loggedSets.filter(\.isComplete)
            guard !completedSets.isEmpty else {
                return nil
            }

            return LoggedExercise(
                id: exercise.id,
                name: exercise.name,
                sets: completedSets,
                notes: ""
            )
        }

        guard !completedExercises.isEmpty else {
            return false
        }

        let savedWorkout = Workout(
            id: UUID(),
            name: draft.name,
            date: draft.date,
            duration: now.timeIntervalSince(startedAt),
            exercises: completedExercises
        )

        backingStore.insertWorkout(savedWorkout)
        finishedWorkout = savedWorkout
        return true
    }

    private static func normalizeExerciseName(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private static func setSummary(for set: LoggedSet) -> String {
        let reps = set.repsText.isEmpty ? "?" : set.repsText

        guard !set.weightText.isEmpty else {
            return "\(reps) reps"
        }

        return "\(reps) reps x \(set.weightText)"
    }
}

extension ActiveWorkoutStore: Hashable {
    static func == (lhs: ActiveWorkoutStore, rhs: ActiveWorkoutStore) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ExerciseHistoryEntry: Identifiable, Hashable {
    let workoutID: UUID
    let workoutName: String
    let date: Date
    let duration: TimeInterval
    let exercise: LoggedExercise

    var id: UUID { workoutID }
}

struct ExercisePerformanceSummary: Hashable {
    let workoutName: String
    let date: Date
    let setSummary: String
    let rpeSummary: String?
    let notePreview: String?
}
