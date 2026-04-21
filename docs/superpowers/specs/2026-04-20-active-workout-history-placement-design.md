# Active Workout History Placement Design

Date: 2026-04-20
Area: Active Workout editor
Platform: iPhone-only SwiftUI app

## Goal

Trim unnecessary metadata from each expanded exercise card and move the history action into the prior-performance area where it has more context.

This is a focused follow-on adjustment to the active workout density work. It does not change the set-row structure, notes placement, or logging behavior.

## Problem

Two elements in the current compact exercise card still add noise:

- the `1 logged` chip in the header does not help the user take action
- the `History` button lives in the bottom action row instead of beside prior-performance information

That splits related history UI across the card and spends vertical and visual space on controls that are either redundant or poorly placed.

## Approved Direction

The user-approved direction is:

- remove the logged-count chip from the exercise header
- move the history action into the prior-performance section
- rename the action to `Full History`
- only show `Full History` when history actually exists
- keep the bottom action row focused on current-workout actions only

## Layout

### Header

The header should keep:

- exercise name
- expand/collapse affordance

The logged-count metadata pill should be removed entirely. No replacement badge is needed.

If the editable-set hint remains in the header, it should remain secondary to the title and should not reintroduce the old chip density. If it is not needed for clean layout, the header may reduce to just title and chevron.

### Prior Performance Block

When history exists, the prior-performance block should render:

- the existing prior-performance label and summary content
- a compact `Full History` button inside the same block

The `Full History` button should feel attached to the summary rather than the bottom action row. A trailing placement in the block is preferred so the summary remains readable and the history action is easy to discover.

When no history exists, the prior-performance block should remain as an informational empty state and should not render any history button.

## Behavior

`Full History` should open the same exercise history sheet currently used by the old `History` button. This is a relocation and rename only; the history detail flow does not change.

Because the button only appears when history exists:

- there should be no disabled history control in the card
- the empty-state prior-performance block remains informational only

The bottom action row should now contain only:

- `Log Set`
- `Remove`

## Data And State

No model or persistence changes should be required.

The existing `ExerciseCardView` state and `ActiveWorkoutStore` queries already provide what this update needs:

- prior-performance summary presence
- exercise history entries
- existing sheet presentation state for history

## Testing

Coverage should stay focused on preventing UI regression:

- verify the logged-count header chip no longer renders
- verify `Full History` appears only when history entries exist
- verify tapping `Full History` still presents the same exercise history flow
- verify the bottom action row no longer includes the old `History` button

Manual UI verification should confirm the exercise card reads cleaner and that the relocated history action feels naturally grouped with prior performance.

## Out Of Scope

This change does not include:

- changing the history detail screen itself
- changing set-row sizing or field proportions
- changing notes placement
- reworking workout-level controls outside the exercise card
