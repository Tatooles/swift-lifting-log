import SwiftUI

struct WorkoutHistoryList: View {
    let workouts: [Workout]

    var body: some View {
        if workouts.isEmpty {
            ContentUnavailableView(
                "No Workouts",
                systemImage: "clock.arrow.circlepath",
                description: Text("Saved workouts will appear here.")
            )
        } else {
            ForEach(workouts) { workout in
                NavigationLink {
                    WorkoutDetailScreen(workout: workout)
                } label: {
                    WorkoutHistoryRow(workout: workout)
                }
            }
        }
    }
}
