import SwiftUI
import FirebaseAuth
import RiveRuntime

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var networkMonitor = NetworkMonitor()
    @State private var agentName: String = ""
    @State private var selectedCarrier: String? = nil
    @EnvironmentObject var agentManager: AgentManager
    @ObservedObject var callsProvider = CallsManager.shared
    @StateObject var subscriptionManager = SubscriptionManager()
    @State private var ciclePositionRight: Bool = true
    @State private var isKeyboardShowing: Bool = false
    @State private var showInstructionView: Bool = false
    @ObservedObject var userManager = UserManager.shared
    @ObservedObject var accountManager = AccountManager.shared
    @State private var hasAgent = false
    @StateObject private var updateModal = AppUpdateModal()
    @StateObject private var adminMessageModal = AdminMessageModal()
    
    init() {
        UITabBar.appearance().isHidden = true
    }
    
    
    var body: some View {
        Group {
            if AgentManager.shared.isLoading {
                LoadingView()
                
            } else if Auth.auth().currentUser == nil || appState.currentView == .login || appState.currentView == .welcome{
                if appState.currentView == .login {
                    NavigationStack {
                        LoginView(selectedCarrier: $selectedCarrier)
                    }
                    .transition(.move(edge: .trailing))
                }
                else {
                    WelcomeView()
                        .transition(.move(edge: .trailing))
                }
            }
            else if appState.currentView == .nameUser {
                NameUserView()
                    .transition(.move(edge: .trailing))
            }
            else if appState.currentView == .createAgent {
                CreateAgentView(agentName: $agentName)
                    .transition(.move(edge: .trailing))
            }
            else if appState.currentView == .instruction {
                InstructionView()
                    .transition(.move(edge: .top))
            }
            else if appState.currentView == .error {
                ErrorView()
            }
            else if appState.currentView == .agent || appState.currentView == .phone || appState.currentView == .callHistory || appState.currentView == .liveCalls {
                mainContent
            }
            else {
                if agentManager.agent == nil {
                    NameUserView()
                        .transition(.move(edge: .trailing))
                }
                else {
                    mainContent
//                                                                        InstructionView()
                    //                            .transition(.move(edge: .trailing))
                    
                }
            }
        }
        .onChange(of: appState.currentView) { _ in
            if appState.currentView == .createAgent || appState.currentView == .nameUser || appState.currentView == .subscription{
                ciclePositionRight = true
            }
            else {
                ciclePositionRight.toggle()
            }
        }
        .animation(.spring(duration: 0.5), value: appState.currentView)
        .overlay {
            if appState.currentView == .subscription || appState.currentView == .nameUser || appState.currentView == .createAgent || appState.currentView == .login || appState.currentView == .instruction {
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification), perform: { _ in
            isKeyboardShowing = false
        })
        .environmentObject(subscriptionManager)
    }
    
    private var mainContent: some View {
        Group {
            ZStack{
                switch appState.currentTab {
                case .calls:
                    PhoneView()
                        .edgesIgnoringSafeArea(.bottom)
                case .assistant:
                    if let agent = agentManager.agent {
                        AgentView(agent: agent)
                            .edgesIgnoringSafeArea(.bottom)
                    }
                }
                
                if appState.displayNavBar {
                    VStack {
                        Spacer()
                        BottomNavBar(selectedTab: $appState.currentTab, badgeNumber: callsProvider.unopenedCallsCount)
                            .padding(.horizontal, 20)
                            .background(
                                LinearGradient(colors: [Color(.white).opacity(0), Color(.white)], startPoint: .top, endPoint: .bottom)
                                    .frame(height: 150)
                                    .frame(maxHeight: .infinity, alignment: .bottom)
                                    .allowsHitTesting(false)
                            )
                            .ignoresSafeArea()
                            .modifier(KeyboardResponsiveModifier())
                    }
                }
            }
        }
        .accentColor(Color("AccentColor"))
    }
}
