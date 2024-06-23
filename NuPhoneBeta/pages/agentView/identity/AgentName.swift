import SwiftUI

struct AgentNameCard: View {
    @Binding var isEditingName: Bool
    @Binding var agentName: String
    var proxy: ScrollViewProxy
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Name")
                Spacer()
//                EditIconButton { isEditingName.toggle() }
            }
            .font(.title3).bold()
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Input(inputValue: $agentName, isEditing: $isEditingName, proxy: proxy, scrollId: "Name")
        }
        .agentCardStyle()
    }
}
