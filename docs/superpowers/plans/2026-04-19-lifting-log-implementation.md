# Lifting Log Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a native iPhone-only iOS 26 SwiftUI lifting log app with local sample data, a three-tab shell, and a fast active workout editor.

**Architecture:** The app uses a small root app shell with `TabView` + per-tab `NavigationStack`, feature-scoped SwiftUI views, and lightweight local models. Workout history uses saved sample models, while the active workout flow uses separate draft models and an `@Observable` store so transient rows and inline editing stay isolated from read-only history data.

**Tech Stack:** SwiftUI, Observation, XCTest, Xcode 26 iOS app template, Liquid Glass APIs on iOS 26

---

## Planned File Map

- `.gitignore` — Xcode, simulator, and derived-data ignores.
- `LiftingLog.xcodeproj/project.pbxproj` — Xcode project definition.
- `LiftingLog/App/LiftingLogApp.swift` — app entry point and root dependency wiring.
- `LiftingLog/App/AppTab.swift` — top-level tab enum and tab metadata.
- `LiftingLog/App/RootTabView.swift` — three-tab shell and per-tab navigation stacks.
- `LiftingLog/App/AppTheme.swift` — shared colors, spacing, and glass chrome helpers.
- `LiftingLog/Models/Workout.swift` — saved workout, exercise, and set models.
- `LiftingLog/Models/ExerciseDefinition.swift` — recent/common exercise definition model.
- `LiftingLog/Models/ActiveWorkoutDraft.swift` — in-progress draft workout, draft exercises, and draft sets.
- `LiftingLog/SampleData/SampleFixtures.swift` — preview-ready sample workouts and exercises.
- `LiftingLog/SampleData/MockWorkoutStore.swift` — in-memory store for sample history and recent exercise suggestions.
- `LiftingLog/Components/GlassSurface.swift` — moderate reusable Liquid Glass container for chrome.
- `LiftingLog/Components/WorkoutTimerBar.swift` — sticky workout timer view.
- `LiftingLog/Components/RPEControl.swift` — tap-based RPE picker.
- `LiftingLog/Components/MetadataPill.swift` — compact prior-performance and summary pills.
- `LiftingLog/Features/History/HistoryScreen.swift` — segmented history root.
- `LiftingLog/Features/History/WorkoutHistoryList.swift` — workout history list view.
- `LiftingLog/Features/History/ExerciseHistoryList.swift` — exercise history list view.
- `LiftingLog/Features/History/WorkoutDetailScreen.swift` — saved workout detail screen.
- `LiftingLog/Features/History/WorkoutHistoryRow.swift` — workout list row.
- `LiftingLog/Features/StartWorkout/StartWorkoutScreen.swift` — blank workout start screen and recent workout cards.
- `LiftingLog/Features/StartWorkout/RecentWorkoutCard.swift` — reusable recent workout card.
- `LiftingLog/Features/StartWorkout/WorkoutCompletionScreen.swift` — minimal completion confirmation screen.
- `LiftingLog/Features/ActiveWorkout/ActiveWorkoutStore.swift` — active workout mutations, expansion state, timer state, and finish action.
- `LiftingLog/Features/ActiveWorkout/ActiveWorkoutScreen.swift` — active workout editor screen.
- `LiftingLog/Features/ActiveWorkout/ExerciseCardView.swift` — collapsible exercise card.
- `LiftingLog/Features/ActiveWorkout/SetRowView.swift` — inline set row editor.
- `LiftingLog/Features/ActiveWorkout/ExercisePickerSheet.swift` — recent-exercise picker plus ad hoc exercise creation.
- `LiftingLog/Features/Profile/ProfileScreen.swift` — placeholder settings-style profile tab.
- `LiftingLogTests/Models/ActiveWorkoutDraftTests.swift` — draft row materialization and blank-set rules.
- `LiftingLogTests/SampleData/MockWorkoutStoreTests.swift` — sample store ordering and recent exercise queries.
- `LiftingLogTests/Features/ActiveWorkoutStoreTests.swift` — one-expanded-exercise rule and finish-workout behavior.

### Task 1: Bootstrap The Xcode App Project

**Files:**
- Create: `.gitignore`
- Create: `LiftingLog.xcodeproj/project.pbxproj`
- Create: `LiftingLog/LiftingLogApp.swift`
- Create: `LiftingLog/Assets.xcassets`
- Create: `LiftingLog/Info.plist`
- Create: `LiftingLogTests/LiftingLogTests.swift`

- [ ] **Step 1: Create the iOS app project in Xcode**

Run:

```bash
open -a Xcode .
```

Expected: Xcode launches in `/Users/kevintatooles/Desktop/Projects/swift-lifting-log`.

Inside Xcode, create a new project with these exact settings:

```text
Template: iOS App
Product Name: LiftingLog
Team: None
Organization Identifier: com.kevintatooles
Interface: SwiftUI
Language: Swift
Testing System: XCTest
Storage: None
Destination folder: /Users/kevintatooles/Desktop/Projects/swift-lifting-log
```

- [ ] **Step 2: Add repo hygiene before writing app code**

Create `.gitignore` with:

