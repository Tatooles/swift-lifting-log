# Active Workout Swipe Card Cleanup Design

## Goal

Keep native iOS swipe-to-delete for both exercise rows and set rows while making each expanded exercise read as one coherent card instead of a stack of nested slabs.

## Problem

The current swipe-delete implementation uses native `List` rows, which is correct for system swipe actions, but the internal row chrome now conflicts with the swipe reveal:

- the exercise appears split into multiple white boxes when expanded
- swiping a row reveals the delete affordance against another rounded slab, which looks broken
- the overall result does not feel like a single exercise container

## Design

### Outer Card

Each exercise remains a `List` section so native swipe actions continue to work. Visually, though, the section should read as one outer card:

- collapsed: one rounded exercise card containing only the header
- expanded: one rounded exercise card whose top row is the header and whose interior contains the rest of the exercise content

The outer card is the only large card-level surface inside an exercise.

### Internal Content

The expanded content becomes mostly flat within that outer card:

- prior performance is flat content, not a nested card
- set rows do not get outer slab backgrounds
- notes do not get a large floating section card
- the bottom action row stays inside the same outer surface

The only rounded controls inside the card should be the elements that need direct input or button affordance:

- weight field capsule
- reps field capsule
- RPE field capsule
- notes input treatment, if any field chrome is retained
- `Full History` button
- `Log Set` button

### Swipe Behavior

Native trailing swipe actions remain unchanged:

- swiping the exercise header deletes the whole exercise
- swiping a set row deletes only that set

Because the internal rows become flat, the swipe reveal should look like a normal iOS destructive action instead of fighting another rounded panel.

## Implementation Notes

This is a view-only cleanup. No model or store behavior changes are required.

Primary files:

- `LiftingLog/Features/ActiveWorkout/ExerciseCardView.swift`
- `LiftingLog/Features/ActiveWorkout/SetRowView.swift`

The current row-position helper for unified top/middle/bottom exercise chrome can stay. The change is to reduce or remove the internal row-level slab backgrounds while preserving the outer exercise shell and existing swipe hooks.

## Testing

Keep verification lightweight and focused:

- preserve the existing row chrome position unit test
- rerun active workout store tests to ensure swipe-delete backing behavior is unchanged
- rerun the full test suite and simulator build

## Non-Goals

- changing the delete interaction model
- changing draft set persistence rules
- redesigning the compact field capsules
- removing `List`-based native swipe behavior
