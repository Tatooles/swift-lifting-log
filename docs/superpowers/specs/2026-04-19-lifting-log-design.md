# Lifting Log iOS App Design

Date: 2026-04-19
Platform: iPhone-only
Minimum OS: iOS 26
UI Framework: SwiftUI

## Goal

Build a native-feeling iOS lifting log app focused on fast workout entry. The first version is local-only, uses mock and sample data, and is structured for rapid screen-by-screen iteration. The app should feel strongly aligned with modern Apple conventions rather than branded like a typical fitness app.

## Scope

Version 1 includes:

- A three-tab shell with History, Start Workout, and Profile.
- Workout history and workout detail browsing.
- Exercise history as a simple exercise list.
- A start workout screen centered on starting a blank workout.
- A high-speed active workout editor optimized for logging sets inline.
- A minimal workout completion screen.
- Sample data and in-memory state only.

Version 1 does not include:

- Backend sync or accounts.
- Persistent local storage.
- Saved workout templates as a full feature.
- Programmed plans or coaching logic.
- Advanced analytics.

Recent workouts may be shown on the start screen as future-facing mock template-style shortcuts, but the core logging flow is freeform.

## Product Principles

- Prioritize speed of entry over visual novelty.
- Use native iOS layout, list, form, and navigation patterns.
- Keep editing on one screen where possible.
- Reduce row movement and modal interruptions during logging.
- Use Liquid Glass moderately in chrome, not as a full-surface design language.

## App Shell

The app uses a `TabView` with three top-level tabs:

1. History
2. Start Workout
3. Profile

Each tab owns its own `NavigationStack` so tab history is isolated and predictable. The center tab, Start Workout, is treated as the primary action through iconography, spacing, and glass-accented chrome, but it remains a standard native tab rather than a custom floating control.

### History Tab

The root history screen uses a segmented control with:

- Workout History
- Exercise History

Workout History shows a list of prior workouts. Selecting one pushes Workout Detail.

Exercise History shows a simple list of exercise names. In version 1, rows are browse-only and do not push into a separate exercise detail screen.

### Start Workout Tab

The root start screen contains:

- A prominent Start Blank Workout action.
- A list of recent workouts underneath, presented as static quick-start inspiration cards that do not implement true templating behavior yet.

Starting a blank workout pushes the Active Workout screen.

### Profile Tab

Profile is a simple settings-style screen with grouped rows for app preferences, app information, and static version/about content.

## Screen Designs

## 1. Workout History Screen

This screen is a vertically scrolling list of previous workouts. Each row shows:

- Workout name
- Date
- Duration

Rows should feel like native iOS history cells: readable typography, compact metadata, and a clear tap target to enter detail.

## 2. Workout Detail Screen

This screen shows summary metadata at the top:

- Workout name
- Date
- Duration

Below that is a list of exercises included in the workout. Each exercise section shows:

- Exercise name
- Sets
- Reps
- Weight
- RPE
- Notes

The layout should favor scanning rather than editing. This is a read-focused detail screen.

## 3. Start Workout Screen

This screen is the workout entry gateway. The hierarchy is:

- Primary Start Blank Workout control near the top
- Recent workouts list underneath

The start action must read as the dominant element on screen. Recent workouts can use simple cards or rows that suggest future quick-start flows without requiring a full template system yet.

## 4. Active Workout Screen

This is the core screen of the app and the highest-priority surface.

### Top Region

Only the running timer remains sticky while the user scrolls.

Above the exercise list, the screen also includes:

- Editable workout name
- Editable workout date

The sticky timer can use moderate Liquid Glass treatment to distinguish it from the scrolling editor below. The workout name and date should live in the normal scroll content so the pinned chrome stays compact.

### Exercise List

The workout contains a vertical list of exercises. Exactly one exercise is expanded at a time. All other exercises remain collapsed into compact summaries.

Collapsed exercise rows should show enough information to identify the lift and current progress without overwhelming the screen.

### Expanded Exercise

The expanded exercise contains:

- Set rows
- Reps text input
- Weight text input
- Tap-based RPE control
- Notes access
- Compact prior performance summary
- A control to open full exercise history

The editing model favors inline entry. Reps and weight use text entry for speed and flexibility. RPE uses tap-based controls so it is faster than typed entry.

### Set Row Behavior

Completed sets remain in place. The UI should not reorder or aggressively collapse completed entries, because stable placement supports fast repeated logging between sets.

