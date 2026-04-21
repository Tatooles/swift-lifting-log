import SwiftUI

struct ExerciseCardPresentation {
    let headerMetadataTitles: [String]
    let priorPerformanceHistoryTitle: String?
    let bottomActionTitles: [String]

    init(
        completedSetCount: Int,
        editableSetIsBlank: Bool,
        hasHistory: Bool
    ) {
        if editableSetIsBlank {
            headerMetadataTitles = []
        } else {
            headerMetadataTitles = ["Editing set \(completedSetCount + 1)"]
        }

        priorPerformanceHistoryTitle = hasHistory ? "Full History" : nil
        bottomActionTitles = ["Log Set", "Remove"]
    }
}

struct ExerciseCardView: View {
    let store: ActiveWorkoutStore
    let exercise: DraftExercise

    @State private var isHistoryPresented = false

    private var isExpanded: Bool {
        store.expandedExerciseID == exercise.id
    }

    private var completedSets: [LoggedSet] {
        store.completedSets(for: exercise.id)
    }

    private var editableSet: DraftSet {
        store.editableSet(for: exercise.id)
    }

    private var priorPerformanceSummary: ExercisePerformanceSummary? {
        store.priorPerformanceSummary(for: exercise.name)
    }

    private var historyEntries: [ExerciseHistoryEntry] {
        store.exerciseHistoryEntries(for: exercise.name)
    }

    private var presentation: ExerciseCardPresentation {
        ExerciseCardPresentation(
            completedSetCount: completedSets.count,
            editableSetIsBlank: editableSet.isBlank,
            hasHistory: !historyEntries.isEmpty
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            if isExpanded {
                expandedContent
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color(.separator).opacity(0.22), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.04), radius: 10, y: 4)
        .animation(.spring(response: 0.32, dampingFraction: 0.84), value: isExpanded)
        .sheet(isPresented: $isHistoryPresented) {
            NavigationStack {
                ExerciseHistoryDetailScreen(exerciseName: exercise.name, entries: historyEntries)
            }
        }
    }

    private var header: some View {
        Button {
            store.toggleExpandedExercise(exercise.id)
        } label: {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(exercise.name)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.leading)

                    if !presentation.headerMetadataTitles.isEmpty {
                        HStack(spacing: 8) {
                            ForEach(presentation.headerMetadataTitles, id: \.self) { title in
                                MetadataPill(
                                    title: title,
                                    systemImage: "square.and.pencil"
                                )
                            }
                        }
                    }
                }

                Spacer()

                Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                    .font(.title3)
                    .foregroundStyle(AppTheme.accent)
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            priorPerformanceStrip

            ForEach(Array(completedSets.enumerated()), id: \.element.id) { index, set in
                SetRowView(
                    setNumber: index + 1,
                    repsText: set.repsText,
                    weightText: set.weightText,
                    rpe: set.rpe,
                    isEditable: false
                )
            }

            SetRowView(
                setNumber: completedSets.count + 1,
                repsText: editableSet.repsText,
                weightText: editableSet.weightText,
                rpe: editableSet.rpe,
                isEditable: true,
                onRepsChange: { updateEditableSet(repsText: $0) },
                onWeightChange: { updateEditableSet(weightText: $0) },
                onRPEChange: { updateEditableSet(rpe: .some($0)) }
            )

            exerciseNotesField

            HStack(spacing: 8) {
                Button {
                    store.completePendingSet(for: exercise.id)
                } label: {
                    Text(presentation.bottomActionTitles[0])
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
                .disabled(editableSet.isBlank)

                Button(presentation.bottomActionTitles[1], role: .destructive) {
                    store.removeExercise(exercise.id)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
    }

    private func updateEditableSet(
        repsText: String? = nil,
        weightText: String? = nil,
        rpe: Double?? = nil
    ) {
        store.updateEditableSet(
            for: exercise.id,
            repsText: repsText,
            weightText: weightText,
            rpe: rpe
        )
    }

    private var exerciseNotesField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Notes")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField(
                "Exercise notes",
                text: Binding(
                    get: { exercise.notes },
                    set: { store.updateExerciseNotes(for: exercise.id, notes: $0) }
                ),
                axis: .vertical
            )
            .lineLimit(1 ... 3)
            .textInputAutocapitalization(.sentences)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(Color(.separator).opacity(0.18), lineWidth: 1)
            )
        }
    }

    @ViewBuilder
    private var priorPerformanceStrip: some View {
        if let priorPerformanceSummary {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top, spacing: 8) {
                    Label("Prior Performance", systemImage: "clock.badge.checkmark")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    Spacer()

                    if let title = presentation.priorPerformanceHistoryTitle {
                        Button(title) {
                            isHistoryPresented = true
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }

                Text(priorPerformanceSummary.setSummary)
                    .font(.headline)

                HStack(spacing: 8) {
                    Text(priorPerformanceSummary.workoutName)
                    Text("•")
                    Text(priorPerformanceSummary.date.formatted(date: .abbreviated, time: .omitted))
                    if let rpeSummary = priorPerformanceSummary.rpeSummary {
                        Text("•")
                        Text(rpeSummary)
                    }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)

                if let notePreview = priorPerformanceSummary.notePreview {
                    Text(notePreview)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.systemBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(Color(.separator).opacity(0.18), lineWidth: 1)
            )
        } else {
            Label("No previous history for this exercise yet.", systemImage: "clock.arrow.circlepath")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(.systemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color(.separator).opacity(0.18), lineWidth: 1)
                )
        }
    }
}

#Preview {
    let store = ActiveWorkoutStore(store: .sample)
    store.addExercise(named: "Bench Press")
    if let exercise = store.draft.exercises.first {
        store.toggleExpandedExercise(exercise.id)

        return ExerciseCardView(store: store, exercise: exercise)
            .padding()
            .background(AppTheme.pageBackground)
    }

    return Color.clear
}

private struct ExerciseHistoryDetailScreen: View {
    let exerciseName: String
    let entries: [ExerciseHistoryEntry]

    var body: some View {
        List {
            ForEach(entries) { entry in
                Section {
                    LabeledContent(
                        "Date",
                        value: entry.date.formatted(date: .abbreviated, time: .omitted)
                    )
                    LabeledContent("Workout", value: entry.workoutName)
                    LabeledContent("Duration", value: entry.durationText)

                    ForEach(Array(entry.exercise.sets.enumerated()), id: \.element.id) { index, set in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Set \(index + 1)")
                                    .font(.subheadline.weight(.semibold))

                                Spacer()

                                Text(setSummary(for: set))
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

                    if !entry.exercise.notes.isEmpty {
                        LabeledContent("Exercise Notes") {
                            Text(entry.exercise.notes)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle(exerciseName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func setSummary(for set: LoggedSet) -> String {
        let reps = set.repsText.isEmpty ? "?" : set.repsText

        guard !set.weightText.isEmpty else {
            return "\(reps) reps"
        }

        return "\(reps) reps x \(set.weightText)"
    }
}

private extension ExerciseHistoryEntry {
    var durationText: String {
        Duration.seconds(duration).formatted(
            .units(allowed: [.hours, .minutes], maximumUnitCount: 2)
        )
    }
}
