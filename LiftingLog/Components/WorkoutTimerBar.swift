import SwiftUI

struct WorkoutTimerBar: View {
    enum Style {
        case fullWidth
        case inline
    }

    let startedAt: Date
    var style: Style = .fullWidth

    var body: some View {
        TimelineView(.periodic(from: startedAt, by: 1)) { context in
            timerContent(now: context.date)
        }
    }

    @ViewBuilder
    private func timerContent(now: Date) -> some View {
        switch style {
        case .fullWidth:
            GlassSurface(cornerRadius: 22, padding: 14, tint: AppTheme.accent.opacity(0.2)) {
                HStack(spacing: 12) {
                    Image(systemName: "timer")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(AppTheme.accent)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Workout Timer")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)

                        Text(elapsedText(since: startedAt, now: now))
                            .font(.title3.monospacedDigit().weight(.semibold))
                    }

                    Spacer()
                }
            }

        case .inline:
            HStack(spacing: 8) {
                Image(systemName: "timer")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.accent)

                Text(elapsedText(since: startedAt, now: now))
                    .font(.headline.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.primary)
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
    VStack(alignment: .leading, spacing: 16) {
        WorkoutTimerBar(startedAt: .now.addingTimeInterval(-812))
        WorkoutTimerBar(startedAt: .now.addingTimeInterval(-812), style: .inline)
    }
    .padding()
    .background(AppTheme.pageBackground)
}
