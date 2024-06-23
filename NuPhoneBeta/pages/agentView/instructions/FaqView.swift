import SwiftUI

struct FaqView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject private var agent: Agent = AgentManager.shared.agent ?? defaultAgent
    @EnvironmentObject var agentManager: AgentManager
    @State private var isEditingQuestion: Bool = false
    @State private var isEditingAnswer: Bool = false
    @State private var editedQuestion: String = ""
    @State private var editedAnswer: String = ""
    @State private var selectedFaqIndex: Int = 0
    @State private var showWarningMessage = false
    @State private var expandedIndices: Set<Int> = []
    
    private func addFaq() {
        agent.prompt.faqs.items.append(FAQItem(question: "New Question", answer: "New Answer"))
        agentManager.updateAgentConfiguration(newAgent: agent) { _ in }
    }
    
    private func deleteFaq(index: Int) {
        agent.prompt.faqs.items.remove(at: index)
        agentManager.updateAgentConfiguration(newAgent: agent) { _ in }
    }
    
    var body: some View {
        VStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("FAQs")
                    Spacer()
                }
                .font(.title3).bold()
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            ForEach(0..<agent.prompt.faqs.items.count, id: \.self) { index in
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
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(index + 1). Question")
                                    .font(.subheadline)
                                Spacer()
                                Button(
                                    action: {
                                        triggerFeedback()
                                        withAnimation {
                                            appState.displayedModal = .deleteFaq
                                        }
                                        appState.alertAction = {
                                            self.deleteFaq(index: index)
                                        }
                                    }
                                ) {
                                    Text("Delete")
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                }
                            }
                            .font(.title3).bold()
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(agent.prompt.faqs.items[index].question)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    self.selectedFaqIndex = index
                                    self.editedQuestion = agent.prompt.faqs.items[index].question
                                    self.isEditingQuestion = true
                                }
                                .fakeTextAreaStyle()
                            
                            HStack {
                                Text("Answer")
                                    .font(.subheadline)
                                Spacer()
                            }
                            .font(.title3).bold()
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Text(agent.prompt.faqs.items[index].answer)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    self.selectedFaqIndex = index
                                    self.editedAnswer = agent.prompt.faqs.items[index].answer
                                    self.isEditingAnswer = true
                                }
                                .fakeTextAreaStyle()
                        }
                        .padding(.vertical, 20)
                    } label: {
                        Text(agent.prompt.faqs.items[index].question)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .lineLimit(1) 
                            .truncationMode(.tail)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .buttonStyle()
            }
            
            Button(action: {
                addFaq()
            }) {
                HStack {
                    Image(systemName: "plus")
                        .foregroundColor(.black)
                    Text("Add FAQ")
                        .foregroundColor(.black)
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
            }
            .disableWithOpacity(agent.prompt.faqs.items.count >= 10)
            .buttonStyle()
        }
        .agentCardStyle()
        .sheet(isPresented: $isEditingQuestion) {
            FullScreenEditorView(
                title: "Edit Question",
                text: $editedQuestion,
                onSave: {
                    agent.prompt.faqs.items[selectedFaqIndex].question = editedQuestion
                    agentManager.updateAgentConfiguration(newAgent: agent) { _ in }
                    isEditingQuestion = false
                },
                onCancel: {
                    isEditingQuestion = false
                },
                wordCountLimit: 100
            )
            .presentationCornerRadius(20)
        }
        .sheet(isPresented: $isEditingAnswer) {
            FullScreenEditorView(
                title: "Edit Answer",
                text: $editedAnswer,
                onSave: {
                    agent.prompt.faqs.items[selectedFaqIndex].answer = editedAnswer
                    agentManager.updateAgentConfiguration(newAgent: agent) { _ in }
                    isEditingAnswer = false
                },
                onCancel: {
                    isEditingAnswer = false
                },
                wordCountLimit: 100
            )
            .presentationCornerRadius(20)
        }
    }
}