```gitignore
DerivedData/
.DS_Store
build/
*.xcuserstate
xcuserdata/
```

- [ ] **Step 3: Verify the generated app builds before refactoring**

Run:

```bash
xcodebuild -project LiftingLog.xcodeproj -scheme LiftingLog -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 4: Commit the clean bootstrap**

```bash
git add .gitignore LiftingLog.xcodeproj LiftingLog LiftingLogTests
git commit -m "chore: bootstrap LiftingLog iOS app"
```

### Task 2: Create The App Shell And Shared Theme

**Files:**
- Create: `LiftingLog/App/LiftingLogApp.swift`
- Create: `LiftingLog/App/AppTab.swift`
- Create: `LiftingLog/App/RootTabView.swift`
- Create: `LiftingLog/App/AppTheme.swift`
- Modify: `LiftingLog.xcodeproj/project.pbxproj`

- [ ] **Step 1: Replace the generated entry view with app-shell files**

Move the generated app entry under `App/` and use this code:

```swift
import SwiftUI

@main
struct LiftingLogApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
    }
}
```

Create `AppTab.swift`:

```swift
import SwiftUI

enum AppTab: Hashable, CaseIterable {
    case history
    case startWorkout
    case profile

    var title: String {
        switch self {
        case .history: "History"
        case .startWorkout: "Start Workout"
        case .profile: "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .history: "clock.arrow.circlepath"
        case .startWorkout: "plus.circle.fill"
        case .profile: "person.crop.circle"
        }
    }
}
```

- [ ] **Step 2: Build the three-tab shell with per-tab navigation**

Create `RootTabView.swift`:

```swift
import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: AppTab = .startWorkout

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HistoryScreen()
            }
            .tabItem { Label(AppTab.history.title, systemImage: AppTab.history.systemImage) }
            .tag(AppTab.history)

            NavigationStack {
                StartWorkoutScreen()
            }
            .tabItem { Label(AppTab.startWorkout.title, systemImage: AppTab.startWorkout.systemImage) }
            .tag(AppTab.startWorkout)

            NavigationStack {
                ProfileScreen()
            }
            .tabItem { Label(AppTab.profile.title, systemImage: AppTab.profile.systemImage) }
            .tag(AppTab.profile)
        }
    }
}
```

Create `AppTheme.swift`:

```swift
import SwiftUI

enum AppTheme {
    static let pageBackground = Color(.systemGroupedBackground)
    static let accent = Color(red: 0.12, green: 0.46, blue: 0.34)
}
```

- [ ] **Step 3: Remove the generated `ContentView.swift` and wire new files into the project**

Delete `LiftingLog/ContentView.swift`, add the new `App/` group to the project, and make sure the target includes `LiftingLogApp.swift`, `AppTab.swift`, `RootTabView.swift`, and `AppTheme.swift`.

- [ ] **Step 4: Verify the shell compiles with placeholder screens**

Create temporary stubs:

```swift
import SwiftUI

struct HistoryScreen: View {
    var body: some View { Text("History") }
}

struct StartWorkoutScreen: View {
    var body: some View { Text("Start Workout") }
}

struct ProfileScreen: View {
    var body: some View { Text("Profile") }
}
```

Run:

```bash
xcodebuild -project LiftingLog.xcodeproj -scheme LiftingLog -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 5: Commit the app shell**

```bash
git add LiftingLog/App LiftingLog.xcodeproj/project.pbxproj
git commit -m "feat: add tab-based app shell"
```

### Task 3: Add Domain Models And Draft-State Tests

**Files:**
- Create: `LiftingLog/Models/Workout.swift`
- Create: `LiftingLog/Models/ExerciseDefinition.swift`
- Create: `LiftingLog/Models/ActiveWorkoutDraft.swift`
- Create: `LiftingLogTests/Models/ActiveWorkoutDraftTests.swift`
- Modify: `LiftingLog.xcodeproj/project.pbxproj`

- [ ] **Step 1: Write failing tests for draft-set materialization and blank-set behavior**

Create `LiftingLogTests/Models/ActiveWorkoutDraftTests.swift`:

```swift
import XCTest
@testable import LiftingLog

final class ActiveWorkoutDraftTests: XCTestCase {
    func testMaterializesDraftSetWhenWeightIsEntered() throws {
        var draft = ActiveWorkoutDraft.makeEmpty()
        draft.addExercise(named: "Bench Press")
        let exerciseID = try XCTUnwrap(draft.exercises.first?.id)

        draft.updateDraftSet(
            for: exerciseID,
            repsText: "",
            weightText: "225",
            rpe: nil,
            notes: ""
        )

        XCTAssertEqual(draft.exercises[0].loggedSets.count, 1)
        XCTAssertEqual(draft.exercises[0].loggedSets[0].weightText, "225")
        XCTAssertEqual(draft.exercises[0].draftSet.weightText, "")
    }

    func testLeavesBlankDraftSetUnpersisted() throws {
        var draft = ActiveWorkoutDraft.makeEmpty()
        draft.addExercise(named: "Squat")
        let exerciseID = try XCTUnwrap(draft.exercises.first?.id)

        draft.updateDraftSet(
            for: exerciseID,
            repsText: "",
            weightText: "",
            rpe: nil,
            notes: ""
        )

        XCTAssertTrue(draft.exercises[0].loggedSets.isEmpty)
    }
}
```

