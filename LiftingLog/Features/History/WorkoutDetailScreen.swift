import SwiftUI

struct WorkoutDetailScreen: View {
    let workout: Workout

    var body: some View {
        List {
            Section {
                LabeledContent("Workout", value: workout.name)
                LabeledContent(
                    "Date",
                    value: workout.date.formatted(date: .abbreviated, time: .omitted)
                )
                LabeledContent("Duration", value: workout.durationText)
            }

            ForEach(workout.exercises) { exercise in
                Section(exercise.name) {
                    ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                        LoggedSetRow(setNumber: index + 1, set: set)
                    }

                    if !exercise.notes.isEmpty {
                        LabeledContent("Notes") {
                            Text(exercise.notes)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(workout.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LoggedSetRow: View {
    let setNumber: Int
    let set: LoggedSet

    var body: some View {
        let weightText = set.weightText.trimmingCharacters(in: .whitespacesAndNewlines)

        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Set \(setNumber)")
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Text(set.repsDisplayText)
                if !weightText.isEmpty {
                    Text("•")
                    Text(weightText)
                }
            }
            .font(.subheadline)

            if let rpe = set.rpe {
                Text("RPE \(rpe.formatted(.number.precision(.fractionLength(1))))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if !set.notes.isEmpty {
                Text(set.notes)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

extension LoggedSet {
    var repsDisplayText: String {
        let trimmedReps = repsText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedReps.isEmpty else {
            return "? reps"
        }

        return "\(trimmedReps) reps"
    }
}

#Preview("Workout Detail") {
    NavigationStack {
        WorkoutDetailScreen(workout: SampleFixtures.workouts[0])
    }
}
