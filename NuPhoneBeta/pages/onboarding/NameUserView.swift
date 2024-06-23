//
//  NameUserView.swift
//  NuPhoneBeta
//
//  Created by Francis Brokering on 2/28/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct NameUserView: View {
    @EnvironmentObject var appState: AppState
    @State var errorMessage: String?
    @ObservedObject var agentManager = AgentManager.shared
    @ObservedObject var accountManager = AccountManager.shared
    @FocusState private var isKeyboardShowing: Bool
    
    let userId = UserManager.shared.currentUserId
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Your Name")
                .font(.largeTitle)
                .fontWeight(.heavy)
            
            Text("This is the name your AI assistant will refer to you by")
                .font(.callout)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
                .padding(.top, -5)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "person")
                    .foregroundStyle(.gray)
                    .frame(width: 30)
                    .offset(y: 2)
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Your Name", text: $accountManager.userName)
                        .textContentType(.givenName)
                        .focused($isKeyboardShowing)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isKeyboardShowing = true
                        }
                    //                        .keyboardType(.phonePad)
                    Divider()
                }
            }
            .padding(.top, 5)
//            if isLoading {
//                ProgressView()
//            } else {
            GradientButton(title: "Continue", icon: "arrow.right", isLoading: .constant(false), onClick: {
                if let user = Auth.auth().currentUser {
                    let db = Firestore.firestore()
                    db.collection("users").document(user.uid).updateData(["user_name": accountManager.userName]) { error in
                        if let error = error {
                            errorMessage = "Something went wrong. Please try again."
                            print("Error writing document: \(error)")
                        } else {
                            accountManager.getUserAccount()
                            appState.currentView = .createAgent
                            appState.previousView = .nameUser
                            print("Document successfully written!")
                        }
                    }
                }
            })
            .hSpacing(.trailing)
            .disableWithOpacity(accountManager.userName == "")
        }
        .padding(.horizontal, 30)
        .frame(maxHeight: .infinity)
        .overlay(
            ZStack {
                Button(action: {
                    do {
                        try Auth.auth().signOut()
                        appState.currentView = .login
                    }
                    catch {
                        
                    }
                }) {
                    HStack {
                        Image(systemName: "arrowshape.backward.circle")
                            .font(.title)
                            .foregroundColor(Color("AccentColor"))
                        Text("Back")
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    }
                    .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                
            }
            .frame(height: 70)
            .frame(maxHeight: .infinity, alignment: .top)
        )
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                Button("Done"){
                    isKeyboardShowing = false
                }
                .tint(Color("Orange"))
                .fontWeight(.heavy)
                .hSpacing(.trailing)
            }
        }
    }
}

#Preview {
    NameUserView()
}
