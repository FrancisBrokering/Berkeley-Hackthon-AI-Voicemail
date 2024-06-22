import SwiftUI
import FirebaseAuth
import RiveRuntime

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    
    var body: some View {
        mainContent
    }
    
    private var mainContent: some View {
        if let agent = agentManager.agent {
            AgentView(agent: agent)
                .edgesIgnoringSafeArea(.bottom)
        }
    }
}
