# Active Workout Density Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor the active workout editor so each exercise uses compact inline set rows, exercise-level notes, and a single shared action row without breaking draft logging behavior.

**Architecture:** Keep the existing `ActiveWorkoutStore` and draft-model flow, but move editable notes ownership from `DraftSet` to `DraftExercise`. `SetRowView` becomes a dense row renderer for both logged and editable sets, `ExerciseCardView` owns the exercise notes field and single-line actions, and the store continues materializing the pending draft row from reps, weight, and RPE only.

**Tech Stack:** SwiftUI, Observation, XCTest, Xcodebuild

---

## Planned File Map

- `docs/superpowers/specs/2026-04-19-active-workout-density-design.md` — approved design reference.
- `LiftingLog/Models/ActiveWorkoutDraft.swift` — draft exercise notes state and draft-set blank rules.
- `LiftingLog/Models/Workout.swift` — saved model compatibility for exercise-level notes and legacy set notes.
- `LiftingLog/Features/ActiveWorkout/ActiveWorkoutStore.swift` — exercise-note mutations, finish-workout persistence.
- `LiftingLog/Features/ActiveWorkout/ExerciseCardView.swift` — compact expanded exercise layout, exercise notes field, action row.
- `LiftingLog/Features/ActiveWorkout/SetRowView.swift` — single-line compact set row layout.
- `LiftingLog/Components/RPEControl.swift` — compact inline RPE button strip.
- `LiftingLog/Features/ActiveWorkout/ActiveWorkoutScreen.swift` — preview data updates for exercise-level notes.
- `LiftingLogTests/Models/ActiveWorkoutDraftTests.swift` — draft row and exercise-notes state behavior.
- `LiftingLogTests/Features/ActiveWorkoutStoreTests.swift` — finish-workout note persistence and exercise filtering.

### Task 1: Move Active Notes To The Exercise Level

**Files:**
- Modify: `LiftingLog/Models/ActiveWorkoutDraft.swift`
- Modify: `LiftingLog/Features/ActiveWorkout/ActiveWorkoutStore.swift`
- Modify: `LiftingLogTests/Models/ActiveWorkoutDraftTests.swift`
- Modify: `LiftingLogTests/Features/ActiveWorkoutStoreTests.swift`

- [ ] **Step 1: Write the failing tests for exercise-level notes**

Add these tests to `LiftingLogTests/Models/ActiveWorkoutDraftTests.swift` and `LiftingLogTests/Features/ActiveWorkoutStoreTests.swift`:

```swift
func testStoresExerciseNotesOnDraftExercise() throws {
    var draft = ActiveWorkoutDraft.makeEmpty()
    draft.addExercise(named: "Bench Press")
    let exerciseID = try XCTUnwrap(draft.exercises.first?.id)

    draft.updateExerciseNotes(for: exerciseID, notes: "Harder to grip the hex DB")

    XCTAssertEqual(draft.exercises[0].notes, "Harder to grip the hex DB")
}
```

```swift
func testFinishWorkoutPersistsExerciseNotes() throws {
    let store = ActiveWorkoutStore(store: .sample, now: Date(timeIntervalSinceReferenceDate: 1000))
    XCTAssertTrue(store.addExercise(named: "Bench Press"))
    let exerciseID = try XCTUnwrap(store.draft.exercises.first?.id)

    store.updateEditableSet(for: exerciseID, repsText: "5", weightText: "225", rpe: .some(8), notes: nil)
    store.completePendingSet(for: exerciseID)
    store.updateExerciseNotes(for: exerciseID, notes: "Paused first rep")

    XCTAssertTrue(store.finishWorkout(now: Date(timeIntervalSinceReferenceDate: 1120)))
    XCTAssertEqual(store.finishedWorkout?.exercises.first?.notes, "Paused first rep")
}
```

- [ ] **Step 2: Run the targeted tests to verify they fail**

Run:

```bash
xcodebuild test -project LiftingLog.xcodeproj -scheme LiftingLog -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:LiftingLogTests/ActiveWorkoutDraftTests -only-testing:LiftingLogTests/ActiveWorkoutStoreTests
```

