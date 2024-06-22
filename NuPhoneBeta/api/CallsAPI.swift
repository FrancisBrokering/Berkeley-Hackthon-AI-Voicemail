import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class CallsAPI {
    static func getCallHistory(completion: @escaping ([CallData]?) -> Void) {
        let serverUrl = Constants.baseURL.appendingPathComponent("conversations/").appending(queryItems: [URLQueryItem(name: "status", value: "ended")])
        var request = URLRequest(url: serverUrl)
        request.httpMethod = "GET"
        
        guard let subAccountApiKey = UserManager.shared.subAccountApiKey else {
            completion(nil)
            return
        }
        request.setValue(subAccountApiKey, forHTTPHeaderField: "X-API-KEY")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print("CALL HISTORY: ", response)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data, error == nil else {
                print("Error:", error?.localizedDescription ?? "Unknown error @ getCallHistory")
                completion(nil)
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
//                print("CALL HISTORY: ", jsonObject)
                guard let callsArray = jsonObject?["items"] as? [[String: Any]] else {
                    completion(nil)
                    return
                }
                
                var callDataList = [CallData]()
                let group = DispatchGroup()
                
                for call in callsArray {
                    guard let id = call["id"] as? String,
                          let uri = call["uri"] as? String,
                          let phoneCallDict = call["phone_call"] as? [String: Any],
                          let toNumber = phoneCallDict["to_number"] as? String,
                          let fromNumber = phoneCallDict["from_number"] as? String,
                          let status = call["status"] as? String,
                          let startTime = call["started_at"] as? String,
                          let messagesArray = call["messages"] as? [[String: Any]] else {
                        continue
                    }
                    
                    var messages = [Message]()
                    for messageDict in messagesArray {
                        guard let roleString = messageDict["role"] as? String,
                              let content = messageDict["content"] as? String,
                              let role = MessageRole(rawValue: roleString) else {
                            continue
                        }
                        messages.append(Message(role: role, content: content))
                    }
                    
                    group.enter()
                    let db = Firestore.firestore()
                    if let user = Auth.auth().currentUser {
                        db.collection("users").document(user.uid).collection("calls").document(id).getDocument { (document, error) in
                            var hasOpened = false
                            if let document = document, document.exists {
                                hasOpened = document.get("has_opened") as? Bool ?? false
                            } else {
                                db.collection("users").document(user.uid).collection("calls").document(id).setData(["has_opened": false], merge: true) { err in
                                    if let err = err {
                                        print("Error setting document: \(err)")
                                    }
                                }
                            }
                            
                            let callData = CallData(id: id, uri: uri, toNumber: toNumber, fromNumber: fromNumber, status: status, startTime: startTime, messages: messages, hasOpened: hasOpened)
                            callDataList.append(callData)
                            group.leave()
                        }
                    } else {
                        // If there's no current user, skip Firestore operations.
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion(callDataList.isEmpty ? nil : callDataList)
                }
            } catch {
                print("Error parsing the call history response: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    
    static func getLiveCalls(completion: @escaping ([CallData]?) -> Void) {
        let serverUrl = Constants.baseURL.appendingPathComponent("conversations/").appending(queryItems: [URLQueryItem(name: "status", value: "started")])
        var request = URLRequest(url: serverUrl)
        request.httpMethod = "GET"
        
        guard let subAccountApiKey = UserManager.shared.subAccountApiKey else {
            completion(nil)
            return
        }
        request.setValue(subAccountApiKey, forHTTPHeaderField: "X-API-KEY")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data, error == nil else {
                print("Error:", error?.localizedDescription ?? "Unknown error @ getCallHistory")
                completion(nil)
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                guard let callsArray = jsonObject?["items"] as? [[String: Any]] else {
                    completion(nil)
                    return
                }
                
                var callDataList = [CallData]()
                let group = DispatchGroup()
                
                let iso8601Formatter = ISO8601DateFormatter()
                iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                iso8601Formatter.timeZone = TimeZone.current
                
                for call in callsArray {
                    guard let id = call["id"] as? String,
                          let uri = call["uri"] as? String,
                          let phoneCallDict = call["phone_call"] as? [String: Any],
                          let toNumber = phoneCallDict["to_number"] as? String,
                          let fromNumber = phoneCallDict["from_number"] as? String,
//                          let direction = call["type"] as? String,
                          let status = call["status"] as? String,
                          let startTimeString = call["started_at"] as? String,
                          let messagesArray = call["messages"] as? [[String: Any]],
                          let startTime = iso8601Formatter.date(from: startTimeString) else {
                        continue
                    }
                    
                    let currentTime = Date()
                    let timeDifference = Calendar.current.dateComponents([.minute], from: startTime, to: currentTime).minute ?? 0
                    
                    if timeDifference > 5 {
                        // This call started more than 5 minutes ago; skip adding it to the array.
                        continue
                    }
                    
                    var messages = [Message]()
                    for messageDict in messagesArray {
                        guard let roleString = messageDict["role"] as? String,
                              let content = messageDict["content"] as? String,
                              let role = MessageRole(rawValue: roleString) else {
                            continue
                        }
                        messages.append(Message(role: role, content: content))
                    }
                    
                    let callData = CallData(id: id, uri: uri, toNumber: toNumber, fromNumber: fromNumber, status: status, startTime: startTimeString, messages: messages, hasOpened: false)
                    callDataList.append(callData)
                }
                
                completion(callDataList.isEmpty ? nil : callDataList)
            } catch {
                print("Error parsing the live call response: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
    
    static func sendInstructionToAgent(liveCall: CallData, instruction: String, idToken: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "https://us-central1-nuphone-6573c.cloudfunctions.net/sendAgentInstruction") else {
            completion(false)
            return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        // Add the ID token in the Authorization header
        request.addValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        let body: [String: Any] = ["instruction": instruction, "liveCallId": liveCall.id, "liveCallUri": liveCall.uri]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending instruction: \(error)")
                completion(false)
                return
            }
            // Handle successful response
            completion(true)
            print("Instruction Sent")
        }.resume()
    }
    
    static func getAudioUrl(callId: String, completion: @escaping (URL?) -> Void) {
        let serverUrl = Constants.baseURL.appendingPathComponent("conversations/")
            .appendingPathComponent("\(callId)")
            .appendingPathComponent("recording")
        var request = URLRequest(url: serverUrl)
        request.httpMethod = "GET"
        
        guard let subAccountApiKey = UserManager.shared.subAccountApiKey else {
            completion(nil)
            return
        }
        request.setValue(subAccountApiKey, forHTTPHeaderField: "X-API-KEY")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  let data = data,
                  error == nil else {
                print("Error:", error?.localizedDescription ?? "Unknown error @ getAudioUrl")
                completion(nil)
                return
            }
            
            do {
                if let jsonResult = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let audioUrlString = jsonResult["recording_url"] as? String,
                   let audioUrl = URL(string: audioUrlString) {
                    completion(audioUrl)
                } else {
                    print("Error: Unable to find audio URL in the response or invalid URL format")
                    completion(nil)
                }
            } catch {
                print("JSON error: \(error.localizedDescription)")
                completion(nil)
            }
        }
        task.resume()
    }
    
}
