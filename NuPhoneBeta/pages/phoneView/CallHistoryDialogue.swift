import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct CallHistoryDialogue: View {
    var dateGroupKey: String?
    @ObservedObject var callData: CallData
    @ObservedObject var callsManager = CallsManager.shared
    @EnvironmentObject var appState: AppState
    
    //    init() {
    //        UITabBar.appearance().isHidden = true
    //    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                ScrollView {
                    VStack(spacing: 20) {
                        Spacer() // Create space for the audio button
                            .frame(height: 70) // Adjust this height to match the audio button's height + desired padding
                        
                        LazyVStack(spacing: 10) {
                            ForEach(callData.messages, id: \.content) { message in
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
                        .padding(.top)
                    }
                    .padding(.bottom, 100)
                }
                
                
                Spacer() // Push the button to the bottom
                GradientButton(
                    title: "Call Back",
                    icon: "phone",
                    isLoading: .constant(false),
                    onClick: {
                        if let url = URL(string: "tel://\(callData.fromNumber)"), UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }
                )
                .padding(.horizontal, 40)
                //                .offset(y: -5)
            }
            
            AudioPlayButton(callId: callData.id)
                .padding(.horizontal, 20)
                .offset(y: 15)
                .zIndex(1)
        }
        .navigationTitle("Chat Details")
        
        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            appState.displayNavBar = false
//            }
            self.markAsOpened()
        }
//        .onDisappear {
//            appState.displayNavBar = true
//        }
    }
    
    private func markAsOpened() {
        let db = Firestore.firestore()
        if let user = Auth.auth().currentUser {
            db.collection("users").document(user.uid).collection("calls").document(callData.id).updateData(["has_opened": true]) { error in
                if error != nil {
                    print("Error updating has_opened field for call: \(self.callData.id)")
                }
            }
        }
        let newCallData = CallData(id: callData.id,
                                   uri: callData.uri,
                                   toNumber: callData.toNumber,
                                   fromNumber: callData.fromNumber,
                                   status: callData.status,
                                   startTime: callData.startTime,
                                   //                                   endTime: callData.endTime,
                                   messages: callData.messages,
                                   hasOpened: true)
        callsManager.updateCallHistory(call: newCallData)
    }
}
