import SwiftUI

struct SetRowView: View {
    let setNumber: Int
    let repsText: String
    let weightText: String
    let rpe: Double?
    let notesText: String
    var isEditable = false
    var onRepsChange: (String) -> Void = { _ in }
    var onWeightChange: (String) -> Void = { _ in }
    var onRPEChange: (Double?) -> Void = { _ in }
    var onNotesChange: (String) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Set \(setNumber)")
                .font(.subheadline.weight(.semibold))

            if isEditable {
                HStack(spacing: 12) {
                    entryField(
                        title: "Reps",
                        text: repsText,
                        keyboardType: .numberPad,
                        onChange: onRepsChange
                    )

                    entryField(
                        title: "Weight",
                        text: weightText,
                        keyboardType: .decimalPad,
                        onChange: onWeightChange
                    )
                }

                RPEControl(selectedRPE: rpe, onSelect: onRPEChange)

                notesField
            } else {
                HStack(spacing: 10) {
                    valueChip(title: repsText.isEmpty ? "No reps" : "\(repsText) reps")

                    if !weightText.isEmpty {
                        valueChip(title: weightText)
                    }

                    if let rpe {
                        valueChip(
                            title: "RPE \(rpe.formatted(.number.precision(.fractionLength(1))))"
                        )
                    }

                    Spacer()
                }

                if !notesText.isEmpty {
                    Text(notesText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color(.separator).opacity(0.22), lineWidth: 1)
        )
    }

    private func entryField(
        title: String,
        text: String,
        keyboardType: UIKeyboardType,
        onChange: @escaping (String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField(title, text: Binding(get: { text }, set: onChange))
                .textInputAutocapitalization(.never)
                .keyboardType(keyboardType)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.tertiarySystemGroupedBackground))
                )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func valueChip(title: String) -> some View {
        Text(title)
            .font(.footnote.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(Color(.tertiarySystemGroupedBackground))
            )
    }

    private var notesField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Notes")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            TextField(
                "Optional set note",
                text: Binding(get: { notesText }, set: onNotesChange),
                axis: .vertical
            )
            .lineLimit(1 ... 3)
            .textInputAutocapitalization(.sentences)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color(.tertiarySystemGroupedBackground))
            )
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        SetRowView(
            setNumber: 1,
            repsText: "5",
            weightText: "225",
            rpe: 8,
            notesText: "Paused first rep.",
            isEditable: false
        )

        SetRowView(
            setNumber: 2,
            repsText: "",
            weightText: "",
            rpe: nil,
            notesText: "",
            isEditable: true
        )
    }
    .padding()
    .background(AppTheme.pageBackground)
}
