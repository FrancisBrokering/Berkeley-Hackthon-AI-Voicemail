import SwiftUI
import FirebaseAuth
import FirebaseFirestore

enum ActionType: String, CaseIterable {
    case notify = "NOTIFY"
    case transferCall = "TRANSFER_CALL"
    case hangUp = "HANGUP"
    
    var friendlyName: String {
        switch self {
        case .notify:
            return "Notify"
        case .transferCall:
            return "Transfer Call"
        case .hangUp:
            return "Hang Up"
        }
    }
    
    //    var functionName: String {
    //        switch self {
    //        case .notify:
    //            return "notify_"
    //        case .transferCall:
    //            return "transfer_call_"
    //        case .hangUp:
    //            return "hang_up_"
    //        }
    //    }
}

struct Action: Equatable {
    var name: String
    var type: ActionType
    var trigger: String
    var arguments: [String: String]
    var transfer_to: String?
    
    static func == (lhs: Action, rhs: Action) -> Bool {
        return lhs.type == rhs.type && lhs.trigger == rhs.trigger && lhs.arguments == rhs.arguments && lhs.transfer_to == rhs.transfer_to
    }
}

struct ActionsView: View {
    var proxy: ScrollViewProxy
    @EnvironmentObject var appState: AppState
    @State private var actions: [Action] = []
    @State private var isDropDownExpanded = false
    @State private var notifyDescriptionValue: String = "you know the caller's name."
    @State private var transferDescriptionValue: String = "if the caller wants to schedule an appointment."
    @State private var hangupDescriptionValue: String = "the caller says goodbye"
    @State private var isEditingTransferToNumber: Bool = false
    @State private var expandedIndices: Set<Int> = []
    @State private var showSheet = false
    
    let actionTypes = ActionType.allCases
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Actions")
                    Spacer()
                }
                .font(.title3).bold()
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            
            ForEach(actions.indices, id: \.self) { index in
                VStack(alignment: .leading) {
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expandedIndices.contains(index) },
                            set: { isExpanded in
                                if isExpanded {
                                    expandedIndices.insert(index)
                                } else {
                                    expandedIndices.remove(index)
                                }
                            }
                        )
                    ) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Action type")
                                    .font(.subheadline)
                                Spacer()
                                Button(action: {
                                    triggerFeedback()
                                    withAnimation {
                                        appState.displayedModal = .deleteAction
                                    }
                                    appState.alertAction = {
                                        deleteAction(at: index)
                                    }
                                }) {
                                    Text("Delete")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                }
                            }
                            .font(.title3).bold()
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            ActionCard(action: $actions[index], isEditingTransferToNumber: $isEditingTransferToNumber, proxy: proxy, actionTypes: actionTypes, index: index)
                        }
                        .padding(.vertical, 20)
                    } label: {
                        Text("Action \(index+1) (\(actions[index].type.friendlyName))")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .buttonStyle()
            }
            
            Button(action: {
                addAction()
            }) {
                HStack {
                    Image(systemName: "plus")
                        .foregroundColor(.black)
                    Text("Add Action")
                        .foregroundColor(.black)
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle()
            
            Spacer(minLength: isEditingTransferToNumber ? 200 : 0)
        }
        .agentCardStyle()
        .onAppear {
            loadActions()
        }
        .onChange(of: actions) { _ in
            autoSaveActions()
        }
    }
    
    func addAction() {
        let index = actions.count
        let newAction = Action(name: "function_" + "\(generateRandomString(length: 6))", type: .notify, trigger: notifyDescriptionValue, arguments: [:], transfer_to: nil)
        actions.append(newAction)
    }
    
    func deleteAction(at index: Int) {
        actions.remove(at: index)
        //        updateAllActionNames()
    }
    
    //    func updateActionName(for actionIndex: Int, with actionType: ActionType) {
    //        print("actionIndex: ", actionIndex)
    //        print("actionType: ", actionType)
    //        if actionIndex < actions.count {
    //            actions[actionIndex].name = actionType.functionName + "\(actionIndex)"
    //            print("actionType.functionName: ", actionType.functionName)
    //            print("ACTION NAME: ", actions[actionIndex].name)
    //        }
    //        print("ACTIONS: ", actions)
    //        print("actions.count", actions.count)
    //    }
    
    //    func updateAllActionNames() {
    //        for (index, action) in actions.enumerated() {
    //            updateActionName(for: index, with: action.type)
    //        }
    //    }
    
    func autoSaveActions() {
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            let actionData = actions.map { action in
                var actionDict: [String: Any] = [
                    "name": action.name,
                    "type": action.type.rawValue,
                    "trigger": action.trigger,
                    "arguments": action.arguments
                ]
                if let transfer_to = action.transfer_to {
                    actionDict["transfer_to"] = transfer_to
                }
                return actionDict
            }
            db.collection("users").document(user.uid).updateData(["actions": actionData]) { error in
                if let error = error {
                    print("Error saving actions: \(error)")
                } else {
                    print("Actions successfully saved!")
                }
            }
        }
    }
    
    func loadActions() {
        if let user = Auth.auth().currentUser {
            let db = Firestore.firestore()
            db.collection("users").document(user.uid).getDocument { document, error in
                if let document = document, document.exists {
                    if let actionData = document.data()?["actions"] as? [[String: Any]] {
                        self.actions = actionData.map { data in
                            let name = data["name"] as? String ?? ""
                            let type = ActionType(rawValue: data["type"] as? String ?? "") ?? .notify
                            let trigger = data["trigger"] as? String ?? ""
                            let arguments = data["arguments"] as? [String: String] ?? [:]
                            let transfer_to = data["transfer_to"] as? String
                            return Action(name: name, type: type, trigger: trigger, arguments: arguments, transfer_to: transfer_to)
                        }
                    }
                } else {
                    print("Document does not exist")
                }
            }
        }
    }
}

