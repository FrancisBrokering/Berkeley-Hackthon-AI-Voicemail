import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import UserNotifications
import UIKit
import FirebaseFirestore

@main
struct nuPhoneApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject var sessionManager = SessionManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AgentManager.shared)
                .environmentObject(sessionManager)
                .environmentObject(appDelegate.appState)
        }
        
    }
}


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    var appState = AppState()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {success, _ in
            guard success else {
                return
            }
            print("success")
        }
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification notification: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(notification) {
            completionHandler(.noData)
            return
        }
        // Handle the notification for other parts of your app or another service
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Detect if this URL is from your OAuth 2.0 redirect
        if let code = URLComponents(string: url.absoluteString)?.queryItems?.first(where: { $0.name == "code" })?.value {
            // Authorization code from OAuth flow detected, proceed with further logic
            print("Received OAuth code: \(code)")
            // Convert the code to tokens here, or pass it on to some method that initiates the flow
        }
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("APP WAS OPENED!")
        //        AgentManager.shared.fetchWakoAgent() { (success) in
        self.appState.currentView = .phone
        self.appState.currentTab = .calls
        CallsManager.fetchLiveCalls(){ liveCalls in
            if let callNotification = response.notification.request.content.userInfo as? [String: Any] {
                print("callNotification INFO", callNotification)
                //            if let data = callNotification["call_uri"] as? [String: Any] {
                // Assuming the call_uri is inside the 'data' dictionary.
                let call_uri = callNotification["call_uri"] as? String ?? ""
                if let range = call_uri.range(of: "/", options: .backwards) {
                    let call_id = String(call_uri[range.upperBound...])
                    print("CALL ID ", call_id)
                    DispatchQueue.main.async {
                        // Assuming appState and Tab are correctly defined and accessible here
                        self.appState.notificationCallId = call_id
                    }
                }
                //            }
            }
            //            }
        }
        // Call the completion handler to indicate that you have finished processing the notification
        completionHandler()
    }
    
    
    //    @objc func appEnterForeground() {
    //        print("App is entering the Foreground")
    //        AgentManager.shared.fetchWakoAgent() { (success) in
    //            DispatchQueue.main.async {
    //                if success {
    //                    CallsManager.fetchLiveCalls(){}
    //                    AgentWebsocket.connect()
    //                } else {
    //                    print("Failed to fetch WakoAgent")
    //                }
    //            }
    //        }
    //    }
    
    //    @objc func appEnterBackground() {
    //        print("App is entering the background")
    //        AgentWebsocket.disconnect()
    //    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, _ in
            let db = Firestore.firestore()
            if let user = Auth.auth().currentUser {
                if fcmToken != nil {
                    db.collection("users").document(user.uid).updateData(["fcm_token": fcmToken]) { error in
                        if let error = error {
                            print("Error writing document: \(error)")
                        } else {
                            print("Document successfully written!")
                        }
                    }
                } else {
                    print("fcm token is nil")
                }
            }
            //            guard let token = token else {
            //                return
            //            }
            //            print("Token: \(token)")
            //TODO STORE DEVICE TOKEN SOMEHOW
            FirebaseAPI.updateUserDeviceToken(fcmToken: token)
        }
    }
    
    //  DO NOT REMOVE THIS FUNCTION
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
}

class SessionManager: ObservableObject {
    @Published var isLoggedIn = false
    //    @Published var initialAgent: Agent? = nil
    @ObservedObject var subscriptionManager = SubscriptionManager()
    let db = Firestore.firestore()
    
    init() {
        self.isLoggedIn = Auth.auth().currentUser != nil
        print("INITIALIZING APP")
        if (self.isLoggedIn) {
            UserManager.shared.fetchSubAccountApiKey { isSuccess in
                if isSuccess {
                    AccountManager.shared.getUserAccount()
                    CallsManager.fetchLiveCalls(){_ in}
                    CallsManager.fetchCallHistory() { (success) in
                        if success {
                            print("INITIAL CALL HISTORY")
                        }
                        
                    }
                    AgentManager.shared.fetchWakoAgent() { (success) in
                        //Make isLoading False only after getting the phone number (inside context provider)
                        DispatchQueue.main.async {
                            if success {
                                AgentManager.shared.isLoading = false
                                //                                AgentWebsocket.connect()
                                if let user = Auth.auth().currentUser {
                                    if let transactionId = self.subscriptionManager.originalTransactionId {
                                        self.db.collection("users").document(user.uid).updateData(["original_transaction_id": transactionId]) { error in
                                            if let error = error {
                                                print("Error writing document: \(error)")
                                            } else {
                                                print("Document successfully written!")
                                            }
                                        }
                                    }
                                }
                                
                                requestContactsAccess { granted in
                                    DispatchQueue.main.async {
                                        if granted {
                                            // Access granted, proceed with contact-related operations
                                        } else {
                                            // Handle the case where access is not granted
                                            // You might want to inform the user or disable certain features
                                        }
                                    }
                                }
                            } else {
                                AgentManager.shared.isLoading = false
                                print("INITIAL FAILED TO FETCH AGENT")
                            }
                        }
                    }
                }
                else {
                    AgentManager.shared.isLoading = false
                    print("Failed to fetch Sub Account API Key.")
                }
            }
        }
        else {
            //if there is no account yet, set isLoading to false.
            print("SETTING IS LOADING TO FALSE")
            AgentManager.shared.isLoading = false
        }
    }
}