Expected: FAIL because `updateExerciseNotes` does not exist and the store does not persist draft exercise notes.

- [ ] **Step 3: Implement the minimal model and store changes**

Update `LiftingLog/Models/ActiveWorkoutDraft.swift` so `DraftExercise` owns notes and `DraftSet` no longer treats notes as part of draft-set state:

```swift
struct DraftExercise: Identifiable, Hashable {
    let id: UUID
    var name: String
    var loggedSets: [LoggedSet]
    var draftSet: DraftSet
    var notes: String = ""
}

struct DraftSet: Hashable {
    var repsText: String = ""
    var weightText: String = ""
    var rpe: Double?

    var isBlank: Bool {
        repsText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && weightText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && rpe == nil
    }
}
```

Add `updateExerciseNotes(for:notes:)` to both the draft and the store, and persist `exercise.notes` into `LoggedExercise.notes` inside `finishWorkout(...)`.

- [ ] **Step 4: Run the same tests to verify they pass**

Run:

```bash
xcodebuild test -project LiftingLog.xcodeproj -scheme LiftingLog -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:LiftingLogTests/ActiveWorkoutDraftTests -only-testing:LiftingLogTests/ActiveWorkoutStoreTests
```

Expected: PASS for the new exercise-notes tests and the existing draft-set tests.

- [ ] **Step 5: Commit the model/store refactor**

```bash
git add LiftingLog/Models/ActiveWorkoutDraft.swift LiftingLog/Features/ActiveWorkout/ActiveWorkoutStore.swift LiftingLogTests/Models/ActiveWorkoutDraftTests.swift LiftingLogTests/Features/ActiveWorkoutStoreTests.swift
git commit -m "refactor: move active notes to exercise level"
```

### Task 2: Compress The Set Row And RPE Control

**Files:**
- Modify: `LiftingLog/Features/ActiveWorkout/SetRowView.swift`
- Modify: `LiftingLog/Components/RPEControl.swift`

- [ ] **Step 1: Write a failing test for the remaining compact-row behavior**

Add this test to `LiftingLogTests/Models/ActiveWorkoutDraftTests.swift`:

```swift
func testTreatsRPEOnlyInputAsMaterializedPendingSet() throws {
    var draft = ActiveWorkoutDraft.makeEmpty()
    draft.addExercise(named: "Incline Curl")
    let exerciseID = try XCTUnwrap(draft.exercises.first?.id)

    draft.updateDraftSet(
        for: exerciseID,
        repsText: "",
        weightText: "",
        rpe: 8,
        notes: ""
    )

    XCTAssertEqual(draft.exercises[0].loggedSets.count, 1)
    XCTAssertEqual(draft.exercises[0].loggedSets[0].rpe, 8)
}
```

- [ ] **Step 2: Run the single test to verify it fails only if needed**

Run:

```bash
xcodebuild test -project LiftingLog.xcodeproj -scheme LiftingLog -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:LiftingLogTests/ActiveWorkoutDraftTests/testTreatsRPEOnlyInputAsMaterializedPendingSet
```

Expected: If the behavior already exists, this test passes immediately and no model change is needed for this task. Otherwise it should fail because the compact-row input path does not preserve RPE-only materialization.

- [ ] **Step 3: Implement the compact row layout**

Update `SetRowView.swift` to use a single-line structure like:

```swift
HStack(spacing: 10) {
    Text("\(setNumber)")
        .font(.caption.weight(.semibold))
        .foregroundStyle(.secondary)
        .frame(width: 18)

    metricField("Weight", text: weightText, keyboardType: .decimalPad, onChange: onWeightChange)
    metricField("Reps", text: repsText, keyboardType: .numberPad, onChange: onRepsChange)

    RPEControl(selectedRPE: rpe, onSelect: onRPEChange)

    if showsDeleteAction {
        Button(role: .destructive, action: onDelete) {
            Image(systemName: "trash")
        }
        .buttonStyle(.plain)
    }
}
```