Run:

```bash
xcodebuild test -project LiftingLog.xcodeproj -scheme LiftingLog -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:LiftingLogTests/ActiveWorkoutDraftTests
```

Expected: build fails because `ActiveWorkoutDraft` does not exist yet.

- [ ] **Step 2: Implement saved-workout and draft models minimally**

Create `Workout.swift`:

```swift
import Foundation

struct Workout: Identifiable, Hashable {
    let id: UUID
    var name: String
    var date: Date
    var duration: TimeInterval
    var exercises: [LoggedExercise]
}

struct LoggedExercise: Identifiable, Hashable {
    let id: UUID
    var name: String
    var sets: [LoggedSet]
    var notes: String
}

struct LoggedSet: Identifiable, Hashable {
    let id: UUID
    var repsText: String
    var weightText: String
    var rpe: Double?
    var notes: String
    var isComplete: Bool
}
```

Create `ExerciseDefinition.swift`:

```swift
import Foundation

struct ExerciseDefinition: Identifiable, Hashable {
    let id: UUID
    var name: String
}
```

Create `ActiveWorkoutDraft.swift`:

```swift
import Foundation

struct ActiveWorkoutDraft: Hashable {
    var name: String
    var date: Date
    var exercises: [DraftExercise]

    static func makeEmpty(now: Date = .now) -> ActiveWorkoutDraft {
        ActiveWorkoutDraft(name: "Blank Workout", date: now, exercises: [])
    }

    mutating func addExercise(named name: String) {
        exercises.append(DraftExercise(id: UUID(), name: name, loggedSets: [], draftSet: DraftSet()))
    }

    mutating func updateDraftSet(for exerciseID: UUID, repsText: String, weightText: String, rpe: Double?, notes: String) {
        guard let index = exercises.firstIndex(where: { $0.id == exerciseID }) else { return }
        let proposed = DraftSet(repsText: repsText, weightText: weightText, rpe: rpe, notes: notes)
        if proposed.isBlank {
            exercises[index].draftSet = proposed
            return
        }

        exercises[index].loggedSets.append(
            LoggedSet(
                id: UUID(),
                repsText: repsText,
                weightText: weightText,
                rpe: rpe,
                notes: notes,
                isComplete: true
            )
        )
        exercises[index].draftSet = DraftSet()
    }
}

struct DraftExercise: Identifiable, Hashable {
    let id: UUID
    var name: String
    var loggedSets: [LoggedSet]
    var draftSet: DraftSet
}

struct DraftSet: Hashable {
    var repsText: String = ""
    var weightText: String = ""
    var rpe: Double?
    var notes: String = ""

    var isBlank: Bool {
        repsText.isEmpty && weightText.isEmpty && rpe == nil && notes.isEmpty
    }
}
```

- [ ] **Step 3: Run the draft-model tests and confirm they pass**

Run:

```bash
xcodebuild test -project LiftingLog.xcodeproj -scheme LiftingLog -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:LiftingLogTests/ActiveWorkoutDraftTests
```

Expected: `** TEST SUCCEEDED **`

- [ ] **Step 4: Commit the model layer**

```bash
git add LiftingLog/Models LiftingLogTests/Models LiftingLog.xcodeproj/project.pbxproj
git commit -m "feat: add workout and draft models"
```

### Task 4: Add Sample Fixtures And The In-Memory Store

**Files:**
- Create: `LiftingLog/SampleData/SampleFixtures.swift`
- Create: `LiftingLog/SampleData/MockWorkoutStore.swift`
- Create: `LiftingLogTests/SampleData/MockWorkoutStoreTests.swift`
- Modify: `LiftingLog/App/LiftingLogApp.swift`
- Modify: `LiftingLog/App/RootTabView.swift`
- Modify: `LiftingLog.xcodeproj/project.pbxproj`

- [ ] **Step 1: Write failing tests for history ordering and recent exercise suggestions**

Create `LiftingLogTests/SampleData/MockWorkoutStoreTests.swift`:

```swift
import XCTest
@testable import LiftingLog

final class MockWorkoutStoreTests: XCTestCase {
    func testWorkoutHistoryIsSortedNewestFirst() {
        let store = MockWorkoutStore.sample

        let dates = store.workouts.map(\.date)
        XCTAssertEqual(dates, dates.sorted(by: >))
    }

    func testRecentExerciseSuggestionsAreUniqueAndOrdered() {
        let store = MockWorkoutStore.sample

        XCTAssertEqual(store.recentExercises.prefix(3).map(\.name), [
            "Bench Press",
            "Back Squat",
            "Romanian Deadlift"
        ])
    }
}
```

Run:

```bash
xcodebuild test -project LiftingLog.xcodeproj -scheme LiftingLog -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:LiftingLogTests/MockWorkoutStoreTests
```

Expected: build fails because `MockWorkoutStore` does not exist yet.

- [ ] **Step 2: Implement sample fixtures and the in-memory store**

Create `SampleFixtures.swift`:

