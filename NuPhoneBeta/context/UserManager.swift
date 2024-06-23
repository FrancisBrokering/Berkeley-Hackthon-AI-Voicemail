import SwiftUI
import FirebaseAuth
import FirebaseFirestore
//import FirebaseFirestore

class UserManager: ObservableObject {
    static let shared = UserManager()
    @Published var isLoading = true
    @Published var subAccountApiKey: String?
    @Published var userPhoneNumber: String? // Added variable for user's phone number

    private init() {
        getUserInfo()
    }

    var currentUser: User? {
        return Auth.auth().currentUser
    }

    var currentUserId: String? {
        return currentUser?.uid
    }

    func getCurrentIdToken(completion: @escaping (String?, Error?) -> Void) {
        currentUser?.getIDToken(completion: { (idToken, error) in
            completion(idToken, error)
        })
    }
    
    func getUserInfo() {
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            guard let self = self else { return }
            self.isLoading = true // Indicate loading starts
            if let user = user {
                // User is signed in
                if let phoneNumber = user.phoneNumber {
                    self.userPhoneNumber = formatPhoneNumber(phoneNumber: phoneNumber)
                    print("USER PHONE NUMBER", phoneNumber)
                }

                // Attempt to fetch the Sub Account API Key
                self.fetchSubAccountApiKey { isSuccess in
                    DispatchQueue.main.async {
                        self.isLoading = false // Update loading status on the main thread
                        if isSuccess {
                            print("Successfully Key.")
                        } else {
                            print("Failed Key")
                        }
                    }
                }
            } else {
                // No user is signed in
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.subAccountApiKey = nil // Clear any existing API key as there's no user
                    self.userPhoneNumber = nil // Clear the phone number as there's no user
                }
            }
        }
    }

    func fetchSubAccountApiKey(completion: @escaping (Bool) -> Void) {
        if let user = Auth.auth().currentUser {
            DispatchQueue.main.async {
                let db = Firestore.firestore()
                db.collection("users").document(user.uid).getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let subAccountKey = document.get("api_key") as? String {
                            print("HAS API KEY")
                            self.subAccountApiKey = subAccountKey
                            completion(true)
                        }
                        else {
                            completion(false)
                        }
                    } else {
                        completion(false)
                    }
                }
            }
        }
//        currentUser?.getIDTokenForcingRefresh(true, completion: { (idToken, error) in
//            guard error == nil else {
//                print("Error refreshing ID Token: \(error!.localizedDescription)")
//                completion(false)
//                return
//            }
//
//            self.currentUser?.getIDTokenResult(completion: { [weak self] (result, error) in
//                guard error == nil else {
//                    print("Error fetching ID Token: \(error!.localizedDescription)")
//                    completion(false)
//                    return
//                }
//
//                print("result?.claims", result?.claims)
//                if let subAccountKey = result?.claims["sub_account_api_key"] as? String {
//                    self?.subAccountApiKey = subAccountKey
//                    completion(true)
//                } else {
//                    completion(false)
//                }
//            })
//        })
    }

}
