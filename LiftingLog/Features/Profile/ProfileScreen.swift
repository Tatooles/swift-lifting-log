import SwiftUI

struct ProfileScreen: View {
    var body: some View {
        List {
            Section {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.accent.opacity(0.14))
                            .frame(width: 56, height: 56)

                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(AppTheme.accent)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Prototype Profile")
                            .font(.headline)

                        Text("Local-first lifting log preferences and app details.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("Preferences") {
                LabeledContent("Units", value: "Pounds in v1")
                LabeledContent("Rest Timer Alerts", value: "Planned")
                LabeledContent("Haptics", value: "Planned")
            }

            Section("Training Defaults") {
                LabeledContent("Default Workout Name", value: "Blank Workout")
                LabeledContent("RPE Tracking", value: "Inline per set")
                LabeledContent("History Sort", value: "Most recent first")
            }

            Section("App Info") {
                LabeledContent("Version", value: profileVersionText)
                LabeledContent("Build", value: "Prototype")
                LabeledContent("Storage", value: "On-device sample data")
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Profile")
    }

    private var profileVersionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

        switch (version, build) {
        case let (version?, build?):
            return "\(version) (\(build))"
        case let (version?, nil):
            return version
        case let (nil, build?):
            return build
        case (nil, nil):
            return "Preview"
        }
    }
}

#Preview {
    NavigationStack {
        ProfileScreen()
    }
}
