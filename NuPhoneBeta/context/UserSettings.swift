import SwiftUI

class UserSettings: ObservableObject {
    @Published var instructionsCompleted: Bool {
        didSet {
            UserDefaults.standard.set(instructionsCompleted, forKey: "instructionStepCompleted12")
        }
    }

    init() {
        // Initialize with value from UserDefaults
        instructionsCompleted = UserDefaults.standard.bool(forKey: "instructionStepCompleted12")
    }
}
