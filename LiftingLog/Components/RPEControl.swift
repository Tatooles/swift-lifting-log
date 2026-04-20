import SwiftUI

struct RPEControl: View {
    let selectedRPE: Double?
    let onSelect: (Double?) -> Void

    private let values: [Double] = [6, 7, 8, 9, 10]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("RPE")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)

                Spacer()

                if selectedRPE != nil {
                    Button("Clear") {
                        onSelect(nil)
                    }
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppTheme.accent)
                }
            }

            HStack(spacing: 8) {
                ForEach(values, id: \.self) { value in
                    Button {
                        onSelect(value)
                    } label: {
                        Text(value.formatted(.number.precision(.fractionLength(0))))
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(backgroundShape(for: value))
                            .foregroundStyle(selectedRPE == value ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    @ViewBuilder
    private func backgroundShape(for value: Double) -> some View {
        let isSelected = selectedRPE == value
        let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)

        if isSelected {
            shape
                .fill(AppTheme.accent.gradient)
        } else {
            shape
                .fill(Color(.tertiarySystemGroupedBackground))
        }
    }
}

#Preview {
    RPEControl(selectedRPE: 8) { _ in }
        .padding()
        .background(AppTheme.pageBackground)
}
