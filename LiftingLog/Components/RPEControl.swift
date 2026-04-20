import SwiftUI

enum RPETextMapper {
    static func text(for value: Double?) -> String {
        guard let value else {
            return ""
        }

        let hasFraction = value != value.rounded(.towardZero)
        return value.formatted(.number.precision(.fractionLength(hasFraction ? 1 : 0)))
    }

    static func value(from text: String) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return nil
        }

        return Double(trimmed)
    }
}

struct RPEControl: View {
    let selectedRPE: Double?
    let onSelect: (Double?) -> Void

    var body: some View {
        TextField(
            "RPE",
            text: Binding(
                get: { RPETextMapper.text(for: selectedRPE) },
                set: { onSelect(RPETextMapper.value(from: $0)) }
            )
        )
        .textInputAutocapitalization(.never)
        .keyboardType(.decimalPad)
        .font(.subheadline.weight(.semibold))
        .multilineTextAlignment(.center)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, minHeight: 36)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.tertiarySystemGroupedBackground))
        )
        .accessibilityLabel("RPE")
    }
}

#Preview {
    RPEControl(selectedRPE: 8) { _ in }
        .padding()
        .background(AppTheme.pageBackground)
}