```swift
import Foundation

enum SampleFixtures {
    static let workouts: [Workout] = [
        Workout(
            id: UUID(),
            name: "Upper Strength",
            date: Date.now.addingTimeInterval(-86_400),
            duration: 4_500,
            exercises: [
                LoggedExercise(
                    id: UUID(),
                    name: "Bench Press",
                    sets: [
                        LoggedSet(id: UUID(), repsText: "5", weightText: "225", rpe: 8.0, notes: "", isComplete: true),
                        LoggedSet(id: UUID(), repsText: "5", weightText: "225", rpe: 8.5, notes: "", isComplete: true)
                    ],
                    notes: "Good bar speed"
                )
            ]
        ),
        Workout(
            id: UUID(),
            name: "Lower Strength",
            date: Date.now.addingTimeInterval(-172_800),
            duration: 5_100,
            exercises: [
                LoggedExercise(
                    id: UUID(),
                    name: "Back Squat",
                    sets: [
                        LoggedSet(id: UUID(), repsText: "5", weightText: "315", rpe: 8.0, notes: "", isComplete: true)
                    ],
                    notes: ""
                )
            ]
        )
    ]

    static let exerciseDefinitions: [ExerciseDefinition] = [
        ExerciseDefinition(id: UUID(), name: "Bench Press"),
        ExerciseDefinition(id: UUID(), name: "Back Squat"),
        ExerciseDefinition(id: UUID(), name: "Romanian Deadlift"),
        ExerciseDefinition(id: UUID(), name: "Overhead Press")
    ]
}
```

Create `MockWorkoutStore.swift`:

```swift
import Foundation

@Observable
final class MockWorkoutStore {
    var workouts: [Workout]
    var recentExercises: [ExerciseDefinition]

    init(workouts: [Workout], recentExercises: [ExerciseDefinition]) {
        self.workouts = workouts.sorted { $0.date > $1.date }
        self.recentExercises = recentExercises
    }

    static let sample = MockWorkoutStore(
        workouts: SampleFixtures.workouts,
        recentExercises: SampleFixtures.exerciseDefinitions
    )
}
```

Update `LiftingLogApp.swift` so the app owns the shared store:

```swift
import SwiftUI

@main
struct LiftingLogApp: App {
    @State private var store = MockWorkoutStore.sample

    var body: some Scene {
        WindowGroup {
            RootTabView(store: store)
        }
    }
}
```

Update `RootTabView.swift` so History and Start Workout receive the shared store:

```swift
import SwiftUI

struct RootTabView: View {
    @State private var selectedTab: AppTab = .startWorkout
    let store: MockWorkoutStore

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HistoryScreen(store: store)
            }
            .tabItem { Label(AppTab.history.title, systemImage: AppTab.history.systemImage) }
            .tag(AppTab.history)

            NavigationStack {
                StartWorkoutScreen(store: store)
            }
            .tabItem { Label(AppTab.startWorkout.title, systemImage: AppTab.startWorkout.systemImage) }
            .tag(AppTab.startWorkout)

            NavigationStack {
                ProfileScreen()
            }
            .tabItem { Label(AppTab.profile.title, systemImage: AppTab.profile.systemImage) }
            .tag(AppTab.profile)
        }
    }
}
```

- [ ] **Step 3: Run the store tests and a full app build**

Run:

```bash
xcodebuild test -project LiftingLog.xcodeproj -scheme LiftingLog -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:LiftingLogTests/MockWorkoutStoreTests
xcodebuild -project LiftingLog.xcodeproj -scheme LiftingLog -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

Expected: `** TEST SUCCEEDED **` and `** BUILD SUCCEEDED **`

- [ ] **Step 4: Commit the sample data layer**

```bash
git add LiftingLog/SampleData LiftingLog/App/LiftingLogApp.swift LiftingLog/App/RootTabView.swift LiftingLog.xcodeproj/project.pbxproj LiftingLogTests/SampleData
git commit -m "feat: add sample workout store"
```

### Task 5: Build History Browsing And Workout Detail

**Files:**
- Create: `LiftingLog/Features/History/HistoryScreen.swift`
- Create: `LiftingLog/Features/History/WorkoutHistoryList.swift`
- Create: `LiftingLog/Features/History/ExerciseHistoryList.swift`
- Create: `LiftingLog/Features/History/WorkoutDetailScreen.swift`
- Create: `LiftingLog/Features/History/WorkoutHistoryRow.swift`
- Modify: `LiftingLog/App/RootTabView.swift`
- Modify: `LiftingLog.xcodeproj/project.pbxproj`

- [ ] **Step 1: Implement the segmented history root and list row**

Create `HistoryScreen.swift`:

```swift
import SwiftUI

struct HistoryScreen: View {
    enum Segment: String, CaseIterable, Identifiable {
        case workouts = "Workout History"
        case exercises = "Exercise History"
        var id: Self { self }
    }

    let store: MockWorkoutStore
    @State private var segment: Segment = .workouts

