import SwiftUI

struct AgentInstructionsCard: View {
    @Binding var agent: Agent
    @Binding var editedValue: String
//    @Binding var editedYouAreValue: String
//    @Binding var editedMainTaskValue: String
//    @Binding var editedConcludeByValue: String
//    @Binding var isEditingYouAre: Bool
//    @Binding var isEditingMainTask: Bool
//    @Binding var isEditingConcludeBy: Bool
    @Binding var isEditingFreestyleInstructions: Bool
//    @Binding var isGuidedSelected: Bool
//    @Binding var isFreestyleSelected: Bool
    var proxy: ScrollViewProxy
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Prompt")
                    Spacer()
                    //                EditIconButton {
                    //                    isEditingFreestyleInstructions.toggle()
                    //                    editedValue = agentPurpose
                    //                }
                }
                .font(.title3).bold()
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
//            GuidedInstructionsView(agent: $agent, isEditingYouAre: _isEditingYouAre, isEditingMainTask: _isEditingMainTask, isEditingConcludeBy: _isEditingConcludeBy, isGuidedSelected: $isGuidedSelected, isFreestyleSelected: $isFreestyleSelected, editedValue: $editedValue)
//            OrDivider()
            FreestyleInstructionsView(agent: $agent, editedValue: $editedValue, isEditingFreestyleInstructions: $isEditingFreestyleInstructions)
        }
        .agentCardStyle()
    }
}
