import SwiftUI

struct ExercisePickerSheet: View {
    let store: ActiveWorkoutStore

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var suggestions: ExercisePickerSuggestions {
        ExercisePickerSuggestions.build(
            recentExercises: store.recentExercises,
            exerciseHistory: store.exerciseHistory,
            existingExerciseNames: store.draft.exercises.map(\.name),
            searchText: searchText
        )
    }

    var body: some View {
        NavigationStack {
            List {
                if let customExerciseName = suggestions.customExerciseName {
                    Section {
                        Button {
                            selectExercise(named: customExerciseName)
                        } label: {
                            Label("Add \"\(customExerciseName)\"", systemImage: "plus.circle.fill")
                        }
                    }
                }

                if !suggestions.recentExercises.isEmpty {
                    Section("Recent Exercises") {
                        ForEach(suggestions.recentExercises) { exercise in
                            selectionButton(for: exercise)
                        }
                    }
                }

                if !suggestions.matchingExercises.isEmpty {
                    Section(searchText.isEmpty ? "More Exercises" : "Matches") {
                        ForEach(suggestions.matchingExercises) { exercise in
                            selectionButton(for: exercise)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search or add exercise")
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func selectionButton(for exercise: ExerciseDefinition) -> some View {
        Button {
            selectExercise(named: exercise.name)
        } label: {
            Text(exercise.name)
        }
    }

    private func selectExercise(named name: String) {
        if store.addExercise(named: name) {
            dismiss()
        }
    }
}

struct ExercisePickerSuggestions {
    let recentExercises: [ExerciseDefinition]
    let matchingExercises: [ExerciseDefinition]
    let customExerciseName: String?

    static func build(
        recentExercises: [ExerciseDefinition],
        exerciseHistory: [ExerciseDefinition],
        existingExerciseNames: [String],
        searchText: String
    ) -> ExercisePickerSuggestions {
        let existingNames = Set(existingExerciseNames.map(Self.normalize))
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedQuery = Self.normalize(query)

        let availableRecent = uniqueExercises(
            from: recentExercises.filter { !existingNames.contains(Self.normalize($0.name)) }
        )

        let availableHistory = uniqueExercises(
            from: exerciseHistory.filter { !existingNames.contains(Self.normalize($0.name)) }
        )

        let filteredRecent = query.isEmpty
            ? availableRecent
            : availableRecent.filter { Self.normalize($0.name).contains(normalizedQuery) }

        let filteredHistory = (query.isEmpty ? availableHistory : availableHistory.filter {
            Self.normalize($0.name).contains(normalizedQuery)
        })
        .filter { historyExercise in
            !filteredRecent.contains(where: { Self.normalize($0.name) == Self.normalize(historyExercise.name) })
        }

        let exactMatchExists = filteredRecent.contains(where: { Self.normalize($0.name) == normalizedQuery })
            || filteredHistory.contains(where: { Self.normalize($0.name) == normalizedQuery })
            || existingNames.contains(normalizedQuery)
            || availableRecent.contains(where: { Self.normalize($0.name) == normalizedQuery })
            || availableHistory.contains(where: { Self.normalize($0.name) == normalizedQuery })

        return ExercisePickerSuggestions(
            recentExercises: filteredRecent,
            matchingExercises: filteredHistory,
            customExerciseName: query.isEmpty || exactMatchExists ? nil : query
        )
    }

    private static func uniqueExercises(from exercises: [ExerciseDefinition]) -> [ExerciseDefinition] {
        var seen = Set<String>()

        return exercises.filter { exercise in
            seen.insert(normalize(exercise.name)).inserted
        }
    }

    private static func normalize(_ name: String) -> String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

#Preview {
    ExercisePickerSheet(store: ActiveWorkoutStore(store: .sample))
}