    var body: some View {
        List {
            Picker("History Type", selection: $segment) {
                ForEach(Segment.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)

            switch segment {
            case .workouts:
                WorkoutHistoryList(workouts: store.workouts)
            case .exercises:
                ExerciseHistoryList(exercises: store.recentExercises)
            }
        }
        .navigationTitle("History")
    }
}
```

Create `WorkoutHistoryRow.swift`:

```swift
import SwiftUI

struct WorkoutHistoryRow: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(workout.name).font(.headline)
            Text(workout.date.formatted(date: .abbreviated, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(Duration.seconds(workout.duration).formatted(.units(allowed: [.hours, .minutes])))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
```

- [ ] **Step 2: Implement workout detail and exercise-history list**

Create `WorkoutHistoryList.swift`:

```swift
import SwiftUI

struct WorkoutHistoryList: View {
    let workouts: [Workout]

    var body: some View {
        ForEach(workouts) { workout in
            NavigationLink {
                WorkoutDetailScreen(workout: workout)
            } label: {
                WorkoutHistoryRow(workout: workout)
            }
        }
    }
}
```

Create `ExerciseHistoryList.swift`:

```swift
import SwiftUI

struct ExerciseHistoryList: View {
    let exercises: [ExerciseDefinition]

    var body: some View {
        ForEach(exercises) { exercise in
            Text(exercise.name)
        }
    }
}
```

Create `WorkoutDetailScreen.swift`:

```swift
import SwiftUI

struct WorkoutDetailScreen: View {
    let workout: Workout

    var body: some View {
        List {
            Section {
                LabeledContent("Date", value: workout.date.formatted(date: .abbreviated, time: .omitted))
                LabeledContent("Duration", value: Duration.seconds(workout.duration).formatted(.units(allowed: [.hours, .minutes])))
            }

            ForEach(workout.exercises) { exercise in
                Section(exercise.name) {
                    ForEach(exercise.sets) { set in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(set.repsText) reps x \(set.weightText) lb")
                            Text("RPE \(set.rpe ?? 0, specifier: "%.1f")")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                            if !set.notes.isEmpty {
                                Text(set.notes).font(.footnote)
                            }
                        }
                    }
                    if !exercise.notes.isEmpty {
                        Text(exercise.notes).font(.footnote)
                    }
                }
            }
        }
        .navigationTitle(workout.name)
    }
}
```

- [ ] **Step 3: Build and preview-check the history flow**

Run:

```bash
xcodebuild -project LiftingLog.xcodeproj -scheme LiftingLog -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

Expected: `** BUILD SUCCEEDED **`

Then open the preview or simulator and confirm:

```text
History shows the segmented control at the top.
Workout rows show name, date, and duration.
Selecting a workout pushes Workout Detail.
Exercise History shows exercise names only.
```

- [ ] **Step 4: Commit the history feature**

```bash
git add LiftingLog/Features/History LiftingLog/App/RootTabView.swift LiftingLog.xcodeproj/project.pbxproj
git commit -m "feat: add workout history browsing"
```

### Task 6: Build Start Workout And Completion Flow

**Files:**
- Create: `LiftingLog/Features/StartWorkout/StartWorkoutScreen.swift`
- Create: `LiftingLog/Features/StartWorkout/RecentWorkoutCard.swift`
- Create: `LiftingLog/Features/StartWorkout/WorkoutCompletionScreen.swift`
- Modify: `LiftingLog.xcodeproj/project.pbxproj`

- [ ] **Step 1: Implement the start screen shell**

Create `RecentWorkoutCard.swift`:

```swift
import SwiftUI

struct RecentWorkoutCard: View {
    let workout: Workout

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(workout.name).font(.headline)
            Text(workout.date.formatted(date: .abbreviated, time: .omitted))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
```

Create `WorkoutCompletionScreen.swift`:

```swift
import SwiftUI

struct WorkoutCompletionScreen: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 52))
                .foregroundStyle(.green)
            Text("Workout Saved")
                .font(.title2.bold())
            Text("Nice work. Your workout is now in history.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(32)
        .navigationBarBackButtonHidden()
    }
}
```

- [ ] **Step 2: Implement the start-workout root with navigation into the active editor**

Create `StartWorkoutScreen.swift`:

```swift
import SwiftUI

struct StartWorkoutScreen: View {
    let store: MockWorkoutStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Button {
                } label: {
                    Label("Start Blank Workout", systemImage: "plus.circle.fill")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.glassProminent)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Workouts").font(.headline)
                    ForEach(store.workouts.prefix(3)) { workout in
                        RecentWorkoutCard(workout: workout)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Start Workout")
    }
}
```

- [ ] **Step 3: Build the start flow and confirm navigation works**

Run:

```bash
xcodebuild -project LiftingLog.xcodeproj -scheme LiftingLog -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

Expected: `** BUILD SUCCEEDED **`

Confirm in simulator:

```text
The Start Workout tab is the default selected tab.
The blank workout action is visually dominant.
The recent workout cards render underneath the primary action.
```

- [ ] **Step 4: Commit the start-workout flow**

```bash
git add LiftingLog/Features/StartWorkout LiftingLog.xcodeproj/project.pbxproj
git commit -m "feat: add workout start flow"
```

### Task 7: Implement Active Workout Store Logic With Tests

**Files:**
- Create: `LiftingLog/Features/ActiveWorkout/ActiveWorkoutStore.swift`
- Create: `LiftingLogTests/Features/ActiveWorkoutStoreTests.swift`
- Modify: `LiftingLog/SampleData/MockWorkoutStore.swift`
- Modify: `LiftingLog.xcodeproj/project.pbxproj`

- [ ] **Step 1: Write failing tests for one-expanded-exercise and workout completion**

Create `LiftingLogTests/Features/ActiveWorkoutStoreTests.swift`:

```swift
import XCTest
@testable import LiftingLog

final class ActiveWorkoutStoreTests: XCTestCase {
    func testExpandingExerciseCollapsesThePreviouslyExpandedExercise() throws {
        let store = MockWorkoutStore.sample
        let activeStore = ActiveWorkoutStore(store: store)
        activeStore.addExercise(named: "Bench Press")
        activeStore.addExercise(named: "Back Squat")

        let firstID = try XCTUnwrap(activeStore.draft.exercises.first?.id)
        let secondID = try XCTUnwrap(activeStore.draft.exercises.last?.id)

        activeStore.toggleExpandedExercise(firstID)
        activeStore.toggleExpandedExercise(secondID)

        XCTAssertEqual(activeStore.expandedExerciseID, secondID)
    }

    func testFinishWorkoutAppendsSavedWorkoutToHistory() {
        let store = MockWorkoutStore.sample
        let activeStore = ActiveWorkoutStore(store: store)
        activeStore.addExercise(named: "Bench Press")

        let initialCount = store.workouts.count
        activeStore.finishWorkout()

        XCTAssertEqual(store.workouts.count, initialCount + 1)
    }
}
```

Run:

```bash
xcodebuild test -project LiftingLog.xcodeproj -scheme LiftingLog -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:LiftingLogTests/ActiveWorkoutStoreTests
```

Expected: build fails because `ActiveWorkoutStore` does not exist yet.

- [ ] **Step 2: Implement the active workout store**

Create `ActiveWorkoutStore.swift`:

```swift
import Foundation

@Observable
final class ActiveWorkoutStore: Identifiable {
    let id = UUID()
    let backingStore: MockWorkoutStore
    var draft: ActiveWorkoutDraft
    var expandedExerciseID: UUID?
    var startedAt: Date
    var finishedWorkout: Workout?

    init(store: MockWorkoutStore, now: Date = .now) {
        self.backingStore = store
        self.draft = .makeEmpty(now: now)
        self.startedAt = now
    }

    func addExercise(named name: String) {
        draft.addExercise(named: name)
        expandedExerciseID = draft.exercises.last?.id
    }

    func toggleExpandedExercise(_ id: UUID) {
        expandedExerciseID = expandedExerciseID == id ? nil : id
    }

    func finishWorkout(now: Date = .now) {
        let savedWorkout = Workout(
            id: UUID(),
            name: draft.name,
            date: draft.date,
            duration: now.timeIntervalSince(startedAt),
            exercises: draft.exercises.map {
                LoggedExercise(id: $0.id, name: $0.name, sets: $0.loggedSets, notes: "")
            }
        )
        backingStore.workouts.insert(savedWorkout, at: 0)
        finishedWorkout = savedWorkout
    }
}
```

- [ ] **Step 3: Run the active-workout-store tests**

Run:

```bash
xcodebuild test -project LiftingLog.xcodeproj -scheme LiftingLog -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:LiftingLogTests/ActiveWorkoutStoreTests
```

Expected: `** TEST SUCCEEDED **`

- [ ] **Step 4: Commit the active workout store**

```bash
git add LiftingLog/Features/ActiveWorkout/ActiveWorkoutStore.swift LiftingLogTests/Features/ActiveWorkoutStoreTests.swift LiftingLog/SampleData/MockWorkoutStore.swift LiftingLog.xcodeproj/project.pbxproj
git commit -m "feat: add active workout store logic"
```

### Task 8: Build The Active Workout Editor UI

**Files:**
- Create: `LiftingLog/Components/GlassSurface.swift`
- Create: `LiftingLog/Components/WorkoutTimerBar.swift`
- Create: `LiftingLog/Components/RPEControl.swift`
- Create: `LiftingLog/Components/MetadataPill.swift`
- Create: `LiftingLog/Features/ActiveWorkout/ActiveWorkoutScreen.swift`
- Create: `LiftingLog/Features/ActiveWorkout/ExerciseCardView.swift`
- Create: `LiftingLog/Features/ActiveWorkout/SetRowView.swift`
- Create: `LiftingLog/Features/ActiveWorkout/ExercisePickerSheet.swift`
- Modify: `LiftingLog/Features/StartWorkout/StartWorkoutScreen.swift`
- Modify: `LiftingLog.xcodeproj/project.pbxproj`

- [ ] **Step 1: Add reusable chrome and controls**

Create `GlassSurface.swift`:

```swift
import SwiftUI

struct GlassSurface<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
```

Create `WorkoutTimerBar.swift`:

```swift
import SwiftUI

struct WorkoutTimerBar: View {
    let startDate: Date

    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { context in
            let elapsed = context.date.timeIntervalSince(startDate)
            Text(Duration.seconds(elapsed).formatted(.time(pattern: .hourMinuteSecond)))
                .font(.headline.monospacedDigit())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(.regularMaterial, in: Capsule())
        }
    }
}
```

Create `RPEControl.swift`:

```swift
import SwiftUI

struct RPEControl: View {
    @Binding var selection: Double?

