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
    
    
    
    //    static func formatAgent(agent: [String: Any]) -> Agent {
    //        // Safely get the agent configuration
    //        guard let agentConfig = agent["config"] as? [String: Any] else {
    //            fatalError("Agent config is missing or of the wrong type!")
    //        }
    //
    //        guard let agentVoice = agentConfig["voice"] as? [String: Any] else {
    //            fatalError("Agent config is missing or of the wrong type!")
    //        }
    //
    //        // Create an AgentVoice instance
    //        let voice = AgentVoice(
    //            name: agentVoice["name"] as! String,
    //            voiceId: agentVoice["voice_id"] as! String,
    //            pitch: agentVoice["pitch"] as! Double,
    //            rate: agentVoice["rate"] as! Double
    //        )
    //
    //        // Create an AgentConfig instance
    //        let config = AgentConfig(
    //            name: agentConfig["name"] as! String,
    //            voice: voice,
    //            enableTransferCall: agentConfig["enable_transfer_call"] as! Bool,
    //            initialMessage: agentConfig["initial_message"] as! String,
    //            personalityTraits: agentConfig["personality_traits"] as! [String],
    //            transferPhoneNumber: agentConfig["transfer_phone_number"] as? String ?? "",
    //            promptPreamble: agentConfig["prompt_preamble"] as! String,
    //            agentPurpose: agentConfig["agent_purpose"] as! String,
    //            useKnowledgeBase: agentConfig["use_knowledge_base"] as! Bool,
    //            actions: agentConfig["actions"] as! [Action],
    //            candidateLanguages: agentConfig["candidate_languages"] as! [String],
    //            defaultLanguage: agentConfig["default_language"] as! String,
    //            phoneNumberId: agentConfig["phone_number_id"] as? String ?? nil
    //        )
    //
    //        // Create and return the Agent instance
    //        return Agent(
    //            agentId: agent["agent_id"] as! String,
    //            ownerId: agent["owner_id"] as! String,
    //            status: agent["status"] as! String,
    //            config: config
    //        )
    //    }
    
    
