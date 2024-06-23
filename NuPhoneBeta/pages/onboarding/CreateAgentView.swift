import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CreateAgentView: View {
    @EnvironmentObject var appState: AppState
    @Binding var agentName: String
    @State var errorMessage: String?
    @State private var isLoading = false
    @ObservedObject var agentManager = AgentManager.shared
    @ObservedObject var accountManager = AccountManager.shared
    @FocusState private var isKeyboardShowing: Bool
    let userId = UserManager.shared.currentUserId
    
    func createAgent(newAgentName: String, handleError: @escaping (Error) -> Void, completion: @escaping (Bool) -> Void) {
        AgentAPI.createWakoAgent(userName: accountManager.userName, agentName: agentName) { agent in
            if agent != nil {
                DispatchQueue.main.async {
                    AgentManager.shared.agent = agent
                    completion(true)
                }
            } else {
                completion(false)
            }
        }
        
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Create Assistant")
                .font(.largeTitle)
                .fontWeight(.heavy)
            
            Text("Name your assistant to continue")
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
                .padding(.top, -5)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "person")
                    .foregroundStyle(.gray)
                    .frame(width: 30)
                    .offset(y: 2)
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Assistant Name", text: $agentName)
                        .textContentType(.nickname)
                        .focused($isKeyboardShowing)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isKeyboardShowing = true
                        }
                    Divider()
                }
            }
            .padding(.top, 5)
            if isLoading {
                ProgressView()
            } else {
                GradientButton(title: "Continue", icon: "arrow.right", isLoading: $isLoading, onClick: {
//                        agentManager.agent?.name = agentName
                        if var metadata = agentManager.agent?.metadata {
                            metadata["name"] = agentName
                            agentManager.agent?.metadata = metadata
                        }

                        agentManager.agent?.initial_message.greeting_message = initialMessageBeginning + "\(accountManager.userName)" + initialMessageEnding
                        agentManager.agent?.initial_message.call_recorded_message = recordMessage
                        agentManager.updateAgentConfiguration(newAgent: agentManager.agent ?? defaultAgent) { success in
                            if success {
                                print("Agent configuration updated successfully.")
                                DispatchQueue.main.async {
                                    //                                    AgentManager.shared.agent = agent
                                    DispatchQueue.main.async {
                                        errorMessage = nil
                                        appState.currentView = .instruction
                                        appState.previousView = .createAgent
                                        if let user = Auth.auth().currentUser {
                                            let db = Firestore.firestore()
                                            db.collection("users").document(user.uid).updateData(["user_onboarded": true]) { error in
                                                if let error = error {
                                                    print("Error writing document: \(error)")
                                                } else {
                                                    print("Document successfully written!")
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                print("Failed to update agent configuration.")
                                DispatchQueue.main.async {
                                    isLoading = false
                                    errorMessage = "Something went wrong. Please try again."
                                }
                            }
                        }
                        //                        AgentAPI.createWakoAgent(userName: accountManager.userName, agentName: agentName) { agent in
                        //                            if agent != nil {
                        //                                DispatchQueue.main.async {
                        //                                    AgentManager.shared.agent = agent
                        //                                    DispatchQueue.main.async {
                        //                                        errorMessage = nil
                        //                                        appState.currentView = .instruction
                        //                                        appState.previousView = .createAgent
                        //                                    }
                        //                                }
                        //                            } else {
                        //                                DispatchQueue.main.async {
                        //                                    isLoading = false
                        //                                    errorMessage = "Something went wrong. Please try again."
                        //                                }
                        //                            }
                        //                        }
                })
                .hSpacing(.trailing)
                .disableWithOpacity(agentName.isEmpty)
            }
        }
        .padding(.horizontal, 30)
        .frame(maxHeight: .infinity)
        .overlay(
            ZStack {
                Button(action: {
                    //                    do {
                    //                        try Auth.auth().signOut()
                    appState.currentView = .nameUser
                    //                    }
                    //                    catch {
                    //
                    //                    }
                }) {
                    HStack {
                        Image(systemName: "arrowshape.backward.circle")
                            .font(.title)
                            .foregroundColor(Color("AccentColor"))
                        Text("Back")
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    }
                    .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                
            }
                .frame(height: 70)
                .frame(maxHeight: .infinity, alignment: .top)
        )
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done"){
                    isKeyboardShowing = false
                }
                .tint(Color("Orange"))
                .fontWeight(.heavy)
                .hSpacing(.trailing)
            }
        }
    }
}
