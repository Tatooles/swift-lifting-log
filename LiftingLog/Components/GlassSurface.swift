import SwiftUI

struct GlassSurface<Content: View>: View {
    let cornerRadius: CGFloat
    let padding: CGFloat
    var tint: Color? = nil
    var interactive = false
    var alignment: Alignment = .leading
    var fullWidth = true
    @ViewBuilder let content: Content

    init(
        cornerRadius: CGFloat = 24,
        padding: CGFloat = 16,
        tint: Color? = nil,
        interactive: Bool = false,
        alignment: Alignment = .leading,
        fullWidth: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.tint = tint
        self.interactive = interactive
        self.alignment = alignment
        self.fullWidth = fullWidth
        self.content = content()
    }

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        Group {
            if fullWidth {
                content
                    .frame(maxWidth: .infinity, alignment: alignment)
            } else {
                content
            }
        }
            .padding(padding)
            .background(shape.fill(Color(.secondarySystemGroupedBackground).opacity(0.82)))
            .overlay(
                shape
                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
            )
            .modifier(
                GlassEffectModifier(
                    cornerRadius: cornerRadius,
                    tint: tint,
                    interactive: interactive
                )
            )
            .shadow(color: Color.black.opacity(0.05), radius: 12, y: 6)
    }
}

private struct GlassEffectModifier: ViewModifier {
    let cornerRadius: CGFloat
    let tint: Color?
    let interactive: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .glassEffect(glassStyle, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        } else {
            content
        }
    }

    @available(iOS 26.0, *)
    private var glassStyle: Glass {
        var glass = Glass.regular

        if let tint {
            glass = glass.tint(tint)
        }

        if interactive {
            glass = glass.interactive()
        }

        return glass
    }
}

#Preview {
    GlassSurface {
        VStack(alignment: .leading, spacing: 8) {
            Text("Workout Notes")
                .font(.headline)

            Text("Moderate glass chrome for cards and controls.")
                .foregroundStyle(.secondary)
        }
    }
    .padding()
    .background(AppTheme.pageBackground)
}