struct ActionCard: View {
    @Binding var action: Action
    @Binding var isEditingTransferToNumber: Bool
    @State var isEditingDescription: Bool = false
    var proxy: ScrollViewProxy
    var actionTypes: [ActionType]
    var index: Int
    let phoneNumberFormatter = PhoneNumberFormatter()
    //    var updateActionName: (Int, ActionType) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            DropDownView(
                selection: Binding(
                    get: { action.type.rawValue },
                    set: { newValue in
                        if let newType = ActionType(rawValue: newValue) {
                            action.type = newType
                            //                            updateActionName(index, newType)
                            setDefaultTrigger(for: newType)
                        }
                    }
                ),
                title: "Action Type",
                prompt: "Select action type",
                options: actionTypes.map { DropDownOption(text: $0.rawValue, displayText: $0.friendlyName) }
            )
            
            if action.type == .notify {
                VStack {
                    HStack {
                        Text("Notify me when...")
                            .font(.subheadline)
                        Spacer()
                    }
                    .font(.title3).bold()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Text(action.trigger)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isEditingDescription.toggle()
                        }
                        .fakeTextAreaStyle()
                }
            } else if action.type == .transferCall {
                VStack {
                    HStack {
                        Text("Transfer the call when...")
                            .font(.subheadline)
                        Spacer()
                    }
                    .font(.title3).bold()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Text(action.trigger)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isEditingDescription.toggle()
                        }
                        .fakeTextAreaStyle()
                }
                VStack(alignment: .leading) {
                    Text("Transfer to")
                    Input(
                        inputValue: Binding(
                            get: { action.transfer_to ?? "" },
                            set: { newValue in action.transfer_to = phoneNumberFormatter.string(for: newValue) }
                        ),
                        isEditing: $isEditingTransferToNumber,
                        placeholder: "(123) 456-7890",
                        proxy: proxy,
                        scrollId: action.name,
                        keyBoardType: .phonePad
                    )
                }
            } else if action.type == .hangUp {
                VStack {
                    HStack {
                        Text("Hang up the call when...")
                            .font(.subheadline)
                        Spacer()
                    }
                    .font(.title3).bold()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Text(action.trigger)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isEditingDescription.toggle()
                        }
                        .fakeTextAreaStyle()
                }
            }
        }
        .sheet(isPresented: $isEditingDescription) {
            FullScreenEditorView(
                title: "Trigger when...",
                text: $action.trigger,
                onSave: {
                    isEditingDescription = false
                },
                onCancel: {
                    isEditingDescription = false
                },
                wordCountLimit: 100
            )
            .presentationCornerRadius(20)
        }
    }
    
    func setDefaultTrigger(for actionType: ActionType) {
        switch actionType {
        case .notify:
            action.trigger = "you know the caller's name."
        case .transferCall:
            action.trigger = "ff the caller wants to schedule an appointment."
        case .hangUp:
            action.trigger = "the caller says goodbye."
        }
    }
}

func generateRandomString(length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return String((0..<length).map { _ in letters.randomElement()! })
}
