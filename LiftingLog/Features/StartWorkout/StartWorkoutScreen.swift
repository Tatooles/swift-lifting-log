import SwiftUI
import Observation

struct StartWorkoutScreen: View {
    let store: MockWorkoutStore

    @State private var flowState = StartWorkoutFlowState()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                startBlankWorkoutButton

                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Workouts")
                        .font(.headline)

                    Text("Use these recent sessions as inspiration for what to train today.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if store.workouts.isEmpty {
                        ContentUnavailableView(
                            "No Recent Workouts",
                            systemImage: "figure.strengthtraining.traditional",
                            description: Text("Completed sessions will show up here.")
                        )
                        .frame(maxWidth: .infinity)
                        .padding(.top, 12)
                    } else {
                        ForEach(Array(store.workouts.prefix(3))) { workout in
                            RecentWorkoutCard(workout: workout)
                        }
                    }
                }
            }
            .padding(AppTheme.screenPadding)
        }
        .background(AppTheme.pageBackground.ignoresSafeArea())
        .navigationTitle("Start Workout")
        .navigationDestination(item: activeWorkoutBinding) { activeWorkoutStore in
            ActiveWorkoutScreen(store: activeWorkoutStore) {
                flowState.showCompletion(for: activeWorkoutStore)
            }
        }
        .sheet(item: completedWorkoutBinding) { workout in
            NavigationStack {
                WorkoutCompletionScreen(workout: workout)
            }
        }
    }

    private var startBlankWorkoutButton: some View {
        Button(action: beginBlankWorkout) {
            VStack(alignment: .leading, spacing: 14) {
                Label("Start Blank Workout", systemImage: "plus.circle.fill")
                    .font(.title3.weight(.semibold))

                Text("Jump into a fresh session with the full active workout editor, sticky timer, and inline set logging.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.88))
                    .multilineTextAlignment(.leading)

                HStack {
                    Text("New workout")
                        .font(.footnote.weight(.semibold))

                    Spacer()

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                }
                .foregroundStyle(.white.opacity(0.95))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(AppTheme.accent.gradient)
            )
        }
        .buttonStyle(.plain)
    }

    private var activeWorkoutBinding: Binding<ActiveWorkoutStore?> {
        Binding(
            get: { flowState.activeWorkoutStore },
            set: { flowState.activeWorkoutStore = $0 }
        )
    }

    private var completedWorkoutBinding: Binding<Workout?> {
        Binding(
            get: { flowState.completedWorkout },
            set: { flowState.completedWorkout = $0 }
        )
    }

    private func beginBlankWorkout() {
        flowState.beginBlankWorkout(in: store)
    }
}

#Preview("Recent Workouts") {
    NavigationStack {
        StartWorkoutScreen(store: .sample)
    }
}

#Preview("Empty State") {
    NavigationStack {
        StartWorkoutScreen(store: startWorkoutEmptyPreviewStore())
    }
}

private func startWorkoutEmptyPreviewStore() -> MockWorkoutStore {
    MockWorkoutStore(
        workouts: [],
        recentExercises: SampleFixtures.exerciseDefinitions
    )
}

@Observable
final class StartWorkoutFlowState {
    var activeWorkoutStore: ActiveWorkoutStore?
    var completedWorkout: Workout?

    func beginBlankWorkout(in store: MockWorkoutStore) {
        completedWorkout = nil
        activeWorkoutStore = ActiveWorkoutStore(store: store)
    }

    func showCompletion(for activeWorkoutStore: ActiveWorkoutStore) {
        guard let finishedWorkout = activeWorkoutStore.finishedWorkout else {
            return
        }

        self.activeWorkoutStore = nil
        completedWorkout = finishedWorkout
    }
}
