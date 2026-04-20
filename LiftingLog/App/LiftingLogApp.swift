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
