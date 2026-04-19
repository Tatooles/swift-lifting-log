import Foundation

struct ActiveWorkoutDraft: Hashable {
    var name: String
    var date: Date
    var exercises: [DraftExercise]

    static func makeEmpty(now: Date = .now) -> ActiveWorkoutDraft {
        ActiveWorkoutDraft(name: "Blank Workout", date: now, exercises: [])
    }

    mutating func addExercise(named name: String) {
        exercises.append(
            DraftExercise(
                id: UUID(),
                name: name,
                loggedSets: [],
                draftSet: DraftSet()
            )
        )
    }

    mutating func updateDraftSet(
        for exerciseID: UUID,
        repsText: String,
        weightText: String,
        rpe: Double?,
        notes: String
    ) {
        guard let index = exercises.firstIndex(where: { $0.id == exerciseID }) else {
            return
        }

        let proposed = DraftSet(
            repsText: repsText,
            weightText: weightText,
            rpe: rpe,
            notes: notes
        )

        if proposed.isBlank {
            if let existingIndex = exercises[index].loggedSets.lastIndex(where: { !$0.isComplete }) {
                exercises[index].loggedSets.remove(at: existingIndex)
            }
            exercises[index].draftSet = proposed
            return
        }

        let set = LoggedSet(
            id: exercises[index].loggedSets.last(where: { !$0.isComplete })?.id ?? UUID(),
            repsText: repsText,
            weightText: weightText,
            rpe: rpe,
            notes: notes,
            isComplete: false
        )

        if let existingIndex = exercises[index].loggedSets.lastIndex(where: { !$0.isComplete }) {
            exercises[index].loggedSets[existingIndex] = set
        } else {
            exercises[index].loggedSets.append(set)
        }

        exercises[index].draftSet = DraftSet()
    }
}

struct DraftExercise: Identifiable, Hashable {
    let id: UUID
    var name: String
    var loggedSets: [LoggedSet]
    var draftSet: DraftSet
}

struct DraftSet: Hashable {
    var repsText: String = ""
    var weightText: String = ""
    var rpe: Double?
    var notes: String = ""

    var isBlank: Bool {
        repsText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && weightText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && rpe == nil
            && notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
