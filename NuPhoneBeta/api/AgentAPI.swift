import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class AgentAPI {
    static func parseAgentPrompt(from promptString: String) -> (system_message: String, prompt: String, personality: [String]) {
        let pattern = "#\\*\\*(.*?): (.*?)\\*\\*#"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let nsString = promptString as NSString
        let results = regex.matches(in: promptString, options: [], range: NSRange(location: 0, length: nsString.length))
        
        var system_message = ""
        var prompt = ""
        var personality = [String]()
        
        for result in results {
            if result.numberOfRanges == 3 {
                let keyRange = result.range(at: 1)
                let valueRange = result.range(at: 2)
                let key = nsString.substring(with: keyRange).uppercased()
                let value = nsString.substring(with: valueRange)
                print("VALUE: ", value)
                print("KEY: ", key)
                switch key {
                case "SYSTEM_MESSAGE":
                    system_message = value
                case "PROMPT":
                    prompt = value
                    .replacingOccurrences(of: "\\n", with: "\n")
                    .trimmingCharacters(in: CharacterSet(charactersIn: "\"").union(.whitespacesAndNewlines))
                case "PERSONALITY":
                    // The original approach to extract the JSON string directly is kept,
                    // but the parsing logic is adjusted to properly handle the escaped quotes.
                    
                    // Attempt to parse the JSON string correctly handling escaped characters
                    if let data = value.data(using: .utf8) {
                        do {
                            let jsonArray = try JSONSerialization.jsonObject(with: data, options: [])
                            if let array = jsonArray as? [String] {
                                personality = array
                            } else {
                                print("Failed to cast JSON object to [String]")
                            }
                        } catch {
                            print("JSON Parsing Error: \(error.localizedDescription)")
                        }
                    }
                default:
                    break
                }
            }
        }
        
        return (system_message, prompt, personality)
    }
    
    static func transferCall(id: String) {
        let endpoint = Constants.baseURL.appendingPathComponent("calls").appendingPathComponent("transfer").appending(queryItems: [URLQueryItem(name: "id", value: id)])
        var request = URLRequest(url: endpoint)
        request.httpMethod = "GET"
        if let subAccountApiKey = UserManager.shared.subAccountApiKey {
            request.setValue(subAccountApiKey, forHTTPHeaderField: "X-API-KEY")
        }
        else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, error == nil, httpResponse.statusCode == 200 else {
                print("Error:", error ?? "Unknown error @ transferCall")
                return
            }
        }
        task.resume()
    }
    
    
    
    static func createWakoAgent(userName: String, agentName: String, completion: @escaping (Agent?) -> Void) {
        var promptConfig = PromptConfig()
        var generatedPrompt = generateAgentPrompt(plan: AccountManager.shared.plan, promptConfig: promptConfig, agentName: agentName, userName: userName)
        let newAgent: [String: Any] = [
            "initial_message": initialMessageBeginning + "\(userName)" + initialMessageEnding + " \(recordMessage)",
            "prompt": generatedPrompt,
            "voice" : [
                "provider": "azure",
                "model": "en-US-JennyMultilingualNeural",
            ],
            "metadata": [
                "name": agentName
            ]
        ]
        let agentURL = Constants.baseURL.appendingPathComponent("agents")
        
        var agentRequest = URLRequest(url: agentURL)
        agentRequest.httpMethod = "POST"
        agentRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let subAccountApiKey = UserManager.shared.subAccountApiKey {
            agentRequest.setValue(subAccountApiKey, forHTTPHeaderField: "X-API-KEY")
        }
        else {
            completion(nil)
            return
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: newAgent, options: [])
            agentRequest.httpBody = jsonData
        } catch {
            print("Error serializing agent agentBody:", error)
            completion(nil)
            return
        }
        let agentTask = URLSession.shared.dataTask(with: agentRequest) { data, response, error in
            guard let _ = response as? HTTPURLResponse, error == nil else {
                print("Error:", error ?? "Unknown error @ createWakoAgent")
                completion(nil)
                return
            }
            
            guard let data = data,
                  let agent = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                print("Error parsing the agent response")
                completion(nil)
                return
            }
            
            guard let agentVoice = agent["voice"] as? [String: Any] else {
                fatalError("Agent config is missing or of the wrong type!")
            }
            
            let newVoice = Voice(
                name: AvailableVoice.name(for:agentVoice["model"] as? String ?? "") ?? "Casey",
                provider: agentVoice["provider"] as? String ?? "",
                model: agentVoice["model"] as? String ?? ""
            )
            
            let initialMessage = InitialMessage(
                greetingMessage: initialMessageBeginning + "\(userName)" + initialMessageEnding
            )
            
            let newAgent = Agent(
                initialMessage: initialMessage,
                prompt: promptConfig,
                voice: newVoice,
                id: agent["id"] as? String ?? "",
                uri: agent["uri"] as? String ?? "",
                accountId: agent["account_id"] as? String ?? "",
                createdAt: agent["created_at"] as? String ?? "",
                updatedAt: agent["updated_at"] as? String ?? "",
                metadata: agent["metadata"] as? [String: Any] ?? [:]
            )
            FirebaseAPI.updateAgentPrompt(promptConfig: newAgent.prompt) { success in}
            FirebaseAPI.updateAgentInitialMessage(initialMessageConfig: newAgent.initial_message){ success in}
            completion(newAgent)
        }
        
        agentTask.resume()
    }
    
    static func getWakoAgent(completion: @escaping (Agent?) -> Void) {
        let serverUrl = Constants.baseURL.appendingPathComponent("agents/")
        
        var request = URLRequest(url: serverUrl)
        request.httpMethod = "GET"
        if let subAccountApiKey = UserManager.shared.subAccountApiKey {
            request.setValue(subAccountApiKey, forHTTPHeaderField: "X-API-KEY")
        } else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, error == nil else {
                print("Error:", error ?? "Unknown error @ getWakoAgent")
                completion(nil)
                return
            }
            guard let data = data else {
                print("Error: No data")
                completion(nil)
                return
            }
            
            do {
                if let agentData = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let agents = agentData["items"] as? [[String: Any]],
                   let agent = agents.first {
                    
                    guard let agentVoice = agent["voice"] as? [String: Any] else {
                        fatalError("Agent voice is missing or of the wrong type!")
                    }
                    
                    let newVoice: Voice
                    if let model = agentVoice["model"] as? String {
                        newVoice = Voice(
                            name: AvailableVoice.name(for: model) ?? "Casey",
                            provider: agentVoice["provider"] as? String ?? "",
                            model: model
                        )
                    } else if let voiceId = agentVoice["voice_id"] as? String {
                        newVoice = Voice(
                            name: AvailableVoice.name(for: voiceId) ?? "Casey",
                            provider: agentVoice["provider"] as? String ?? "",
                            model: "" // Empty string since model is not provided
                        )
                        newVoice.voice_id = voiceId
                    } else {
                        fatalError("Neither model nor voice_id is present in agent voice!")
                    }
                    
                    FirebaseAPI.getAgentInitialMessage() { initialMessage in
                        FirebaseAPI.getAgentPrompt() { promptConfig in
                            let metadata = agent["metadata"] as? [String: Any] ?? [:]  // Extract metadata
                            
                            let newAgent = Agent(
                                initialMessage: initialMessage,
                                prompt: promptConfig,
                                voice: newVoice,
                                id: agent["id"] as? String ?? "",
                                uri: agent["uri"] as? String ?? "",
                                accountId: agent["account_id"] as? String ?? "",
                                createdAt: agent["created_at"] as? String ?? "",
                                updatedAt: agent["updated_at"] as? String ?? "",
                                metadata: metadata  // Pass the entire metadata dictionary
                            )
                            completion(newAgent)
                        }
                    }
                } else {
                    print("Agent items are missing or of the wrong type!")
                    completion(nil)
                    return
                }
            } catch {
                print("Error parsing the agent response: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }

    
    static func updateWakoAgent(agentId: String, greetingMessage: String, agentRequestBody: [String: Any], completion: @escaping (Agent?) -> Void) {
        let agentURL = Constants.baseURL.appendingPathComponent("agents").appendingPathComponent(agentId)
        
        var request = URLRequest(url: agentURL)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let subAccountApiKey = UserManager.shared.subAccountApiKey {
            request.setValue(subAccountApiKey, forHTTPHeaderField: "X-API-KEY")
        } else {
            completion(nil) // Corrected to return nil for consistency with Agent?
            return
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: agentRequestBody)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, error == nil, let data = data else {
                print("Error:", error ?? "Unknown error @ updateWakoAgent")
                completion(nil)
                return
            }
            
            do {
                guard let agentDict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Error parsing the agent response")
                    completion(nil)
                    return
                }
                
                guard let agentVoiceDict = agentDict["voice"] as? [String: Any] else {
                    print("Error: Missing or invalid 'voice' data")
                    completion(nil)
                    return
                }
                
                let agentVoice: Voice
                if let model = agentVoiceDict["model"] as? String {
                    agentVoice = Voice(
                        name: AvailableVoice.name(for: model) ?? "Casey",
                        provider: agentVoiceDict["provider"] as? String ?? "",
                        model: model
                    )
                } else if let voiceId = agentVoiceDict["voice_id"] as? String {
                    agentVoice = Voice(
                        name: AvailableVoice.name(for: voiceId) ?? "Casey",
                        provider: agentVoiceDict["provider"] as? String ?? "",
                        model: "" // Empty string since model is not provided
                    )
                    agentVoice.voice_id = voiceId
                } else {
                    print("Error: Neither model nor voice_id is present in agent voice!")
                    completion(nil)
                    return
                }
                
                let initialMessage = InitialMessage(
                    greetingMessage: greetingMessage
                )
                
                FirebaseAPI.getAgentPrompt() { promptConfig in
                    let metadata = agentDict["metadata"] as? [String: Any] ?? [:]

                    let updatedAgent = Agent(
                        initialMessage: initialMessage,
                        prompt: promptConfig,
                        voice: agentVoice,
                        id: agentDict["id"] as? String ?? "",
                        uri: agentDict["uri"] as? String ?? "",
                        accountId: agentDict["account_id"] as? String ?? "",
                        createdAt: agentDict["created_at"] as? String ?? "",
                        updatedAt: agentDict["updated_at"] as? String ?? "",
                        metadata: metadata
                    )
                    completion(updatedAgent)
                }

            } catch {
                print("Error deserializing JSON:", error)
                completion(nil)
            }
        }
        
        task.resume()
    }

}

