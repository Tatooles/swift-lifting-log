import SwiftUI

struct HistoryScreen: View {
    enum Segment: String, CaseIterable, Identifiable {
        case workouts = "Workout History"
        case exercises = "Exercise History"

        var id: Self { self }
    }

    let store: MockWorkoutStore
    @State private var selectedSegment: Segment = .workouts

    init(store: MockWorkoutStore, initialSegment: Segment = .workouts) {
        self.store = store
        _selectedSegment = State(initialValue: initialSegment)
    }

    var body: some View {
        List {
            Section {
                Picker("History Type", selection: $selectedSegment) {
                    ForEach(Segment.allCases) { segment in
                        Text(segment.rawValue).tag(segment)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .listRowInsets(
                    EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
                )
                .listRowBackground(Color.clear)
            }

            Section {
                switch selectedSegment {
                case .workouts:
                    WorkoutHistoryList(workouts: store.workouts)
                case .exercises:
                    ExerciseHistoryList(exercises: store.exerciseHistory)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("History")
    }
}

#Preview("Workout History") {
    NavigationStack {
        HistoryScreen(store: .sample)
    }
}

#Preview("Exercise History") {
    NavigationStack {
        HistoryScreen(store: .sample, initialSegment: .exercises)
    }
}
