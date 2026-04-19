import SwiftUI

struct WorkoutCompletionScreen: View {
    let workout: Workout

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(AppTheme.accent)

            VStack(spacing: 8) {
                Text("Workout Complete")
                    .font(.title2.weight(.semibold))

                Text("\(workout.exercises.count) exercises logged in \(workout.durationText).")
                    .font(.headline)

                Text("Your session was saved to history and is ready to review whenever you want.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 10) {
                LabeledContent("Workout", value: workout.name)
                LabeledContent(
                    "Date",
                    value: workout.date.formatted(date: .abbreviated, time: .omitted)
                )
            }
            .font(.subheadline)
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(.secondarySystemGroupedBackground))
            )

            Button("Done") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(AppTheme.screenPadding)
        .background(AppTheme.pageBackground.ignoresSafeArea())
        .navigationTitle("Completed")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        WorkoutCompletionScreen(workout: SampleFixtures.workouts[0])
    }
}
