import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseAnalytics


struct LoginView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
//    @Binding var currentView: AppView
//    @Binding var previousView: AppView
    @EnvironmentObject var appState: AppState
    @ObservedObject var accountManager = AccountManager.shared
    @State private var phoneNumber: String = ""
    @State private var verificationCode: String = ""
    @State private var errorMessage: String? = nil
    @State private var verificationID: String? = nil
    @State private var isVerificationCodeFieldVisible: Bool = false
    @State private var askOTP: Bool = false
    @State private var otpText: String = ""
    @Binding var selectedCarrier: String?
    @State private var isLoading: Bool = false
    @State private var isOtpLoading: Bool = false
    @State private var isCheckBoxClicked = false
    @State private var proceedWithoutAgree = false
    
    let phoneNumberFormatter = PhoneNumberFormatter()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Get Started")
                .font(.largeTitle)
                .fontWeight(.heavy)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
            
            Text("Enter your US phone number to continue")
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
                .padding(.top, -5)
            
            HStack(alignment: .top, spacing: 5) {
//                Image(systemName: "phone")
//                    .foregroundStyle(.gray)
//                    .frame(width: 30)
//                    .offset(y: 2)
                Text("+1")
                    .foregroundStyle(.black.opacity(0.8))
                    .offset(y: 2)
                
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .onChange(of: phoneNumber) { newValue in
                            phoneNumber = phoneNumberFormatter.string(for: newValue) ?? ""
                        }
                    Divider()
                }
            }
            .padding(.top, 5)
            
            HStack(alignment: .top) {
                Image(systemName: isCheckBoxClicked ? "checkmark.square" : "square")
                    .foregroundColor(isCheckBoxClicked || proceedWithoutAgree ? Color("AccentColor") : .gray.opacity(0.8))
                    .font(.system(size: 20))
                    .onTapGesture {
                        isCheckBoxClicked.toggle()
                    }
//                    .padding(1)
                    .background(isCheckBoxClicked ? Color("Orange").opacity(0.1) : Color.clear)
                    .cornerRadius(3)
                    .modifier(ShakeEffect(animatableData: CGFloat(proceedWithoutAgree ? 1 : 0)))

                Text("I have read and agree to Bear Phone's Terms and Service")
                    .tint(Color("AccentColor"))
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(.bottom, 5)
            }
            
            GradientButton(title: isLoading ? "Verifying": "Send Code", icon: "arrow.right", isLoading: $isLoading, onClick: {
                isLoading = true
                self.errorMessage = nil
                if let originalTransactionId = self.subscriptionManager.originalTransactionId {
                    print("Original Transaction ID: \(originalTransactionId)")
                    FirebaseAPI.checkHasAccountWithDifferentCredentials(originalTransactionId: originalTransactionId, phoneNumber: phoneNumber) { hasAccount in
                        if hasAccount == nil {
                            self.errorMessage = "Something went wrong. Please try again."
                            isLoading = false
                            isOtpLoading = false
                            return
                        }
                        if hasAccount == true {
                            self.errorMessage = "An account with a different phone number already exists. Please use the correct phone number."
                            isLoading = false
                            isOtpLoading = false
                            return
                        }
                        if hasAccount == false {
                            sendVerificationCode { success, error in
                                if success {
                                    askOTP.toggle()
                                } else {
                                    errorMessage = error?.localizedDescription
                                }
                            }
                        }
                    }
                } else {
                    sendVerificationCode { success, error in
                        if success {
                            askOTP.toggle()
                        } else {
                            errorMessage = error?.localizedDescription
                        }
                    }
                }
            })
            .hSpacing(.trailing)
            .disableWithOpacity(!isPhoneNumberComplete(phoneNumber) || !isCheckBoxClicked)
            .contentShape(Rectangle())
            .onTapGesture {
                if isPhoneNumberComplete(phoneNumber) && !isCheckBoxClicked {
                    errorMessage = "You must agree to NuPhon's Terms of Service and Privacy Policy to proceed."
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        errorMessage = nil
                    }
                    withAnimation {
                        proceedWithoutAgree = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        proceedWithoutAgree = false
                    }
                }
            }
        }
        .padding(.vertical, 15)
        .padding(.horizontal, 25)
        .sheet(isPresented: $askOTP, onDismiss: {
            /// Reset OTP if You Want
            isLoading = false
            isOtpLoading = false
            otpText = ""
        }, content: {
            if #available(iOS 16.4, *) {
                OTPView(otpText: $otpText, isOtpLoading: $isOtpLoading) { otp in
                    // Set the verification code from the otpText
                    self.verificationCode = otp
                    // Call the verify function
                    self.verifyCodeAndSignIn()
                }
                .presentationDetents([.height(350)])
                .presentationCornerRadius(30)
            } else { OTPView(otpText: $otpText, isOtpLoading: $isOtpLoading) { otp in
                // Set the verification code from the otpText
                self.verificationCode = otp
                // Call the verify function
                self.verifyCodeAndSignIn()
            }
            .presentationDetents([.height(350)])
            }
        })
    }
    
    private func sendVerificationCode(completion: @escaping (Bool, Error?) -> Void) {
        let e164PhoneNumber = "+1\(phoneNumber)"
        
        PhoneAuthProvider.provider().verifyPhoneNumber(e164PhoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print("ERROR!!!!!!")
                print(error)
                self.errorMessage = error.localizedDescription
                isLoading = false
                isOtpLoading = false
                completion(false, error)
                return
            }
            
            if let verificationID = verificationID {
                self.verificationID = verificationID
                self.isVerificationCodeFieldVisible = true
                completion(true, nil)
            } else {
                isLoading = false
                isOtpLoading = false
                completion(false, nil)
            }
        }
    }
    
    private func verifyCodeAndSignIn() {
        guard let verificationID = verificationID else {
            errorMessage = "Verification ID not found."
            isLoading = false
            isOtpLoading = false
            return
        }
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    isLoading = false
                    isOtpLoading = false
                }
                return
            }
            
            var attemptCount = 0
            let maxAttempts = 30

            DispatchQueue.main.async {
                let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    UserManager.shared.fetchSubAccountApiKey { isSuccess in
                        attemptCount += 1
                        if isSuccess {
                            timer.invalidate()
                            AgentManager.shared.fetchWakoAgent() { success in
                                DispatchQueue.main.async {
                                    askOTP.toggle()
                                    isLoading = false
                                    isOtpLoading = false
                                    accountManager.getUserAccount()
                                    if success {
                                        if let user = Auth.auth().currentUser {
                                            let db = Firestore.firestore()
                                            db.collection("users").document(user.uid).getDocument { (document, error) in
                                                if let document = document, document.exists {
                                                    var user_onboarded = document.get("user_onboarded") as? Bool ?? false
                                                    print("USER ONBOARDED: ", user_onboarded)
                                                    if user_onboarded {
                                                        Analytics.logEvent(AnalyticsEventLogin, parameters: [
                                                          AnalyticsParameterMethod: "phone_number"
                                                          ])
                                                        appState.currentView = .agent
                                                        appState.previousView = .login
                                                    }
                                                    else {
                                                        print("signUp")
                                                        Analytics.logEvent(AnalyticsEventSignUp, parameters: [
                                                          AnalyticsParameterMethod: "phone_number"
                                                        ])
                                                        Analytics.logEvent("new_install", parameters: ["value": "install"])
                                                        appState.currentView = .nameUser
                                                        appState.previousView = .login
                                                    }
                                                } else {
                                                    Analytics.logEvent(AnalyticsEventLogin, parameters: [
                                                      AnalyticsParameterMethod: "error"
                                                      ])
                                                    appState.currentView = .error
                                                    appState.previousView = .login
                                                }
                                            }
                                        }
                                    } else {
                                        appState.currentView = .error
                                        appState.previousView = .login
                                    }
                                }
                            }
                        } else if attemptCount >= maxAttempts {
                            timer.invalidate()
                            DispatchQueue.main.async {
                                isLoading = false
                                isOtpLoading = false
                                appState.currentView = .error
                                appState.previousView = .login
                            }
                        }
                    }
                }
            }
        }

    }
}
