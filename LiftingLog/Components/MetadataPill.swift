import SwiftUI

struct MetadataPill: View {
    let title: String
    let systemImage: String

    var body: some View {
        GlassSurface(cornerRadius: 18, padding: 10) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppTheme.accent)

                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.primary)
            }
        }
        .fixedSize(horizontal: true, vertical: true)
    }
}

#Preview {
    MetadataPill(title: "3 exercises", systemImage: "list.bullet")
        .padding()
        .background(AppTheme.pageBackground)
}
