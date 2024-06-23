import Foundation
import FirebaseAuth
import FirebaseFirestore

class AccountManager: ObservableObject {
    static let shared = AccountManager()
    @Published var accountId: String?
    @Published var userAccount: Account?
    @Published var dedicatedNumber: String?
    @Published var userName: String = ""
    @Published var plan: String = ""
    
    private init() {
        getUserAccount()
    }
    
    func getUserAccount() {
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    self.accountId = document.get("account_id") as? String ?? nil
                    self.userName = document.get("user_name") as? String ?? ""
                    print("ACCOUNT ID", self.accountId)
                    if self.accountId != nil {
                        AccountAPI.getUserAccount(accountId: self.accountId!) { account in
                            DispatchQueue.main.async {
                                self.userAccount = account
                            }
                        }
                    }
                } else {
                    print("No account id found")
                }
            }
            
            PhoneNumberAPI.listPhoneNumber { [weak self] phoneNumber in
                print("PHONENUMBER: ", phoneNumber)
                DispatchQueue.main.async {
                    self?.dedicatedNumber = phoneNumber
                }
            }
        }
    }
}
