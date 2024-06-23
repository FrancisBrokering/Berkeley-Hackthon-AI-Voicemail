//
//  AccountAPI.swift
//  NuPhoneBeta
//
//  Created by Francis Brokering on 2/23/24.
//

import SwiftUI

class AccountAPI {
    static func getUserAccount(accountId: String, completion: @escaping (Account?) -> Void) {
        let serverUrl = Constants.baseURL.appendingPathComponent("sub_accounts/\(accountId)")
        
        var request = URLRequest(url: serverUrl)
        request.httpMethod = "GET"
        print("PASSED HERE")
        if let subAccountApiKey = UserManager.shared.subAccountApiKey {
            request.setValue(subAccountApiKey, forHTTPHeaderField: "X-API-KEY")
            print("PASSED HERE API")
        }
        else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, error == nil else {
                print("Error:", error ?? "Unknown error @ getUserAccount")
                completion(nil)
                return
            }
            guard let data = data else {
                print("Error: No data")
                completion(nil)
                return
            }
            
            do {
                if let accountData = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    print("ACCOUNT DATA", accountData)
                    print("ACCOUNT usage minues",  accountData["current_usage_minutes"] as? Double)
                    let userAccount = Account(
                        last_usage_reset: accountData["last_usage_reset"] as? String ?? "",
                        current_usage_minutes: accountData["current_usage_minutes"] as? Double ?? 0,
                        usage_limit_minutes: accountData["usage_limit_minutes"] as? Double ?? 0
                    )
                    print("USER ACCOUNT", userAccount.current_usage_minutes)
                    completion(userAccount)
                }
                else {
                    print("Could not retrieve user's account")
                    completion(nil)
                    return
                }
            } catch {
                print("Error parsing the account response: \(error)")
                completion(nil)
            }
        }
        task.resume()
    }
}
