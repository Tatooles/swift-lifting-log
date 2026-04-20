import SwiftUI

enum AppTab: Hashable, CaseIterable {
    case history
    case startWorkout
    case profile

    var title: String {
        switch self {
        case .history:
            "History"
        case .startWorkout:
            "Start Workout"
        case .profile:
            "Profile"
        }
    }

    var systemImage: String {
        switch self {
        case .history:
            "clock.arrow.circlepath"
        case .startWorkout:
            "plus.circle.fill"
        case .profile:
            "person.crop.circle"
        }
    }
}
