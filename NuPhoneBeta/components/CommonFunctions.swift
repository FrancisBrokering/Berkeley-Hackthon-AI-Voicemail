import SwiftUI
import Foundation

func triggerFeedback() {
    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
}