    private let values = stride(from: 6.0, through: 10.0, by: 0.5).map { $0 }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(values, id: \.self) { value in
                    Button(String(format: "%.1f", value)) {
                        selection = value
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(selection == value ? AppTheme.accent : .gray.opacity(0.2))
                }
            }
        }
    }
}
```

- [ ] **Step 2: Implement the active workout screen, exercise cards, and inline set rows**

Create `ActiveWorkoutScreen.swift`:

```swift
import SwiftUI

struct ActiveWorkoutScreen: View {
    @State var store: ActiveWorkoutStore
    @State private var showingExercisePicker = false

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16, pinnedViews: [.sectionHeaders]) {
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        TextField("Workout Name", text: $store.draft.name)
                            .textFieldStyle(.roundedBorder)

                        DatePicker("Date", selection: $store.draft.date, displayedComponents: .date)

                        ForEach(store.draft.exercises) { exercise in
                            ExerciseCardView(
                                exercise: exercise,
                                isExpanded: store.expandedExerciseID == exercise.id,
                                onToggle: { store.toggleExpandedExercise(exercise.id) }
                            )
                        }

                        Button("Add Exercise") {
                            showingExercisePicker = true
                        }
                        .buttonStyle(.glass)
                    }
                    .padding()
                } header: {
                    WorkoutTimerBar(startDate: store.startedAt)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        .background(.clear)
                }
            }
        }
        .navigationTitle("Active Workout")
        .sheet(isPresented: $showingExercisePicker) {
            ExercisePickerSheet(store: store)
        }
        .safeAreaInset(edge: .bottom) {
            Button("Finish Workout") {
                store.finishWorkout()
            }
            .buttonStyle(.glassProminent)
            .padding()
        }
        .navigationDestination(item: $store.finishedWorkout) { _ in
            WorkoutCompletionScreen()
        }
    }
}
```

Create `ExerciseCardView.swift`:

```swift
import SwiftUI

