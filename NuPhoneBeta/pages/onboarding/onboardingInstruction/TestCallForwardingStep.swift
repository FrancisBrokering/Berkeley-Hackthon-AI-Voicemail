import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import RiveRuntime

struct TestCallForwardingStep: View {
    @Binding var forwardVerifiedResult: Bool?
    @Binding var isForwardVerifiedLoading: Bool
    @Binding var displayTestCallForwardingSheet: Bool
    @State var secondsPassed = 0
    @State var timer: Timer? = nil
    @EnvironmentObject var appState: AppState
    @ObservedObject var callManager = TestCallManager.shared
    
    let confetti = RiveViewModel(fileName: "confetti", stateMachineName: "State Machine 1")
    
    var body: some View {
        VStack (alignment: .center, spacing: 20) {
            
            Text("Check activation")
                .font(.largeTitle)
                .fontWeight(.heavy)
            
            VStack (alignment: .leading,  spacing: 10) {
//                Text("Verify agent activation")
//                    .font(.headline)
                
                HStack{
                    Text("To test your setup, tap 'Verify'. You'll receive a call from \(Constants.testCallPhoneNumber). Please ") + Text("DECLINE").bold() + Text(" this call to complete the verification.")
                }
                .subTextStyle()
                    
                GradientButton(title: forwardVerifiedResult == false ? "Try again" : "Verify", iconPosition: .left, isLoading: .constant(false), onClick: {
                    DispatchQueue.main.async {
                        forwardVerifiedResult = nil
                        isForwardVerifiedLoading = true
                        callManager.callDeclined = false
                        callManager.callAccepted = false
                    }
                    if let user = Auth.auth().currentUser {
                        let db = Firestore.firestore()
                        db.collection("users").document(user.uid).updateData(["forward_verified": false]) { error in
                            if let error = error {
                                print("ERROR: ", String(describing: error))
                                isForwardVerifiedLoading = false
                                forwardVerifiedResult = false
                                return
                            } else {
                                UserManager.shared.getCurrentIdToken { idToken, error in
                                        guard let idToken = idToken, error == nil else {
                                            isForwardVerifiedLoading = false
                                            forwardVerifiedResult = false
                                            return
                                        }
                                        
                                        FirebaseAPI.testCallUser(idToken: idToken) { success in
                                            if success {
                                                if let user = Auth.auth().currentUser {
                                                    DispatchQueue.main.async {
                                                        let db = Firestore.firestore()
                                                        secondsPassed = 0
                                                        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                                                            secondsPassed += 1
                                                            db.collection("users").document(user.uid).getDocument { (document, error) in
                                                                if let document = document, document.exists {
                                                                    forwardVerifiedResult = document.get("forward_verified") as? Bool
                                                                    if forwardVerifiedResult == true {
                                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                                                                            try? confetti.triggerInput("Trigger explosion")
                                                                        }
                                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                                                                            displayTestCallForwardingSheet = false
                                                                        }
                                                                        isForwardVerifiedLoading = false
                                                                        timer.invalidate()
                                                                    }
                                                                } else {
                                                                    print("No account id found")
                                                                }
                                                            }
                                                            if secondsPassed >= 30 || forwardVerifiedResult == true {
                                                                isForwardVerifiedLoading = false
                                                                timer.invalidate()
                                                            }
                                                        }
                                                        timer?.fire()
                                                    }
                                                }
                                            } else {
                                                print("NOT SUCCESS")
                                                isForwardVerifiedLoading = false
                                                forwardVerifiedResult = false
                                            }
                                        }
                                }
                                
                            }
                        }
                    }
                })
                .disableWithOpacity(isForwardVerifiedLoading || forwardVerifiedResult == true)
                .onReceive(callManager.$callAccepted) { newValue in
                    if newValue {
                        isForwardVerifiedLoading = false
                    }
                }
                
                if isForwardVerifiedLoading {
                    if callManager.callDeclined {
                        VStack(alignment: .center){
                            RiveViewModel(fileName: "loadingSquare").view()
                                .frame(height: 320)
                                .padding(.bottom, -60)
                                .padding(.top, -60)
                            
                            Text("Verifying setup. ")
                                .font(.caption)
                            + Text("You can retry in \(30 - secondsPassed)s")
                                .font(.caption)
                        }
                    }
                    else {
                        VStack(alignment: .center){
                            RiveViewModel(fileName: "declineCall").view()
                                .frame(height: 320)
                                .padding(.bottom, -60)
                                .padding(.top, -60)
                            
                            Text("Please decline the call.")
                                .font(.caption)
                            Text("You can retry in \(30 - secondsPassed)s")
                                .font(.caption)
                        }
                    }
                }
                
                else if callManager.callAccepted {
                    VStack(alignment: .center){
                        RiveViewModel(fileName: "errorIconRed").view()
                            .frame(height: 250)
                            .padding(.bottom, -50)
                            .padding(.top, -40)
                            .allowsHitTesting(false)
                        
                        Text("Call was not forwarded to agent")
                        Text("Try again and decline the call")
                            .font(.caption).opacity(0.7)
                    }
                }
                
                else if forwardVerifiedResult == false {
                    VStack(alignment: .center){
                        RiveViewModel(fileName: "errorIconRed").view()
                            .frame(height: 250)
                            .padding(.bottom, -50)
                            .padding(.top, -40)
                            .allowsHitTesting(false)
                        
                        Text("Agent is not active")
                        Text("Please repeat the activation process or contact support at nuphone@wako.ai")
                            .font(.caption).opacity(0.7)
                    }
                }
                
                else if forwardVerifiedResult == true {
                    VStack(alignment: .center){
                        RiveViewModel(fileName: "successIcon").view()
                            .frame(height: 180)
                            .overlay(
                                ZStack{
                                    confetti.view()
                                        .scaleEffect(4)
                                        .allowsHitTesting(false)
                                }
                            )
                        Text("Assistant is active. You are all set!")
//                        Text("You are all set!")
                    }
                    .padding(.top, 40)
                }
            }
        }
        .frame(maxHeight: .infinity)
        .onDisappear() {
            forwardVerifiedResult = nil
            isForwardVerifiedLoading = false
            callManager.callDeclined = false
            callManager.callAccepted = false
            secondsPassed = 0
            timer?.invalidate()
            timer = nil
        }
//        .overlay(
//            ZStack {
//                if forwardVerifiedResult == false && isForwardVerifiedLoading == false {
//                    Text("Skip")
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            appState.currentView = .agent
//                        }
//                        .foregroundColor(Color("AccentColor"))
//                    //                    .font(.largeTitle.weight(.bold))
//                        .fontWeight(.semibold)
//                        .frame(maxWidth: .infinity, alignment: .trailing)
//                        .padding(.leading, 20)
//                }
//            }
//            .frame(height: 70)
//            .frame(maxHeight: .infinity, alignment: .top)
//        )
    }
}

#if DEBUG
struct TestCallForwardingStep_Previews: PreviewProvider {
    @State static var forwardVerifiedResult: Bool? = nil
    @State static var isForwardVerifiedLoading: Bool = false
    
    static var previews: some View {
        TestCallForwardingStep(forwardVerifiedResult: $forwardVerifiedResult, isForwardVerifiedLoading: $isForwardVerifiedLoading, displayTestCallForwardingSheet:  .constant(false))
            .previewLayout(.sizeThatFits) // You can change the layout to fit your needs
            .padding() // Adds some padding around the preview
    }
}
#endif
