import SwiftUI

struct SetRowView: View {
    let setNumber: Int
    let repsText: String
    let weightText: String
    let rpe: Double?
    var isEditable = false
    var onRepsChange: (String) -> Void = { _ in }
    var onWeightChange: (String) -> Void = { _ in }
    var onRPEChange: (Double?) -> Void = { _ in }

    var body: some View {
        HStack(spacing: 10) {
            Text("\(setNumber)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 18)

            if isEditable {
                metricField(
                    placeholder: "Wt",
                    text: weightText,
                    keyboardType: .decimalPad,
                    onChange: onWeightChange
                )

                metricField(
                    placeholder: "Reps",
                    text: repsText,
                    keyboardType: .numberPad,
                    onChange: onRepsChange
                )

                RPEControl(selectedRPE: rpe, onSelect: onRPEChange)
            } else {
                metricValue(weightText.isEmpty ? "Wt" : weightText)
                metricValue(repsText.isEmpty ? "Reps" : repsText)

                metricValue(rpe.map(RPETextMapper.text(for:)) ?? "RPE")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color(.separator).opacity(0.18), lineWidth: 1)
        )
    }

    private func metricField(
        placeholder: String,
        text: String,
        keyboardType: UIKeyboardType,
        onChange: @escaping (String) -> Void
    ) -> some View {
        TextField(placeholder, text: Binding(get: { text }, set: onChange))
            .textInputAutocapitalization(.never)
            .keyboardType(keyboardType)
            .font(.subheadline.weight(.semibold))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, minHeight: 36)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.tertiarySystemGroupedBackground))
            )
    }

    private func metricValue(_ value: String) -> some View {
        Text(value)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(value == "Wt" || value == "Reps" || value == "RPE" ? .secondary : .primary)
            .frame(maxWidth: .infinity, minHeight: 36)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.tertiarySystemGroupedBackground))
            )
    }
}

#Preview {
    VStack(spacing: 16) {
        SetRowView(
            setNumber: 1,
            repsText: "5",
            weightText: "225",
            rpe: 8,
            isEditable: false
        )

        SetRowView(
            setNumber: 2,
            repsText: "",
            weightText: "",
            rpe: nil,
            isEditable: true
        )
    }
    .padding()
    .background(AppTheme.pageBackground)
}
