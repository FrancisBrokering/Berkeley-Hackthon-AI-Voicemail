import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

class FirebaseAPI {
    static func getAgentPrompt(completion: @escaping (PromptConfig) -> Void) {
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).getDocument { (documentSnapshot, error) in
                guard let document = documentSnapshot, document.exists, let data = document.get("prompt_config") else {
                    print("No document found or failed to serialize data")
                    completion(PromptConfig())
                    return
                }
                
                do {
                    // Convert the Firestore document data to JSON
                    print("prompt data", data)
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                    // Decode the JSON data to your PromptConfig struct
                    print("promptConfig", jsonData)
                    let promptConfig = try JSONDecoder().decode(PromptConfig.self, from: jsonData)
                    //                    print("promptConfig faqs", promptConfig.faqs.items)
                    completion(promptConfig)
                } catch {
                    print("Error decoding prompt_config: \(error)")
                    completion(PromptConfig())
                }
            }
        }
        else {
            print("user not found")
        }
    }
    
    static func updateAgentPrompt(promptConfig: PromptConfig, completion: @escaping (Bool) -> Void) {
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let documentRef = db.collection("users").document(user.uid)
            print("UPDATING PROMPT IN FIREBASE")
            do {
                // Convert the PromptConfig object to a dictionary using JSONEncoder
                let data = try JSONEncoder().encode(promptConfig)
                let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] ?? [:]
                documentRef.updateData(["prompt_config": dictionary]) { error in
                    if let error = error {
                        print("Error updating PROPMT document: \(error)")
                        completion(false)
                    } else {
                        print("PROPMP Document successfully updated")
                        completion(true)
                    }
                }
            } catch {
                print("Error encoding promptConfig: \(error)")
                completion(false)
            }
        } else {
            print("User not found")
            completion(false)
        }
    }
    
    static func getAgentInitialMessage(completion: @escaping (InitialMessage) -> Void) {
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).getDocument { (documentSnapshot, error) in
                guard let document = documentSnapshot, document.exists, let data = document.get("initial_message_config") else {
                    print("No document found or failed to serialize data")
                    completion(InitialMessage())
                    return
                }
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
                    let initialMessage = try JSONDecoder().decode(InitialMessage.self, from: jsonData)
                    print("initialMessage", initialMessage)
                    completion(initialMessage)
                } catch {
                    print("Error decoding InitialMessage: \(error)")
                    completion(InitialMessage())
                }
            }
        }
        else {
            print("user not found")
        }
    }
    
    static func updateAgentInitialMessage(initialMessageConfig: InitialMessage, completion: @escaping (Bool) -> Void) {
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let documentRef = db.collection("users").document(user.uid)
            do {
                // Convert the PromptConfig object to a dictionary using JSONEncoder
                let data = try JSONEncoder().encode(initialMessageConfig)
                let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] ?? [:]
                
                documentRef.updateData(["initial_message_config": dictionary]) { error in
                    if let error = error {
                        print("Error updating InitialMessage document: \(error)")
                        completion(false)
                    } else {
                        print("InitialMessage Document successfully updated")
                        completion(true)
                    }
                }
            } catch {
                print("Error encoding InitialMessage: \(error)")
                completion(false)
            }
        } else {
            print("User not found")
            completion(false)
        }
    }
    
    
    static func updateUserDeviceToken(fcmToken: String?) {
        if (fcmToken==nil) {
            return
        }
        let endpoint = Constants.baseURL.appendingPathComponent("apple").appendingPathComponent("updateDeviceToken")
        
        UserManager.shared.getCurrentIdToken { (idToken, error) in
            if let error = error {
                print("Error fetching ID Token:", error)
                return
            }
            
            guard let idToken = idToken else {
                print("ID Token is nil")
                return
            }
            
            let requestPayload: [String: Any] = [
                "fcm_token": fcmToken
            ]
            
            var request = URLRequest(url: endpoint)
            request.httpMethod = "POST"
            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Permission")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONSerialization.data(withJSONObject: requestPayload)
            
            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                guard let _ = response as? HTTPURLResponse, error == nil else {
                    print("Error:", error ?? "Unknown error @ updateUserDeviceToken")
                    return
                }
            }
            
            task.resume()
        }
        
    }
    
    static func checkHasAccountWithDifferentCredentials(originalTransactionId: String, phoneNumber: String, completion: @escaping (Bool?) -> Void) {
        // Get an instance of Firebase Functions
        //        let functions = Functions.functions()
        guard let url = URL(string: "https://us-central1-nuphone-6573c.cloudfunctions.net/checkHasAccountWithDifferentCredentials") else { return }
        
        let body: [String: Any] = [
            "originalTransactionId": originalTransactionId,
            "phoneNumber": phoneNumber
        ]
        
        var request = URLRequest(url: url) // Fixed variable name from `endpoint` to `url`
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, error == nil else {
                print("Error:", error ?? "Unknown error in checkIfOriginalTransactionIdMatchesPhoneNumber")
                completion(nil)
                return
            }
            
            guard httpResponse.statusCode == 200, let responseData = data else {
                print("Invalid response or status code.")
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
                   let hasAccount = json["result"] as? Bool {
                    completion(hasAccount)
                } else {
                    print("Could not parse JSON response.")
                    completion(nil)
                }
            } catch {
                print("JSON parsing error:", error)
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    //
    static func testCallUser(idToken: String, completion: @escaping (Bool) -> Void) {
        // Get an instance of Firebase Functions
        //        let functions = Functions.functions()
        guard let url = URL(string: "https://us-central1-nuphone-6573c.cloudfunctions.net/verifyIfUserForwarded") else { return }
        var request = URLRequest(url: url) // Fixed variable name from `endpoint` to `url`
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, error == nil else {
                print("Error:", error ?? "Unknown error in checkCallForwarding")
                completion(false)
                return
            }
            
            guard httpResponse.statusCode == 200, let responseData = data else {
                print("Invalid response or status code.")
                completion(false)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
                   let didCall = json["result"] as? Bool {
                    completion(didCall)
                } else {
                    print("Could not parse JSON response.")
                    completion(false)
                }
            } catch {
                print("JSON parsing error:", error)
                completion(false)
            }
        }
        
        task.resume()
    }
    
    static func deleteAccount(idToken: String, completion: @escaping (Bool) -> Void) {
        // Get an instance of Firebase Functions
        //        let functions = Functions.functions()
        guard let url = URL(string: "https://us-central1-nuphone-6573c.cloudfunctions.net/deleteAccount") else { return }
        
        var request = URLRequest(url: url) // Fixed variable name from `endpoint` to `url`
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, error == nil else {
                print("Error:", error ?? "Unknown error in deleteAccount")
                completion(false)
                return
            }
            
            guard httpResponse.statusCode == 200, let responseData = data else {
                print("Invalid response or status code.")
                completion(false)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
                   let success = json["result"] as? Bool {
                    completion(success)
                } else {
                    print("Could not parse JSON response.")
                    completion(false)
                }
            } catch {
                print("JSON parsing error:", error)
                completion(false)
            }
        }
        
        task.resume()
    }
    
    static func updateAccount(idToken: String, subscription: String , completion: @escaping (Bool) -> Void) {
        // Get an instance of Firebase Functions
        //        let functions = Functions.functions()
        guard let url = URL(string: "https://us-central1-nuphone-6573c.cloudfunctions.net/updateAccount") else { return }
        
        var request = URLRequest(url: url)
        let body: [String: Any] = [
            "subscription": subscription,
        ]
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error serializing JSON:", error)
            completion(false)
            return
        }
        print("REQUEST: ", request)
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, error == nil else {
                print("Error:", error ?? "Unknown error in deleteAccount")
                completion(false)
                return
            }
            
            guard httpResponse.statusCode == 200, let responseData = data else {
                print("Invalid response or status code.")
                completion(false)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
                   let success = json["result"] as? Bool {
                    AccountManager.shared.getUserAccount()
                    completion(success)
                } else {
                    print("Could not parse JSON response.")
                    completion(false)
                }
            } catch {
                print("JSON parsing error:", error)
                completion(false)
            }
        }
        
        task.resume()
    }
    
    static func getMinimumRequiredVersion(idToken: String, completion: @escaping (String?) -> Void) {
        // Get an instance of Firebase Functions
        //        let functions = Functions.functions()
        guard let url = URL(string: "https://us-central1-nuphone-6573c.cloudfunctions.net/getMinimumRequiredVersion") else { return }
        var request = URLRequest(url: url) // Fixed variable name from `endpoint` to `url`
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, error == nil else {
                print("Error:", error ?? "Unknown error in checkCallForwarding")
                completion(nil)
                return
            }
            
            print("STATUS CODE: ", httpResponse.statusCode)
            
            guard httpResponse.statusCode == 200, let responseData = data else {
                print("Invalid response or status code.")
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
                   let version = json["version"] as? String {
                    completion(version)
                } else {
                    print("Could not parse JSON response.")
                    completion(nil)
                }
            } catch {
                print("JSON parsing error:", error)
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    
    static func getAdminMessage(idToken: String, completion: @escaping (AdminMessage?) -> Void) {
        guard let url = URL(string: "https://us-central1-nuphone-6573c.cloudfunctions.net/getAdminMessage") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, error == nil else {
                print("Error:", error ?? "Unknown error in getAdminMessage")
                completion(nil)
                return
            }
            guard httpResponse.statusCode == 200, let responseData = data else {
                print("Invalid response or status code.")
                completion(nil)
                return
            }

            do {
                let decoder = JSONDecoder()
                let adminMessage = try decoder.decode(AdminMessage.self, from: responseData)
                
                completion(adminMessage)
            } catch {
                print("JSON decoding error:", error)
                completion(nil)
            }
        }
        
        task.resume()
    }

    
    
    
    //    static func sendTransactionId(agentId: String, transactionId: String) {
    //        if let userId = UserManager.shared.currentUserId {
    //            let endpoint = Constants.baseURL.appendingPathComponent("billing").appendingPathComponent("save_subscription_id")
    //
    //            UserManager.shared.getCurrentIdToken { (idToken, error) in
    //                if let error = error {
    //                    print("Error fetching ID Token:", error)
    //                    return
    //                }
    //
    //                guard let idToken = idToken else {
    //                    print("ID Token is nil")
    //                    return
    //                }
    //
    //                let requestPayload: [String: Any] = [
    //                    "agent_id": agentId,
    //                    "transaction_id": transactionId
    //                ]
    //
    //                var request = URLRequest(url: endpoint)
    //                request.httpMethod = "POST"
    //                request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Permission")
    //                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    //                request.httpBody = try? JSONSerialization.data(withJSONObject: requestPayload)
    //
    //                let task = URLSession.shared.dataTask(with: request) { _, response, error in
    //                    guard let httpResponse = response as? HTTPURLResponse, error == nil else {
    //                        print("Error:", error ?? "Unknown error @ updateUserDeviceToken")
    //                        return
    //                    }
    //                }
    //
    //                task.resume()
    //            }
    //        }
    //    }
}

