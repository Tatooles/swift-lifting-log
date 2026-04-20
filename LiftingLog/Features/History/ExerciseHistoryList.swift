import SwiftUI

struct ExerciseHistoryList: View {
    let exercises: [ExerciseDefinition]

    var body: some View {
        if exercises.isEmpty {
            ContentUnavailableView(
                "No Exercises",
                systemImage: "list.bullet",
                description: Text("Logged exercises will appear here.")
            )
        } else {
            ForEach(exercises) { exercise in
                Text(exercise.name)
            }
        }
    }
}
