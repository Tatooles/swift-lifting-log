# Active Workout Density Design

Date: 2026-04-19
Area: Active Workout editor
Platform: iPhone-only SwiftUI app

## Goal

Reduce the vertical space used by each exercise in the active workout editor so more sets fit on screen at once, while preserving the fast inline logging workflow.

This design specifically targets the expanded exercise editor inside the active workout flow. It does not attempt to redesign the whole screen or match the existing web UI exactly.

## Problem

The current active workout form is too tall per set because each editable row stacks:

- a set label
- two labeled text fields
- a full-width RPE control
- a per-set notes field

This makes each exercise expand into a long stack of cards, which slows scanning and makes repeated set entry feel heavier than it needs to.

## Approved Direction

The user-approved direction is:

- Keep the current always-visible editable draft row at the bottom of each expanded exercise.
- Make each set row read as a compact single line instead of a stacked mini-form.
- Keep RPE as always-visible inline buttons, but make the control smaller.
- Remove per-set notes from the active editor.
- Add one exercise-level notes field below the list of sets for that exercise.
- Place `History`, `Log Set`, and `Remove` on the same action row to save space.

## Layout

Each expanded exercise card should render in this order:

1. Compact prior-performance strip
2. Logged set rows
3. One always-visible editable draft row
4. Exercise notes field
5. Shared action row

The exercise stays visually grouped as one compact editor rather than a stack of independent cards.

### Set Rows

Each set row should fit on one horizontal line where practical. The target structure is:

- small set index
- compact weight field or value
- compact reps field or value
- compact inline RPE selector or value
- trailing remove affordance for editable/logged rows where removal is supported

Completed rows and the editable draft row should use the same basic structure so the exercise reads like one table with one active entry line.

The editable row remains the last row in the list at all times. Users should not need to press an add button before typing the next set.

### RPE

RPE remains directly visible in each editable row, but the control becomes denser than the current implementation.

The compact control should:

- use smaller tap targets than the current full-width buttons while still remaining usable on iPhone
- stay inline with the row instead of occupying its own block
- preserve quick single-tap selection
- continue to support clearing the selected RPE

The intent is to preserve speed while cutting height, not to hide RPE behind another interaction.

### Exercise Notes

Each exercise gets one notes field placed directly below its set rows.

This notes field represents the whole exercise, not an individual set. It should be visually subordinate to the set list so the logging workflow still centers on sets first.

## Behavior

### Draft Row

The current draft-row behavior stays in place:

- the bottom editable row is always visible
- entering reps, weight, or RPE materializes a pending set
- clearing the row back to blank removes the pending set
- tapping `Log Set` completes the pending set and leaves a fresh blank editable row at the bottom

This behavior is important because it keeps repeated set logging fast and predictable.

### Action Row

The bottom action row for each expanded exercise contains:

- `History`
- `Log Set`
- `Remove`

`Log Set` remains the primary action. `History` and `Remove` are secondary actions, but all three should fit on a single line in normal iPhone widths.

### Existing Screen Structure

This density pass does not change the broader active workout screen structure:

- workout title and date stay where they are
- exercise expansion behavior stays the same
- one exercise remains expanded at a time
- sticky timer and bottom screen-level action bar stay unchanged

## Data Model Impact

This should stay close to the current model instead of introducing a larger rewrite.

### Active Draft

The active editor should stop relying on per-set notes in normal entry flow. The draft model should add exercise-level draft notes on `DraftExercise`.

`DraftSet` should continue to represent only set-level entry state required by the compact row:

- reps
- weight
- RPE

### Saved Workout

Finished workouts should continue saving exercise-level notes through the existing `LoggedExercise.notes` property.

`LoggedSet.notes` may remain in the saved model for compatibility with sample data and history views, but this redesign should not expose per-set note editing in the active workout form.

## View Ownership

- `SetRowView` becomes the compact row renderer for both completed sets and the editable draft row.
- `ExerciseCardView` owns the exercise notes field and the compact shared action row.
- `RPEControl` is redesigned into a smaller inline-capable control rather than a full-width block.

## Testing

Tests should cover the behavioral rules that must remain true after the density refactor:

- draft-set materialization still happens when reps, weight, or RPE are entered
- clearing the editable row still removes the pending set
- exercise notes are stored at the exercise level in draft state
- finishing a workout persists exercise notes into `LoggedExercise.notes`
- workouts still exclude exercises that have no completed sets

UI verification should confirm:

- more set rows fit on screen than before
- the editable row remains immediately available at the bottom
- the single-line action row fits on standard iPhone widths
- compact RPE buttons remain easy to tap

## Out Of Scope

This design does not include:

- moving workout-level notes into the screen header or footer
- switching to an add-set-only interaction
- turning the action row into icon-only controls
- redesigning the sticky timer, screen header, or bottom workout bar
- changing history detail rendering beyond any minimal compatibility updates needed for model changes