struct ExerciseCardView: View {
    let exercise: DraftExercise
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onToggle) {
                HStack {
                    Text(exercise.name).font(.headline)
                    Spacer()
                    Text("\(exercise.loggedSets.count) sets")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                ForEach(exercise.loggedSets) { set in
                    SetRowView(title: "Set", repsText: .constant(set.repsText), weightText: .constant(set.weightText), rpe: .constant(set.rpe))
                }
                SetRowView(
                    title: "Next",
                    repsText: .constant(exercise.draftSet.repsText),
                    weightText: .constant(exercise.draftSet.weightText),
                    rpe: .constant(exercise.draftSet.rpe)
                )
                MetadataPill(text: "Last time: 225 x 5 @ 8")
                Button("View Exercise History") { }
                    .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
```

Create `SetRowView.swift`:

```swift
import SwiftUI

struct SetRowView: View {
    let title: String
    @Binding var repsText: String
    @Binding var weightText: String
    @Binding var rpe: Double?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.subheadline.weight(.semibold))
            HStack {
                TextField("Reps", text: $repsText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                TextField("Weight", text: $weightText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)
            }
            RPEControl(selection: $rpe)
        }
    }
}
```

- [ ] **Step 3: Add the exercise picker sheet and wire recent exercises**

Create `ExercisePickerSheet.swift`:

```swift
import SwiftUI

struct ExercisePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var customName = ""
    let store: ActiveWorkoutStore

    var body: some View {
        NavigationStack {
            List {
                Section("Recent") {
                    ForEach(store.backingStore.recentExercises) { exercise in
                        Button(exercise.name) {
                            store.addExercise(named: exercise.name)
                            dismiss()
                        }
                    }
                }

                Section("Add New") {
                    TextField("Exercise Name", text: $customName)
                    Button("Add Exercise") {
                        guard !customName.isEmpty else { return }
                        store.addExercise(named: customName)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Add Exercise")
        }
    }
}
```

Create `MetadataPill.swift`:

```swift
import SwiftUI

struct MetadataPill: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
    }
}
```

Update `StartWorkoutScreen.swift` so the primary action opens the active workout flow once `ActiveWorkoutStore` exists:

```swift
import SwiftUI

struct StartWorkoutScreen: View {
    let store: MockWorkoutStore
    @State private var activeStore: ActiveWorkoutStore?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Button {
                    activeStore = ActiveWorkoutStore(store: store)
                } label: {
                    Label("Start Blank Workout", systemImage: "plus.circle.fill")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.glassProminent)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Recent Workouts").font(.headline)
                    ForEach(store.workouts.prefix(3)) { workout in
                        RecentWorkoutCard(workout: workout)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Start Workout")
        .navigationDestination(item: $activeStore) { activeStore in
            ActiveWorkoutScreen(store: activeStore)
        }
    }
}
```

- [ ] **Step 4: Run build verification and simulator validation on the core editor**

Run:

```bash
xcodebuild test -project LiftingLog.xcodeproj -scheme LiftingLog -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
xcodebuild -project LiftingLog.xcodeproj -scheme LiftingLog -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

