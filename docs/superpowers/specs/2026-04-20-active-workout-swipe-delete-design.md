# Active Workout Swipe Delete Design

Date: 2026-04-20
Area: Active Workout editor
Platform: iPhone-only SwiftUI app

## Goal

Replace explicit remove buttons in the active workout editor with native iOS swipe-to-delete interactions for both individual set rows and whole exercise cards.

This is a focused interaction update. It does not redesign the overall active workout screen or the compact row layout beyond what is needed to support swipe deletion cleanly.

## Problem

The current active workout editor still uses explicit destructive buttons inside the card:

- set deletion is not available through a native row gesture
- exercise deletion relies on a bottom-row `Remove` button

That makes deletion feel less iOS-native than the rest of the editor and costs visible space inside already-dense cards.

## Approved Direction

The user-approved direction is:

- add native trailing swipe actions to all set rows
- expose a destructive `Delete` action when a set row is swiped
- add native trailing swipe deletion for the entire exercise card
- remove the explicit bottom-row `Remove` button once card-level swipe delete exists
- keep the interaction system-native rather than building a custom drag reveal

## Interaction

### Set Rows

Every visible set row in the active editor should support native trailing swipe actions.

Swiping a row left should reveal a destructive `Delete` action. Tapping `Delete` removes that row’s underlying set data.

Per the current user instruction, this applies to all rows for now:

- completed logged rows
- the current editable draft row

This may change later when the draft-row model is reworked, but this design treats all current set rows as swipe-deletable.

Full-swipe delete should not be enabled by default. Users should explicitly tap the revealed destructive action to confirm intent.

### Exercise Cards

Each whole exercise card should also support native trailing swipe actions at the card level.

Swiping the card left should reveal a destructive `Delete` action that removes the entire exercise from the active workout.

This card-level gesture replaces the explicit `Remove` button in the shared action row.

## Liquid Glass Fit

The swipe interaction itself should remain system-native. The Liquid Glass alignment comes from the surrounding surfaces and control styling, not from replacing Apple’s swipe action behavior.

This means:

- use native SwiftUI swipe actions instead of custom drag logic
- keep destructive affordances visually standard and recognizable
- preserve or improve glass/grouped surfaces around rows and cards where appropriate
- avoid bespoke delete controls that compete with the platform’s interaction model

The goal is to feel more like modern iOS, not more custom.

## View Behavior

### Bottom Action Row

Once exercise-level swipe delete exists, the bottom action row should only contain current-workout actions:

- `Log Set`

`Remove` should be removed from that row entirely.

### Prior Performance And History

This change does not alter the previously approved history placement:

- `Full History` remains in the prior-performance block
- no history action returns to the bottom row

## Data And State

The store and draft model need explicit deletion support for sets.

### Set Deletion

The implementation should add a clear set-delete path that can remove:

- a completed logged set by identity
- the current editable draft/pending set

The deletion model must preserve the existing logging behavior:

- deleting one completed set should not disturb unrelated completed sets
- deleting the editable draft row should clear/remove the pending draft state correctly
- the always-visible editable row behavior should remain coherent after deletion

### Exercise Deletion

Exercise deletion can continue to use the existing exercise removal behavior already owned by the active workout store, but the trigger moves from an inline button to swipe actions on the card.

Expanded-state behavior should remain stable after exercise removal. If the removed exercise was expanded, the store should continue choosing the next available sensible expanded exercise as it does now.

## View Ownership

- `SetRowView` should support row-level swipe deletion hooks without taking on draft/store logic itself.
- `ExerciseCardView` should own the exercise-card swipe action and wire row delete closures into rendered set rows.
- `ActiveWorkoutStore` should own set and exercise deletion behavior.
- `ActiveWorkoutDraft` should expose the underlying mutation needed to remove the correct set backing data.

## Testing

Tests should cover:

- deleting a completed set removes only the targeted completed set
- deleting the editable draft row removes or clears the pending set state correctly
- deleting an exercise removes the whole card from the active workout draft
- expanded exercise selection remains valid after exercise deletion
- finishing a workout still excludes exercises with no completed sets after deletions

Manual UI verification should confirm:

- set rows reveal a native trailing `Delete` action on swipe
- exercise cards reveal a native trailing `Delete` action on swipe
- the bottom action row no longer shows `Remove`
- swipe interactions feel system-native and do not fight the compact layout

## Out Of Scope

This change does not include:

- reworking the draft-row model itself
- enabling full-swipe instant deletion
- adding undo banners or custom confirmation flows
- redesigning the prior-performance block or notes placement
- introducing custom drag gestures to mimic swipe actions
