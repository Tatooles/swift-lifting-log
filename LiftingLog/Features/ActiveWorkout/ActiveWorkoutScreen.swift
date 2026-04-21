import SwiftUI

struct ActiveWorkoutScreen: View {
    let store: ActiveWorkoutStore
    let onFinish: () -> Void

    @State private var isExercisePickerPresented = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard

                if store.draft.exercises.isEmpty {
                    emptyState
                } else {
                    ForEach(store.draft.exercises) { exercise in
                        ExerciseCardView(store: store, exercise: exercise)
                    }
                }
            }
            .padding(.horizontal, AppTheme.screenPadding)
            .padding(.top, 8)
            .padding(.bottom, 112)
        }
        .background(AppTheme.pageBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .top) {
            sessionBar
        }
        .safeAreaInset(edge: .bottom) {
            bottomBar
        }
        .sheet(isPresented: $isExercisePickerPresented) {
            ExercisePickerSheet(store: store)
                .presentationDetents([.medium, .large])
        }
    }

    private var workoutNameBinding: Binding<String> {
        Binding(
            get: { store.draft.name },
            set: { store.draft.name = $0 }
        )
    }

    private var workoutDateBinding: Binding<Date> {
        Binding(
            get: { store.draft.date },
            set: { store.updateWorkoutDate($0) }
        )
    }

    private var headerCard: some View {
        GlassSurface(cornerRadius: 32, padding: 22) {
            VStack(alignment: .leading, spacing: 16) {
                TextField("Workout Name", text: workoutNameBinding)
                    .font(.largeTitle.weight(.bold))
                    .textInputAutocapitalization(.words)

                HStack(spacing: 10) {
                    DatePicker(
                        selection: workoutDateBinding,
                        displayedComponents: [.date]
                    ) {
                        Label(
                            store.draft.date.formatted(date: .abbreviated, time: .omitted),
                            systemImage: "calendar"
                        )
                    }
                    .datePickerStyle(.compact)

                    MetadataPill(
                        title: "\(store.draft.exercises.count) exercises",
                        systemImage: "figure.strengthtraining.traditional"
                    )
                }
            }
        }
    }

    private var emptyState: some View {
        GlassSurface(cornerRadius: 28, padding: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Label("Add your first exercise", systemImage: "list.bullet.clipboard")
                    .font(.headline)

                Text("Pick from recent movements or type a new exercise name on the fly.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    isExercisePickerPresented = true
                } label: {
                    Label("Choose Exercise", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.accent)
            }
        }
    }

    private var sessionBar: some View {
        HStack(spacing: 12) {
            WorkoutTimerBar(startedAt: store.startedAt)

            Text(completedExerciseSummary)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .frame(maxWidth: .infinity, alignment: .center)

            Button("Finish") {
                finishWorkout()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .tint(AppTheme.accent)
            .disabled(!store.canFinishWorkout)
        }
        .padding(.horizontal, AppTheme.screenPadding)
        .padding(.top, 8)
        .padding(.bottom, 10)
        .background(.bar)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    private var bottomBar: some View {
        Button {
            isExercisePickerPresented = true
        } label: {
            Label("Add Exercise", systemImage: "plus")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .padding(.horizontal, AppTheme.screenPadding)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .background(.bar)
    }

    private var completedExerciseSummary: String {
        let count = store.completedExerciseCount
        let noun = count == 1 ? "exercise" : "exercises"
        return "\(count) \(noun) completed"
    }

    private func finishWorkout() {
        if store.finishWorkout() {
            onFinish()
        }
    }
}

#Preview("Empty Workout") {
    NavigationStack {
        ActiveWorkoutScreen(store: activeWorkoutEmptyPreviewStore(), onFinish: {})
    }
}

#Preview("In Progress") {
    NavigationStack {
        ActiveWorkoutScreen(store: activeWorkoutFilledPreviewStore(), onFinish: {})
    }
}

private func activeWorkoutEmptyPreviewStore() -> ActiveWorkoutStore {
    ActiveWorkoutStore(store: .sample, now: SampleFixtures.workouts[0].date)
}

private func activeWorkoutFilledPreviewStore() -> ActiveWorkoutStore {
    let store = ActiveWorkoutStore(store: .sample, now: SampleFixtures.workouts[0].date)

    store.draft.name = "Push Day"
    store.addExercise(named: "Bench Press")
    if let benchPressID = store.draft.exercises.first?.id {
        store.updateEditableSet(
            for: benchPressID,
            repsText: "5",
            weightText: "225",
            rpe: .some(8.0),
            notes: ""
        )
        store.completePendingSet(for: benchPressID)
        store.updateEditableSet(
            for: benchPressID,
            repsText: "5",
            weightText: "225",
            rpe: .some(8.5),
            notes: "Moved cleanly."
        )
        store.completePendingSet(for: benchPressID)
    }

    store.addExercise(named: "Weighted Pull-Up")
    if let pullUpID = store.draft.exercises.last?.id {
        store.updateEditableSet(
            for: pullUpID,
            repsText: "6",
            weightText: "45",
            rpe: .some(8.0),
            notes: ""
        )
        store.completePendingSet(for: pullUpID)
        store.updateEditableSet(
            for: pullUpID,
            repsText: "6",
            weightText: "45",
            rpe: .some(8.5),
            notes: "One rep left."
        )
        store.toggleExpandedExercise(pullUpID)
    }

    return store
}
