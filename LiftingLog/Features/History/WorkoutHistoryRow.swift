import SwiftUI

struct WorkoutHistoryRow: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(workout.name)
                .font(.headline)

            HStack(spacing: 8) {
                Text(workout.date.formatted(date: .abbreviated, time: .omitted))
                Text("•")
                Text(workout.durationText)
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

extension Workout {
    var durationText: String {
        Duration.seconds(duration).formatted(
            .units(allowed: [.hours, .minutes], maximumUnitCount: 2)
        )
    }
}
