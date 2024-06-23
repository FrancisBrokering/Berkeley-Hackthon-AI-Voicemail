//
//  AllCallHistoryView.swift
//  NuPhoneBeta
//
//  Created by Francis Brokering on 3/7/24.
//

import SwiftUI

struct AllCallHistoryView: View {
    @ObservedObject var callsManager = CallsManager.shared
    @EnvironmentObject var appState: AppState
    @StateObject var fakeWebsocket = FakeWebsocket.shared
    @State var displayDialouge = false
    
//    init() {
//        UITabBar.appearance().isHidden = true
//    }
    
    var groupedCalls: [String: [CallData]] {
        let isoDateFormatter = ISO8601DateFormatter()
        isoDateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // Configure to handle fractional seconds
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd" // Desired format for grouping
        
        // Add a DateFormatter for comparing dates without time
        let comparisonFormatter = DateFormatter()
        comparisonFormatter.dateFormat = "yyyy-MM-dd"
        
        let now = Date()
        let todayDateString = comparisonFormatter.string(from: now)
        
        return Dictionary(grouping: callsManager.callHistory) { callData in
            guard let date = isoDateFormatter.date(from: callData.startTime) else {
                return "Unknown Date" // Handle parsing failure, adjust as necessary
            }
            let callDateString = comparisonFormatter.string(from: date)
            if callDateString == todayDateString {
                return "Today"
            } else {
                return dateFormatter.string(from: date)
            }
        }
    }
    
    var sortedKeys: [String] {
        groupedCalls.keys.sorted(by: >) // assuming you want the latest dates first
    }
    
    var body: some View {
        List {
            ForEach(sortedKeys, id: \.self) { key in
//                Section(header: Text(key)) {
                    ForEach(groupedCalls[key]!, id: \.id) { callData in
                        NavigationLink(destination: CallHistoryDialogue(dateGroupKey: key, callData: callData)) {
                            HStack {
                                Circle()
                                        .fill(callData.hasOpened ? Color.gray.opacity(0.1) : Color.blue)
                                        .frame(width: 10, height: 10)
                                        .padding(.trailing, 0)
                                
                                ContactImageView(callData: callData)
                                
                                VStack(alignment: .leading) {
                                    Text(callData.callerName)
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.black)
                                    HStack{
                                        Text(callData.firstRelevantMessage())
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                Spacer()
                                Text(callData.formattedDate)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 5)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
//                }
            }
        }
        .onAppear {
            fakeWebsocket.startFakeWebsocket()
//            appState.currentView = .callHistory
            appState.displayNavBar = false
            CallsManager.fetchCallHistory(){ (success) in
                if success {
                    print("call hsitory success")
                }
            }
        }
        .onDisappear() {
//            appState.displayNavBar = true
            fakeWebsocket.stopFakeWebsocket()
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
        .listStyle(PlainListStyle())
        .navigationTitle("History")
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(false)
        
    }
}
