import Foundation

class CallsManager: ObservableObject {
    
    static let shared = CallsManager()
    
    @Published var liveCalls: [CallData] = []
    @Published var callHistory: [CallData] = []
    
    var unopenedCallsCount: Int {
        callHistory.filter { !$0.hasOpened }.count
    }
    
    static func fetchCallHistory(completion: @escaping (Bool) -> Void) {
        CallsAPI.getCallHistory() { fetchedCalls in
            DispatchQueue.main.async {
                if let calls = fetchedCalls {
                    let dateFormatter = ISO8601DateFormatter()
                    dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Add this line
                    let sortedCalls = calls.sorted(by: {
                        guard let date0 = dateFormatter.date(from: $0.startTime),
                              let date1 = dateFormatter.date(from: $1.startTime) else {
                            print("FAILD!!!!!!")
                            return false
                        }
                        // Compare startTime in reverse order
                        return date0 > date1
                    })
                    CallsManager.shared.callHistory = sortedCalls
                    completion(true)
                } else {
                    // Handle the error as needed, e.g., show an alert or a placeholder
                    CallsManager.shared.callHistory = []
                    print("Failed to fetch call history: ")
                    completion(false)
                }

            }
        }
    }


    //updates call history locally
    func updateCallHistory(call: CallData) {
        DispatchQueue.main.async {
            if let index = self.callHistory.firstIndex(where: { $0.id == call.id }) {
                self.callHistory[index] = call
            } else {
                self.callHistory.append(call)
            }
        }
    }
    
    static func addLiveCall(liveCall: CallData) {
        DispatchQueue.main.async {
            print("ADDED NEW CALL")
            if let index = shared.liveCalls.firstIndex(where: { $0.id == liveCall.id }) {
                // A call with the same conversation ID already exists
                print(index)
            } else {
                // The call doesn't exist; add it to the array
                shared.liveCalls.append(liveCall)
            }
        }
    }
    
    static func removeLiveCall(liveCall: CallData) {
        DispatchQueue.main.async {
            print("REMOVED NEW CALL")
            shared.liveCalls.removeAll { $0.id == liveCall.id }
        }
    }
    
    static func updateDialogueLiveCall(id: String, dialogue: [Message]) {
        DispatchQueue.main.async {
            print("UPDATED DIALOGUE")
            
            if let liveCall = shared.liveCalls.first(where: { $0.id == id }) {
                liveCall.messages = dialogue
                print("liveCalls:")
                print(shared.liveCalls)
            } else {
                print("Failed to find LiveCall with conversationId: \(id)")
            }
        }
    }
    
    static func convertToDialogue(from jsonObject: [String: Any]) -> [Message] {
        var messages: [Message] = []

        if let dialogueData = jsonObject["dialogue"] as? [String] {
            for messageString in dialogueData {
                if let messageData = messageString.data(using: .utf8) {
                    do {
                        let messageObject = try JSONSerialization.jsonObject(with: messageData, options: []) as? [String: String]
                        if let roleRawValue = messageObject?["role"],
                           let role = MessageRole(rawValue: roleRawValue),
                           let content = messageObject?["content"] {
                            messages.append(Message(role: role, content: content))
                        } else {
                            print("Failed to extract role or content from: \(messageString)")
                        }
                    } catch {
                        print("Error parsing inner JSON: \(messageString). Error: \(error)")
                    }
                } else {
                    print("Failed to convert message string to data: \(messageString)")
                }
            }
        } else {
            print("Failed at top-level parsing.")
        }
        
        return messages
    }
    
    static func fetchLiveCalls(completion: @escaping ([CallData]) -> Void) {
        CallsAPI.getLiveCalls() { fetchedCalls in
            DispatchQueue.main.async {
                if let calls = fetchedCalls {
                    shared.liveCalls = calls
                } else {
                    shared.liveCalls = []
                }
                completion(shared.liveCalls)
            }
        }
    }
}
