import SwiftUI

struct FreestyleInstructionsView: View {
    @Binding var agent: Agent
    @Binding var editedValue: String
    @Binding var isEditingFreestyleInstructions: Bool
//    @Binding var isGuidedSelected: Bool
//    @Binding var isFreestyleSelected: Bool
    @ObservedObject var accountManager = AccountManager.shared
//    @State private var displaySubscriptionSheet: Bool = false
    
//    private func swapRadio() {
//        self.isGuidedSelected = false
//        self.isFreestyleSelected = true
//        agent.prompt.instructions.instruction_type = .freestyle
//    }
    
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 20) {
//                VStack(alignment: .leading, spacing: 10){
//                    HStack(alignment: .center) {
//                        HStack(alignment: .center, spacing: 10) {
//                            RadioButton(selected: $isFreestyleSelected)
//                            Text("Freestyle")
//                                .font(.headline)
//                        }
//                        
//                        
//                        if accountManager.plan == "free" {
//                            PremiumIcon()
//                        }
//                        Spacer()
//                    }
//                    .contentShape(Rectangle())
//                    .onTapGesture {
//                        if accountManager.plan == "free" {
//                            withAnimation(.spring()) {
//                                displaySubscriptionSheet = true
//                            }
//                        }
//                        else {
//                            swapRadio()
//                        }
//                    }
//                    Text("Provide open-ended instructions to your assistant")
//                        .subTextStyle()
//                }
                Text(agent.prompt.instructions.freestyle_instruction )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white)
                    .contentShape(Rectangle())
                    .onTapGesture {
//                        if accountManager.plan == "free" {
//                            withAnimation(.spring()) {
//                                displaySubscriptionSheet = true
//                            }
//                        }
//                        else {
                            isEditingFreestyleInstructions.toggle()
                            editedValue = agent.prompt.instructions.freestyle_instruction
//                        }
                    }
                //                    .opacity(accountManager.plan == "free" ? 0.5 : 1)
                //                    .disableWithOpacity(accountManager.plan == "free")
                    .fakeTextAreaStyle()
//                    .opacity(accountManager.plan == "free" ? 0.5 : 1)
            }
        }
        .sheet(isPresented: $isEditingFreestyleInstructions) {
            FullScreenEditorView(
                title: "Prompt",
                text: $editedValue,
                onSave: {
//                    swapRadio()
                    agent.prompt.instructions.freestyle_instruction = editedValue
                    isEditingFreestyleInstructions = false
                },
                onCancel: {
                    isEditingFreestyleInstructions = false
                },
                wordCountLimit: 1000
            )
            .presentationCornerRadius(20)

        }
//        .sheet(isPresented: $displaySubscriptionSheet) {
//            PaywallView(clickedOnProFeature: true,  isDisplaySheet: $displaySubscriptionSheet)
//        }
    }
}
