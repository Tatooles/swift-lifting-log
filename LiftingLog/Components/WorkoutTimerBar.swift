import SwiftUI

struct WorkoutTimerBar: View {
    let startedAt: Date

    var body: some View {
        TimelineView(.periodic(from: startedAt, by: 1)) { context in
            GlassSurface(cornerRadius: 22, padding: 14, tint: AppTheme.accent.opacity(0.2)) {
                HStack(spacing: 12) {
                    Image(systemName: "timer")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(AppTheme.accent)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Workout Timer")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        Text(elapsedText(since: startedAt, now: context.date))
                            .font(.title3.monospacedDigit().weight(.semibold))
                    }

                    Spacer()
                }
            }
        }
    }

    private func elapsedText(since startedAt: Date, now: Date) -> String {
        let totalSeconds = max(Int(now.timeIntervalSince(startedAt)), 0)
        let hours = totalSeconds / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }

        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    WorkoutTimerBar(startedAt: .now.addingTimeInterval(-812))
        .padding()
        .background(AppTheme.pageBackground)
}