//    static func availablePhoneNumbersToBuy(completion: @escaping (String?) -> Void) {
//        let phoneNumberURL = Constants.baseURL.appendingPathComponent("phone_numbers/buy")
//        var request = URLRequest(url: phoneNumberURL)
//        request.httpMethod = "GET"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        if let subAccountApiKey = UserManager.shared.subAccountApiKey {
//            request.setValue(subAccountApiKey, forHTTPHeaderField: "X-API-KEY")
//        }
//        else {
//            completion(nil)
//        }
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let httpResponse = response as? HTTPURLResponse, error == nil else {
//                print("Error:", error ?? "Unknown error @ availablePhoneNumbersToBuy")
//                completion(nil)
//                return
//            }
//            
//            switch httpResponse.statusCode {
//            case 200...299:
//                guard let data = data else {
//                    print("No data received")
//                    completion(nil)
//                    return
//                }
//                do {
//                    // Assuming the JSON structure is an array of PhoneNumberToBuy objects
//                    if let phoneNumbers = try JSONSerialization.jsonObject(with: data) as? [[String: Any]],
//                       let firstPhoneNumber = phoneNumbers.first,
//                       let phoneNumber = firstPhoneNumber["phone_number"] as? String { // Correct key to "phone_number"
//                        completion(phoneNumber)
//                    } else {
//                        print("Error parsing the phone number response availablePhoneNumbersToBuy")
//                        completion(nil)
//                    }
//                } catch {
//                    print("Error parsing the data:", error)
//                    completion(nil)
//                }
//            default:
//                print("Received HTTP \(httpResponse.statusCode)")
//                completion(nil)
//            }
//        }
//        
//        task.resume()
//        
//    }
    
    
    
//    static func buyPhoneNumber(phoneNumber: String, completion: @escaping (PhoneNumberData?) -> Void) {
//        let phoneNumberURL = Constants.baseURL.appendingPathComponent("phone_numbers/buy")
//        var request = URLRequest(url: phoneNumberURL)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        if let subAccountApiKey = UserManager.shared.subAccountApiKey {
//            request.setValue(subAccountApiKey, forHTTPHeaderField: "X-API-KEY")
//        }
//        else {
//            completion(nil)
//        }
//        
//        let phoneNumberRequestBody: [String: Any] = [
//            "provider": "twilio",
//            "phone_number": phoneNumber,
//        ]
//        
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: phoneNumberRequestBody, options: [])
//            request.httpBody = jsonData
//        } catch {
//            print("Error serializing agent agentBody:", error)
//            completion(nil)
//            return
//        }
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let httpResponse = response as? HTTPURLResponse, error == nil else {
//                print("Error:", error ?? "Unknown error @ buyPhoneNumber")
//                completion(nil)
//                return
//            }
//            
//            switch httpResponse.statusCode {
//            case 200...299:
//                guard let data = data else {
//                    print("No data received")
//                    completion(nil)
//                    return
//                }
//                do {
//                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//                       let phoneNumber = jsonObject["phone_number"] as? String
//                    //    let phoneNumberId = jsonObject["id"] as? String
//                    {
//                        if let user = Auth.auth().currentUser {
//                            let db = Firestore.firestore()
//                            db.collection("users").document(user.uid).updateData(["phone_number": phoneNumber]) { error in
//                                if let error = error {
//                                    print("Error writing document phoneNumber: \(error)")
//                                } else {
//                                    print("Document successfully written! phoneNumber")
//                                }
//                            }
//                            
//                        }
//                        let newPhoneNumberData = PhoneNumberData(
//                            phoneNumber: phoneNumber,
//                            id: jsonObject["id"] as? String ?? ""
//                        )
//                        completion(newPhoneNumberData)
//                    } else {
//                        print("Error parsing the phone number response buyPhoneNumber")
//                        completion(nil)
//                    }
//                } catch {
//                    print("Error parsing the data:", error)
//                    completion(nil)
//                }
//            default:
//                print("Received HTTP \(httpResponse.statusCode)")
//                completion(nil)
//            }
//        }
//        
//        task.resume()
//        
//    }
    
//    static func getWakoAgentPhoneNumber(completion: @escaping (PhoneNumberData?) -> Void) {
//        let phoneNumberURL = Constants.baseURL.appendingPathComponent("phone_numbers")
//        var request = URLRequest(url: phoneNumberURL)
//        request.httpMethod = "GET"
//        if let subAccountApiKey = UserManager.shared.subAccountApiKey {
//            request.setValue(subAccountApiKey, forHTTPHeaderField: "X-API-KEY")
//        } else {
//            completion(nil) // If API key is not available, immediately return.
//            return
//        }
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let httpResponse = response as? HTTPURLResponse, error == nil, httpResponse.statusCode == 200 else {
//                print("Error:", error ?? "Unknown error @ getWakoAgentPhoneNumber")
//                completion(nil)
//                return
//            }
//            
//            guard let data = data else {
//                print("No data received from getWakoAgentPhoneNumber")
//                completion(nil)
//                return
//            }
//            
//            do {
//                if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//                   let items = jsonObject["items"] as? [[String: Any]],
//                   let firstItem = items.first,
//                //    let phoneNumberId = firstItem["id"] as? String,
//                   let phoneNumber = firstItem["phone_number"] as? String {
//                    let db = Firestore.firestore()
//                    if let user = Auth.auth().currentUser {
//                        db.collection("users").document(user.uid).updateData(["phone_number": phoneNumber]) { error in
//                            if let error = error {
//                                print("Error writing document phoneNumber: \(error)")
//                            } else {
//                                print("Document successfully written! phoneNumber")
//                            }
//                        }
//                        
//                    }
//                    let newPhoneNumberData = PhoneNumberData(
//                        phoneNumber: phoneNumber,
//                        id: firstItem["id"] as? String ?? ""
//                    )
//                    completion(newPhoneNumberData)
//                } else {
//                    print("Error parsing the phone number response from getWakoAgentPhoneNumber")
//                    completion(nil)
//                }
//            } catch {
//                print("JSON parsing error: \(error)")
//                completion(nil)
//            }
//        }
//        
//        task.resume()
//    }

//    static func updateWakoAgentPhoneNumber(phoneNumber: String, phoneNumberRequestBody: [String: Any], completion: @escaping (PhoneNumberData?) -> Void) {
//        let phoneNumberURL = Constants.baseURL.appendingPathComponent("phone_numbers").appendingPathComponent(phoneNumber)
//        print("UPDATE PHONE NUMBER: ", phoneNumber)
//        var request = URLRequest(url: phoneNumberURL)
//        request.httpMethod = "PATCH"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        if let subAccountApiKey = UserManager.shared.subAccountApiKey {
//            request.setValue(subAccountApiKey, forHTTPHeaderField: "X-API-KEY")
//        } else {
//            completion(nil)
//            return
//        }
//        
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: phoneNumberRequestBody, options: [])
//            request.httpBody = jsonData
//        } catch {
//            print("Error serializing agent agentBody:", error)
//            completion(nil)
//            return
//        }
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let httpResponse = response as? HTTPURLResponse, error == nil else {
//                print("Error:", error ?? "Unknown error @ updateWakoAgentPhoneNumber")
//                completion(nil)
//                return
//            }
//            
//            switch httpResponse.statusCode {
//            case 200...299:
//                guard let data = data else {
//                    print("No data received")
//                    completion(nil)
//                    return
//                }
//                do {
//                    if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any],
//                       let phoneNumber = jsonObject["phone_number"] as? String {
//                        let newPhoneNumberData = PhoneNumberData(
//                            phoneNumber: phoneNumber,
//                            id: jsonObject["id"] as? String ?? ""
//                        )
////                        print("UPDATED PHONE NUMBER")
//                        completion(newPhoneNumberData)
//                    } else {
//                        print("Error parsing the phone number response updateWakoAgentPhoneNumber")
//                        completion(nil)
//                    }
//                } catch {
//                    print("Error parsing the data:", error)
//                    completion(nil)
//                }
//            default:
//                print("Received HTTP \(httpResponse.statusCode)")
//                completion(nil)
//            }
//        }
//        
//        task.resume()
//    }
    
    
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
    
    
    
    static func createWakoAgent(agentRequestBody: [String: Any], completion: @escaping (Agent?) -> Void) {
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
            let jsonData = try JSONSerialization.data(withJSONObject: agentRequestBody, options: [])
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
            
            let newVoice = Agent.Voice(
                name: AvailableVoice.name(for:agentVoice["model"] as? String ?? "") ?? "en-US-EmmaNeural",
                provider: agentVoice["provider"] as? String ?? "",
                model: agentVoice["model"] as? String ?? "",
                pitch: agentVoice["pitch"] as? Int ?? 0,
                rate: agentVoice["rate"] as? Int ?? 0
            )
            
            let parsedResult = AgentAPI.parseAgentPrompt(from: agent["prompt"] as? String ?? "")
            
            
            let newAgent = Agent(
                name: agent["name"] as? String ?? "",
                initialMessage: agent["initial_message"] as? String ?? "",
                prompt: parsedResult.prompt,
                system_message: parsedResult.system_message,
                personality: parsedResult.personality,
                language: agent["language"] as? String ?? "",
                voice: newVoice,
                knowledgeBaseId: nil,
                id: agent["id"] as? String ?? "",
                uri: agent["uri"] as? String ?? "",
                accountId: agent["account_id"] as? String ?? "",
                createdAt: agent["created_at"] as? String ?? "",
                updatedAt: agent["updated_at"] as? String ?? ""
//                phoneNumber: nil
            )
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
        }
        else {
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
                   let agents = agentData["items"] as? [[String: Any]], // Assuming this is the correct structure
                   let agent = agents.first { // This is how you access the first agent
                    guard let agentVoice = agent["voice"] as? [String: Any] else {
                        fatalError("Agent voice is missing or of the wrong type!")
                    }
                    
                    let newVoice = Agent.Voice(
                        name: AvailableVoice.name(for:agentVoice["model"] as? String ?? "") ?? "en-US-EmmaNeural",
                        provider: agentVoice["provider"] as? String ?? "",
                        model: agentVoice["model"] as? String ?? "",
                        pitch: agentVoice["pitch"] as? Int ?? 0,
                        rate: agentVoice["rate"] as? Int ?? 0
                    )
                    
                    let parsedResult = AgentAPI.parseAgentPrompt(from: agent["prompt"] as? String ?? "")
                    let initialMessage = (agent["initial_message"] as? String ?? "").replacingOccurrences(of: callRecordMessage, with: "")
                    
                    
                    let newAgent = Agent(
                        name: agent["name"] as? String ?? "",
                        initialMessage: initialMessage,
                        prompt: parsedResult.prompt,
                        system_message: parsedResult.system_message,
                        personality: parsedResult.personality,
                        language: agent["language"] as? String ?? "",
                        voice: newVoice,
                        knowledgeBaseId: nil,
                        id: agent["id"] as? String ?? "",
                        uri: agent["uri"] as? String ?? "",
                        accountId: agent["account_id"] as? String ?? "",
                        createdAt: agent["created_at"] as? String ?? "",
                        updatedAt: agent["updated_at"] as? String ?? ""
                    )
                    completion(newAgent)
                }
                else {
                    print("Agent items is missing or of the wrong type!")
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
    
    static func updateWakoAgent(agentId: String, agentRequestBody: [String: Any], completion: @escaping (Agent?) -> Void) {
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
                
                // Assuming the structure of the Agent object and the keys in the response are the same as those used in createWakoAgent
                guard let agentVoiceDict = agentDict["voice"] as? [String: Any] else {
                    print("Error: Missing or invalid 'voice' data")
                    completion(nil)
                    return
                }
                
                let agentVoice = Agent.Voice(
                    name: AvailableVoice.name(for: agentVoiceDict["model"] as? String ?? "") ?? "en-US-EmmaNeural",
                    provider: agentVoiceDict["provider"] as? String ?? "",
                    model: agentVoiceDict["model"] as? String ?? "",
                    pitch: agentVoiceDict["pitch"] as? Int ?? 0,
                    rate: agentVoiceDict["rate"] as? Int ?? 0
                )
                
                let parsedResult = AgentAPI.parseAgentPrompt(from: agentDict["prompt"] as? String ?? "")
                
                let updatedAgent = Agent(
                    name: agentDict["name"] as? String ?? "",
                    initialMessage: agentDict["initial_message"] as? String ?? "",
                    prompt: parsedResult.prompt,
                    system_message: parsedResult.system_message,
                    personality: parsedResult.personality,
                    language: agentDict["language"] as? String ?? "",
                    voice: agentVoice,
                    knowledgeBaseId: nil,
                    id: agentDict["id"] as? String ?? "",
                    uri: agentDict["uri"] as? String ?? "",
                    accountId: agentDict["account_id"] as? String ?? "",
                    createdAt: agentDict["created_at"] as? String ?? "",
                    updatedAt: agentDict["updated_at"] as? String ?? ""
//                    phoneNumber: phoneNumber
                )
                completion(updatedAgent)
            } catch {
                print("Error deserializing JSON:", error)
                completion(nil)
            }
        }
        
        task.resume()
    }
}