Expected: `** TEST SUCCEEDED **` and `** BUILD SUCCEEDED **`

Confirm in simulator:

```text
Only the timer is pinned while scrolling.
Workout name and date scroll with the content above the exercise list.
Only one exercise card is expanded at a time.
Reps and weight use text fields.
RPE uses tap targets rather than text entry.
Completed sets stay in place.
The blank draft row is visible but does not create stored history on its own.
```

- [ ] **Step 5: Commit the active workout UI**

```bash
git add LiftingLog/Components LiftingLog/Features/ActiveWorkout LiftingLog/Features/StartWorkout/StartWorkoutScreen.swift LiftingLog.xcodeproj/project.pbxproj
git commit -m "feat: build active workout editor"
```

### Task 9: Finish Profile, Previews, And Final Verification

**Files:**
- Create: `LiftingLog/Features/Profile/ProfileScreen.swift`
- Modify: `LiftingLog/Features/History/HistoryScreen.swift`
- Modify: `LiftingLog/Features/StartWorkout/StartWorkoutScreen.swift`
- Modify: `LiftingLog/Features/ActiveWorkout/ActiveWorkoutScreen.swift`
- Modify: `LiftingLog/Features/History/WorkoutDetailScreen.swift`
- Modify: `LiftingLog.xcodeproj/project.pbxproj`

- [ ] **Step 1: Implement the profile placeholder screen**

Create `ProfileScreen.swift`:

```swift
import SwiftUI

struct ProfileScreen: View {
    var body: some View {
        List {
            Section("Preferences") {
                LabeledContent("Units", value: "Pounds")
                LabeledContent("RPE Scale", value: "6.0 - 10.0")
            }

            Section("App") {
                LabeledContent("Version", value: "1.0")
                LabeledContent("Build", value: "Local Prototype")
            }
        }
        .navigationTitle("Profile")
    }
}
```

- [ ] **Step 2: Add `#Preview` coverage to each primary screen**

Add preview blocks using `MockWorkoutStore.sample` and `ActiveWorkoutStore(store: .sample)` to:

```swift
#Preview {
    NavigationStack {
        HistoryScreen(store: .sample)
    }
}
```

```swift
#Preview {
    NavigationStack {
        StartWorkoutScreen(store: .sample)
    }
}
```

```swift
#Preview {
    NavigationStack {
        ActiveWorkoutScreen(store: ActiveWorkoutStore(store: .sample))
    }
}
```

```swift
#Preview {
    NavigationStack {
        WorkoutDetailScreen(workout: SampleFixtures.workouts[0])
    }
}
```

- [ ] **Step 3: Run the final full verification pass**

Run:

```bash
xcodebuild test -project LiftingLog.xcodeproj -scheme LiftingLog -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

Expected: `** TEST SUCCEEDED **`

Then run the app in the simulator and verify this full path:

```text
Launch into the Start Workout tab.
Open History and switch between Workout History and Exercise History.
Open a workout and confirm detail metadata and set information.
Return to Start Workout and begin a blank workout.
Add at least two exercises, expand each one, and confirm only one stays open at a time.
Finish the workout and land on the completion screen.
Return to History and confirm the finished workout appears at the top.
```

- [ ] **Step 4: Commit the polished prototype**

```bash
git add LiftingLog LiftingLogTests LiftingLog.xcodeproj/project.pbxproj
git commit -m "feat: finish lifting log prototype"
```

## Self-Review

### Spec Coverage

- Three-tab shell with `TabView` and per-tab `NavigationStack`: Tasks 2, 5, 6, 9
- History segmented control with workout and exercise history: Task 5
- Workout detail metadata and set detail: Task 5
- Start Workout root with primary blank-workout action and recent cards: Task 6
- Active workout timer-only sticky chrome, inline entry, one expanded exercise, text reps/weight, tap RPE, no blank persisted sets: Tasks 3, 7, 8
- Simple profile/settings placeholder: Task 9
- Completion screen and history insertion after finishing: Tasks 6, 7, 9
- Modular code structure and sample-data-first architecture: Tasks 2, 3, 4, 8, 9

### Placeholder Scan

- No `TODO`, `TBD`, or “implement later” placeholders remain in task steps.
- The recent workout cards are intentionally static inspiration cards in Task 6, matching the approved spec.
- Exercise history remains browse-only in Task 5, matching the approved spec.

### Type Consistency

- `MockWorkoutStore` is the shared in-memory dependency used by `LiftingLogApp`, `RootTabView`, `HistoryScreen`, `StartWorkoutScreen`, and `ActiveWorkoutStore`.
- `ActiveWorkoutDraft`, `DraftExercise`, and `DraftSet` are defined in Task 3 and reused consistently by `ActiveWorkoutStore` and the active editor UI.
- `Workout`, `LoggedExercise`, and `LoggedSet` are the saved-history models reused by sample fixtures, history views, and workout completion.