Update `RPEControl.swift` so it renders a compact inline strip, for example:

```swift
HStack(spacing: 4) {
    ForEach(values, id: \.self) { value in
        Button {
            onSelect(selectedRPE == value ? nil : value)
        } label: {
            Text(value.formatted(.number.precision(.fractionLength(0))))
                .font(.caption.weight(.semibold))
                .frame(minWidth: 28)
                .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}
```

- [ ] **Step 4: Run the draft test suite to verify behavior still passes**

Run:

```bash
xcodebuild test -project LiftingLog.xcodeproj -scheme LiftingLog -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:LiftingLogTests/ActiveWorkoutDraftTests
```

Expected: PASS. The UI layout change must not break draft-set materialization rules.

- [ ] **Step 5: Commit the compact row refactor**

```bash
git add LiftingLog/Features/ActiveWorkout/SetRowView.swift LiftingLog/Components/RPEControl.swift LiftingLogTests/Models/ActiveWorkoutDraftTests.swift
git commit -m "feat: compact active workout set rows"
```

### Task 3: Move Exercise Notes And Actions Into The Exercise Card

**Files:**
- Modify: `LiftingLog/Features/ActiveWorkout/ExerciseCardView.swift`
- Modify: `LiftingLog/Features/ActiveWorkout/ActiveWorkoutScreen.swift`

- [ ] **Step 1: Build the exercise-level notes field and shared action row**

In `ExerciseCardView.swift`, remove per-set note wiring from `SetRowView` calls and add an exercise notes field under the set list:

```swift
TextField(
    "Exercise notes",
    text: Binding(
        get: { exercise.notes },
        set: { store.updateExerciseNotes(for: exercise.id, notes: $0) }
    ),
    axis: .vertical
)
.lineLimit(1 ... 3)
```

Replace the stacked action buttons with one row:

```swift
HStack(spacing: 10) {
    Button("History") { isHistoryPresented = true }
        .buttonStyle(.bordered)

    Button {
        store.completePendingSet(for: exercise.id)
    } label: {
        Label("Log Set", systemImage: "checkmark.circle.fill")
            .frame(maxWidth: .infinity)
    }
    .buttonStyle(.borderedProminent)

    Button("Remove", role: .destructive) {
        store.removeExercise(exercise.id)
    }
    .buttonStyle(.bordered)
}
```

- [ ] **Step 2: Update preview and sample editor state**

Adjust `ActiveWorkoutScreen.swift` previews so exercise-level notes are written with `updateExerciseNotes(...)` instead of draft-set notes, and keep the sample expanded exercise populated enough to visually exercise the denser layout.

- [ ] **Step 3: Run a build to verify the SwiftUI changes compile**

Run:

```bash
xcodebuild -project LiftingLog.xcodeproj -scheme LiftingLog -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 4: Commit the exercise-card UI update**

```bash
git add LiftingLog/Features/ActiveWorkout/ExerciseCardView.swift LiftingLog/Features/ActiveWorkout/ActiveWorkoutScreen.swift
git commit -m "feat: add compact active workout exercise editor"
```

### Task 4: Final Verification

**Files:**
- Modify: `LiftingLog/Features/ActiveWorkout/ExerciseCardView.swift` (only if verification exposes layout regressions)
- Modify: `LiftingLog/Features/ActiveWorkout/SetRowView.swift` (only if verification exposes layout regressions)
- Modify: `LiftingLog/Components/RPEControl.swift` (only if verification exposes layout regressions)

- [ ] **Step 1: Run the full test suite**

Run:

```bash
xcodebuild test -project LiftingLog.xcodeproj -scheme LiftingLog -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

Expected: `** TEST SUCCEEDED **`

- [ ] **Step 2: Run a final build**

Run:

```bash
xcodebuild -project LiftingLog.xcodeproj -scheme LiftingLog -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Commit any verification-driven cleanup**

```bash
git add LiftingLog docs/superpowers/plans/2026-04-19-active-workout-density-implementation.md LiftingLogTests
git commit -m "test: verify active workout density refactor"
```
