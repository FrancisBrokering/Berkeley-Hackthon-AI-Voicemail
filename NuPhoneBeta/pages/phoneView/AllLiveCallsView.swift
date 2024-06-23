import SwiftUI

struct AllLiveCallsView: View {
    @ObservedObject var callsManager = CallsManager.shared
    @EnvironmentObject var appState: AppState
    
    init() {
        UITabBar.appearance().isHidden = true
    }
//    @State private var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
//    @ObservedObject var fakeWebsocket: FakeWebsocket
//    @StateObject var fakeWebsocket = FakeWebsocket.shared
    

    var body: some View {
        List(callsManager.liveCalls, id: \.id) { liveCall in // Assuming 'id' is a unique identifier in liveCall
            NavigationLink(destination: LiveCallDialogue(liveCall: liveCall)) {
                HStack {
                    ContactImageView(callData: liveCall)
                    VStack(alignment: .leading) {
                        Text(liveCall.callerName)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        HStack{
                            Text(liveCall.firstRelevantMessage())
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.vertical, 5)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .listStyle(PlainListStyle())
        // .background(Constants.nuPhoneBackgroundGray)
        .navigationTitle("Calls")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(false)
        
        .onAppear {
            appState.displayNavBar = false
        }
    }

}
