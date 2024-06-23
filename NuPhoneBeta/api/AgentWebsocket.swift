//import Foundation
//
//class AgentWebsocket {
//    
//    private static var task: URLSessionWebSocketTask?
//    
//    static func connect() {
//        UserManager.shared.getCurrentIdToken { (idToken, error) in
//            if let error = error {
//                print("Error fetching ID Token:", error)
//                return
//            }
//            
//            guard let idToken = idToken else {
//                print("ID Token is nil")
//                return
//            }
//            
//            let agent = AgentManager.shared.agent
//            guard let agent = agent else {
//                print("agent is NULL")
//                return
//            }
//
//            let endpoint = agent.id + "/monitoring"
//            let url = Constants.webSocketBaseURL.appendingPathComponent(endpoint)
//            let task = URLSession.shared.webSocketTask(with: url)
//            print("WEB SOCKET URL: ", url)
//        
//            func receiveMessage() {
//                if task.state != URLSessionWebSocketTask.State.running {
//                    print("WebSocket task is not available for receiving messages.")
//                    return
//                }
//                
//                task.receive { result in
//                    switch result {
//                    case .success(let message):
//                        switch message {
//                        case .string(let messageString):
//                            // Handle the received message based on its content
//                            if let data = messageString.data(using: .utf8),
//                               let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                               let eventType = jsonObject["type"] as? String {
//                                print("!!!!!!!!jsonObject: ", jsonObject)
//                                switch eventType {
//                                case "call_started":
//                                    if let body = jsonObject["body"] as? String {
//                                        if let data = body.data(using: .utf8) {
//                                            do {
//                                                if let bodyJsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                                                    if let call = CallsManager.convertObjectToLiveCall(from: bodyJsonObject) {
//                                                        CallsManager.addLiveCall(liveCall: call)
//                                                    } else {
//                                                        print("Failed to convert body to LiveCall for call_started event.")
//                                                    }
//                                                }
//                                            } catch {
//                                                print("Error deserializing JSON: \(error)")
//                                            }
//                                        }
//                                    } else {
//                                        print("Failed to get body string from jsonObject.")
//                                    }
//
//                                    
//                                case "transcript":
//                                    if let body = jsonObject["body"] as? [String: Any],
//                                       let conversationId = body["id"] as? String {
//                                        let dialogue = CallsManager.convertToDialogue(from: body)
//                                        CallsManager.updateDialogueLiveCall(id: conversationId, dialogue: dialogue)
//                                    } else {
//                                        print("Failed to convert body to Dialogue for transcript event.")
//                                    }
//                                    
//                                case "call_ended":
//                                    if let body = jsonObject["body"] as? String {
//                                        if let data = body.data(using: .utf8) {
//                                            do {
//                                                if let bodyJsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                                                    if let call = CallsManager.convertObjectToLiveCall(from: bodyJsonObject) {
//                                                        CallsManager.removeLiveCall(liveCall: call)
//                                                    } else {
//                                                        print("Failed to convert body to LiveCall for call_ended event.")
//                                                    }
//                                                }
//                                            } catch {
//                                                print("Error deserializing JSON: \(error)")
//                                            }
//                                        }
//                                    } else {
//                                        print("Failed to get body string from jsonObject.")
//                                    }
//
//                                default:
//                                    print("WEBSOCKET EVENT NOT RECOGNIZED")
//                                }
//                            } else {
//                                // Handle parsing error or non-JSON message
//                                print("Received invalid JSON message: \(messageString)")
//                            }
//                        default:
//                            // Handle non-string messages
//                            print("Received non-string message: \(message)")
//                        }
//                    case .failure(let error):
//                        print("WebSocket error: \(error)")
//                    }
//                    receiveMessage()
//                }
//            }
//            task.resume()
//            
//            self.task = task
//            
//            // On connect, send a message with {"authorization": "123456"}
//            let authorizationMessage = """
//                {
//                    "type": "authorization",
//                    "Bearer": "\(idToken)"
//                }
//                """
//            
//            // Create a message with the authorization payload
//            let message = URLSessionWebSocketTask.Message.string(authorizationMessage)
//            
//            task.send(message) { error in
//                if let error = error {
//                    print("Error sending authorization message: \(error)")
//                } else {
//                    // Start receiving messages once the authorization message is sent
//                    receiveMessage()
//                    print("______________________ WEBSOCKET CONNECTED _____________________________")
//                }
//            }
//        }
//    }
//    
//    static func disconnect() {
//        guard let task = self.task else {
//            print("NO WEBSOCKET CONNECTION TO REMOVE")
//            return
//        }
//        
//        if task.state == URLSessionWebSocketTask.State.running {
//            print("______________________ WEBSOCKET DISCONNECTED _____________________________")
//            task.cancel()
//        } else {
//            print("WebSocket is not in a connected state.")
//        }
//    }
//}
//    
