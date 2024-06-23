import SwiftUI

struct FreestyleInstructionsView: View {
    @Binding var agent: Agent
    @Binding var editedValue: String
    @Binding var isEditingFreestyleInstructions: Bool
    @ObservedObject var accountManager = AccountManager.shared
    
    var body: some View {
        VStack {
            VStack(alignment: .center, spacing: 20) {
                Text(agent.prompt.instructions.freestyle_instruction )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.white)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        isEditingFreestyleInstructions.toggle()
                        editedValue = agent.prompt.instructions.freestyle_instruction
                    }
                    .fakeTextAreaStyle()
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
    }
}
