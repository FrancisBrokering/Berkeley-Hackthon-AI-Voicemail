import SwiftUI

struct LiveCallDialogue: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var liveCall: CallData
    @ObservedObject var callsManager = CallsManager.shared
    @StateObject var fakeWebsocket = FakeWebsocket.shared
    @State private var isCallActive = true
    @State private var isAcceptCallLoading = false
    @State private var isDeclineCallLoading = false
    
//    init() {
//        UITabBar.appearance().isHidden = true
//    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                HStack {
                    Text("\(liveCall.callerName)")
                        .font(.subheadline)
                        .foregroundColor(Color.gray)
                }
                .padding(.vertical, 5)
            }
            .padding(.horizontal)
            .padding(.top, 20)
            //shadow on the bottom
//            .shadow(color: Color("shadow").opacity(0.1), radius: 5, x: 0, y: 5)
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(liveCall.messages) { message in
                        HStack {
                            if message.role != .agent {
                                TextBubbleView(content: message.content, isAgent: false)
                                Spacer()
                            } else {
                                Spacer()
                                TextBubbleView(content: message.content, isAgent: true)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .background(.white)
            .padding(.bottom, 20)
            
            
            HStack(spacing: 10) {
                Button(action: {
                    isDeclineCallLoading = true
                   UserManager.shared.getCurrentIdToken { idToken, error in
                       DispatchQueue.main.async {
                           guard let idToken = idToken, error == nil else {
                               // Handle error or absence of token
                               print("Error or no ID Token: \(error?.localizedDescription ?? "Unknown error")")
                               return
                           }
                           CallsAPI.sendInstructionToAgent(liveCall: liveCall, instruction: "hang_up", idToken: idToken) { _ in
                               DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                   isDeclineCallLoading = false
                               }
                           }
                       }
                   }
               }) {
                    HStack {
                        Image(systemName: "phone.down")
                        Text(isCallActive ? "Decline" : "Call Ended")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.red)
                    .cornerRadius(10)
                }
                .disableWithOpacity(!isCallActive || isAcceptCallLoading)
//                .padding(.horizontal)
                .offset(y: -30)

                Button(action: {
                    isAcceptCallLoading = true
                    UserManager.shared.getCurrentIdToken { idToken, error in
                        DispatchQueue.main.async {
                            guard let idToken = idToken, error == nil else {
                                // Handle error or absence of token
                                print("Error or no ID Token: \(error?.localizedDescription ?? "Unknown error")")
                                return
                            }
                            CallsAPI.sendInstructionToAgent(liveCall: liveCall, instruction: "transfer_call", idToken: idToken) { _ in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    isAcceptCallLoading = false
                                }
                            }
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "phone")
                        Text(isCallActive ? "Accept" : "Call Ended")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.green)
                    .cornerRadius(10)
                }
                .disableWithOpacity(!isCallActive || isDeclineCallLoading)
                .padding(.horizontal)
                .offset(y: -30)
            }

        }
        .navigationTitle("Live Call")
        .edgesIgnoringSafeArea(.bottom)
        
        //update selected call when callsManager changes
        .onReceive(callsManager.$liveCalls) { _ in
            if let updatedCall = callsManager.liveCalls.first(where: { $0.id == liveCall.id }) {
                liveCall.messages = updatedCall.messages
            }
            isCallActive = callsManager.liveCalls.contains(where: { $0.id == liveCall.id })
        }
        .onAppear() {
//            appState.displayNavBar = false
            fakeWebsocket.startFakeWebsocket()
        }
        .onDisappear() {
            fakeWebsocket.stopFakeWebsocket()
            appState.notificationCallId = nil
        }
    }
}