Each expanded exercise always shows one draft row at the bottom. That draft row becomes a persisted set only after the user enters some value. If the row stays untouched, it is not stored. This satisfies the requirement to avoid persisting blank sets while preserving fast entry.

### Exercise Creation

Adding exercises is recent-list-first:

- Choose from recent/common exercises
- Or type a new exercise name immediately

This avoids the weight of a master exercise catalog while staying fast for recurring lifts.

## 5. Exercise History Screen

This screen is a simple list of exercise names. It lives behind the history segmented control. The active workout screen can link into this list or a closely related exercise-history destination using the same underlying sample data.

## 6. Workout Completion Screen

This is a minimal confirmation screen shown after finishing a workout. It should acknowledge completion and offer a clean route back into the app. It should not introduce extra ceremony.

## Architecture

The app uses feature-scoped state and models rather than a single large global store or a heavy MVVM stack.

### Root Ownership

A small root app model owns:

- Tab selection
- Shared sample/mock store
- Creation of new active workout drafts

### Feature Ownership

Each feature owns its own focused state:

- History reads from the local mock store.
- Start Workout creates and routes into a new workout draft.
- Active Workout owns mutation-heavy draft editing logic.
- Profile owns only simple local settings-display state.

This keeps the most complex flow, Active Workout, isolated from simpler browsing screens while still making previews and local iteration straightforward.

## Domain Models

Version 1 should start with lightweight local models such as:

- `Workout`
- `LoggedExercise`
- `LoggedSet`
- `ExerciseDefinition`
- `ActiveWorkoutDraft`
- `DraftExercise`
- `DraftSet`

The draft types are separate from saved workout history types so the editor can support transient rows, partial entry, and inline mutations without forcing history models to carry editing-only state.

## Suggested File Structure

```text
LiftingLog/
  App/
  Models/
  SampleData/
  Components/
  Features/
    History/
    StartWorkout/
    ActiveWorkout/
    Profile/
```

Within features, each major screen and its local reusable subviews should live together so the project is easy to evolve screen by screen.

## UI And Styling

The visual language should be strongly iOS-native:

- `NavigationStack` and large-title navigation where appropriate
- `TabView` for the main shell
- Native lists, forms, grouped sections, and toolbars
- System typography and spacing
- Subtle material and Liquid Glass in high-value chrome only

Liquid Glass should be applied primarily to:

- Tab bar presentation and supporting chrome
- Sticky active workout timer
- Select primary controls where it improves affordance

Main content surfaces should remain visually quiet to preserve scanning speed and touch clarity.

## Preview And Iteration Strategy

Every major screen should be previewable using central sample fixtures. The project should support iterating on each screen independently with mock state, without requiring real persistence or networking.

Sample data should include:

- Several completed workouts
- A few repeated exercises with prior performance
- An in-progress workout draft with multiple exercises and sets

## Error Handling And Empty States

Because version 1 is local and mock-driven, error handling is minimal. The focus is on clear empty states and safe defaults:

- History shows a no-workouts-yet empty state when there are no workouts.
- Exercise history can show an empty message when there are no logged exercises.
- Start Workout should remain useful even with no recent workouts.

The active workout editor should prefer graceful local validation over blocking alerts. Blank draft sets should simply never materialize into stored state.

## Testing Strategy

Version 1 should emphasize:

- Preview coverage for primary screens and key states
- Lightweight unit coverage for draft-model behavior if added early
- Manual simulator validation of navigation and workout-entry flows

The most important behavior to validate is the active workout screen:

- Only one exercise expands at a time
- Draft set rows persist only after data entry
- Completed rows remain stable
- Timer remains accessible while scrolling
- Workout name and date remain visible in the main content area above the exercise list

## Open Decisions Deferred Intentionally

These items are explicitly out of scope for version 1 and should not shape the initial architecture beyond keeping extension points clean:

- Persistent storage
- Saved templates
- Exercise library management
- Exercise detail analytics
- Cloud sync

## Recommended First Implementation Slice

The first implementation pass should build:

1. App shell with tabs and navigation
2. Shared models and sample data
3. History tab and workout detail
4. Start Workout screen
5. Active Workout screen and editing interactions
6. Profile screen
7. Workout completion flow

This sequence establishes the shell and history quickly, then focuses engineering effort on the active workout experience, which is the defining workflow of the app.
