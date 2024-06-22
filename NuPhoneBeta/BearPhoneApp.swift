import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth

@main
struct BearPhoneApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var sessionManager = SessionManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AgentManager.shared)
                .environmentObject(sessionManager)
                .environmentObject(appDelegate.appState)
        }
        
    }
}
