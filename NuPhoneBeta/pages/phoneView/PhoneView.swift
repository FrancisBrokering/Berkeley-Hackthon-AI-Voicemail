import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import RiveRuntime

struct PhoneView: View {
    @State private var selectedLiveCall: CallData?
    @State private var selectedCallHistory: CallData?
    @ObservedObject var callsManager = CallsManager.shared
    @EnvironmentObject var appState: AppState
    //    @Environment(\.notificationCallId) var notificationCallId: Binding<String?>
    @StateObject var fakeWebsocket = FakeWebsocket.shared
    
    func selectLiveCall(byID id: String) {
        if let call = callsManager.liveCalls.first(where: { $0.id == id }) {
            selectedLiveCall = call
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Calls")
                    //                        .padding(.top, 30)
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding(.leading, 20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Live Calls
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Live").font(.title3).bold()
                            Spacer()
                            if !callsManager.liveCalls.isEmpty {
                                NavigationLink(destination: AllLiveCallsView()) {
                                    Text("See All")
                                }
                                .onAppear() {
                                    appState.displayNavBar = true
                                }
                            }
                        }
                        .padding(.bottom)
                        
                        if callsManager.liveCalls.isEmpty {
                            Text("No live calls currently.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(callsManager.liveCalls.prefix(3)) { liveCall in
                                Button(action: {
                                    selectedLiveCall = liveCall
                                }) {
                                    HStack {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 10, height: 10)
                                            .padding(.trailing, 0)
                                        
                                        ContactImageView(callData: liveCall)
                                        
                                        VStack(alignment: .leading) {
                                            Text(liveCall.callerName)
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.black)
                                            Text(liveCall.firstRelevantMessage())
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                                .truncationMode(.tail)
                                                .lineLimit(1)
                                        }
                                        Spacer()
                                        
                                    }
                                    .contentShape(Rectangle())
                                    .padding(.vertical, 7)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .phoneCardStyle()
                    
                    // Call History
                    VStack(alignment: .leading) {
                        HStack {
                            Text("History").font(.title3).bold()
                            Spacer()
                            if !callsManager.callHistory.isEmpty {
                                NavigationLink(destination: AllCallHistoryView()) {
                                    Text("See All")
                                }
                                .onAppear() {
                                    appState.displayNavBar = true
                                }
                            }
                        }
                        .padding(.bottom)
                        
                        if callsManager.callHistory.isEmpty {
                            Text("No call history available.")
                                .foregroundColor(.gray)
                        }
                        else {
                            ForEach(callsManager.callHistory.prefix(5)) { callData in
                                Button(action: {
                                    selectedCallHistory = callData
                                }) {
                                    HStack {
                                        Circle()
                                            .fill(callData.hasOpened ? Color.gray.opacity(0.1) : Color.blue)
                                            .frame(width: 10, height: 10)
                                            .padding(.trailing, 0)
                                        
                                        ContactImageView(callData: callData)
    
                                        VStack(alignment: .leading) {
                                            Text(callData.callerName)
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .foregroundColor(.black)
                                            
                                            HStack {
                                                Text(callData.firstRelevantMessage())
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                                    .truncationMode(.tail)
                                                    .lineLimit(1)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        Text(callData.formattedDate)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                        
                                        //                                        Image(systemName: "chevron.right")
                                        //                                            .foregroundColor(.gray)
                                    }
                                    .contentShape(Rectangle())
                                    .padding(.vertical, 7)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .phoneCardStyle()
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 70)
            }
            .refreshable {
                DispatchQueue.main.async {
                    CallsManager.fetchCallHistory(){ (success) in
                        if success {
                            print("call hsitory success")
                        }
                    }
                }
            }
            .background(
                //                VStack{
                //                    RiveViewModel(fileName: "shapes").view()
                //                        .scaleEffect(x: 1, y: -1)
                //                        .ignoresSafeArea()
                //                        .blur(radius: 30)
                //                        .background(
                //                            Image("background")
                //                                .blur(radius: 50)
                //
                //                        )
                //                        .offset(x: -100, y:-300)
                //
                //                }
                ZStack {
                    MovingBackground()
                        .padding(.bottom, 20)
                        .blur(radius: 10)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("Blue")]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .edgesIgnoringSafeArea(.top)
                        )
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                    ArcShape(arcHeight: 30)
                        .fill(Color(.white))
                        .offset(y: +(UIScreen.main.bounds.height / 7))
                    
                }
                
            )
            
            .sheet(item: $selectedLiveCall) { liveCall in
                LiveCallDialogue(liveCall: liveCall)
            }
            .sheet(item: $selectedCallHistory) { callData in
                CallHistoryDialogue(callData: callData)
            }
            //            .onAppear() {
            //                appState.currentView = .phone
            //            }
            
        }
        .onReceive(appState.$notificationCallId) { newID in
            print("notificationCallId changed: ", newID)
            print("live calls: ", callsManager.liveCalls)
            if let id = newID {
                selectLiveCall(byID: id)
            }
        }
        .onAppear() {
            fakeWebsocket.startFakeWebsocket()
            CallsManager.fetchCallHistory(){ (success) in
                if success{
                    print("FETCHED CALL HISTORY")
                }
            }
        }
        .onDisappear() {
            fakeWebsocket.stopFakeWebsocket()
        }
    }
    
}


struct ArcShape: Shape {
    var arcHeight: CGFloat // This property will control the "strength" of the arc
    
    init(arcHeight: CGFloat = 50) { // Default arcHeight
        self.arcHeight = arcHeight
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Adjust the control point to be below the start and end points of the arc,
        // causing the arc to bend downwards.
        let controlPoint = CGPoint(x: rect.midX, y: rect.minY + arcHeight)
        
        // Draw the quadratic curve to form an arc at the top that bends downwards
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY),
                          control: controlPoint)
        
        // Complete the rectangle
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath() // This closes the path by drawing a line from the current point back to the starting point
        
        return path
    }
}

// Helper extension to create a Color from hexadecimal string
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.startIndex
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = Double((rgbValue & 0xff0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00ff00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000ff) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
