import SwiftUI

struct RecentWorkoutCard: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.name)
                        .font(.headline)

                    Text(workout.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(workout.durationText)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Label("\(workout.exercises.count) exercises", systemImage: "list.bullet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(exercisePreview)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
    }

    private var exercisePreview: String {
        let names = workout.exercises.prefix(3).map(\.name)

        if workout.exercises.count > 3 {
            return names.joined(separator: " • ") + " • +\(workout.exercises.count - 3) more"
        }

        return names.joined(separator: " • ")
    }
}

#Preview {
    RecentWorkoutCard(workout: SampleFixtures.workouts[0])
        .padding()
        .background(AppTheme.pageBackground)
}
