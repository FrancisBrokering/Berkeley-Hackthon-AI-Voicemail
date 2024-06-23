import Foundation
import FirebaseAuth

class AgentManager: ObservableObject {
    
    // Singleton instance
    static let shared = AgentManager()
    
    @Published var agent: Agent? = nil
    @Published var isLoading = true
    var websocket: URLSessionWebSocketTask?
    var error: Error?
    
    // Function to fetch Agent Data with completion handler
    func fetchWakoAgent(withRetryCount retryCount: Int = 2, completion: @escaping (Bool) -> Void) {
        AgentAPI.getWakoAgent() { [weak self] (agentData) in
            DispatchQueue.main.async { // Ensure updates are on the main thread
                if let agentData = agentData {
                    self?.agent = agentData
                    completion(true)
                    self?.error = nil
                } else {
                    print("Failed to fetch agents")
                    if retryCount > 0 {
                        self?.fetchWakoAgent(withRetryCount: retryCount - 1, completion: completion)
                    } else {
                        self?.error = NSError(domain: "Failed to fetch agents", code: -1, userInfo: nil)
                        completion(false)
                    }
                }
            }
        }
    }
    
    func updateAgentConfiguration(newAgent: Agent, completion: @escaping (Bool) -> Void) {
        var accountManager = AccountManager.shared
        let tempAgent = self.agent
        self.agent = newAgent
        print("UPDATING AGENT!!!!!", newAgent.voice.model ?? newAgent.voice.voice_id ?? "No model or voice_id")

        print("agent.prompt.personality: ", newAgent.prompt.personality)

        // Safely serialize agentPrompt to JSON
        do {
            var agentName = newAgent.metadata["name"] as? String ?? ""

            var agentPrompt = generateAgentPrompt(plan: AccountManager.shared.plan, promptConfig: newAgent.prompt, agentName: agentName, userName: accountManager.userName)

            let agentPromptData = try JSONEncoder().encode(agentPrompt)
            guard let agentPromptJsonString = String(data: agentPromptData, encoding: .utf8) else {
                print("Error encoding agent prompt to JSON string")
                completion(false)
                return
            }

            // Create the voice dictionary based on the presence of model or voice_id
            var voiceDict: [String: Any] = [
                "provider": newAgent.voice.provider,
            ]

            if let model = newAgent.voice.model {
                voiceDict["model"] = model
            }
            if let voice_id = newAgent.voice.voice_id {
                voiceDict["voice_id"] = voice_id
            }
            print("VOICE: ", voiceDict)
            let updatedAgent: [String: Any] = [
                "initial_message": "\(newAgent.initial_message.greeting_message)",
                "prompt": agentPromptJsonString,
                "voice": voiceDict,
                "metadata": [
                    "name": agentName
                ]
            ]

            FirebaseAPI.updateAgentInitialMessage(initialMessageConfig: newAgent.initial_message) { success in
                if success {
                    FirebaseAPI.updateAgentPrompt(promptConfig: newAgent.prompt) { success in
                        if success {
                            AgentAPI.updateWakoAgent(agentId: newAgent.id, greetingMessage: newAgent.initial_message.greeting_message, agentRequestBody: updatedAgent) { updatedAgent in
                                DispatchQueue.main.async {
                                    if let updatedAgent = updatedAgent {
                                        self.agent = updatedAgent
                                        completion(true)
                                    } else {
                                        self.agent = tempAgent
                                        print("Failed to update agent with new configuration.")
                                        completion(false)
                                    }
                                }
                            }
                        } else {
                            self.agent = tempAgent
                            print("Failed to update agent prompt in Firebase.")
                            completion(false)
                        }
                    }
                } else {
                    self.agent = tempAgent
                    print("Failed to update agent initial message in Firebase.")
                    completion(false)
                }
            }
        } catch {
            self.agent = tempAgent
            print("An error occurred while encoding agent prompt: \(error)")
            completion(false)
        }
    }

}
