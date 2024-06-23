import SwiftUI


//This modifier is used to hide the nav bar at the bottom when the keyboard is being displayed
struct KeyboardResponsiveModifier: ViewModifier {
    @State private var isVisible = true

    func body(content: Content) -> some View {
        content
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                    isVisible = false
                }

                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    isVisible = true
                }
            }
            .opacity(isVisible ? 1 : 0)
            .animation(.easeInOut, value: isVisible)
    }
}
