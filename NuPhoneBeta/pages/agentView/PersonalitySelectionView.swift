import SwiftUI
import CoreHaptics

let availablePersonalities: [String] = ["😊friendly", "💼formal", "🤖robotic", "🤓nerdy", "🤔curious", "🤗helpful", "🤩excited", "😎cool", "😂funny"]

struct PersonalitySelectionView: View {
    @EnvironmentObject var agentManager: AgentManager
    @Binding var agent: Agent
    @State var selectedPersonalities: [String]

//    let availablePersonalities: [String]
    
//    @Binding var selectedPersonalities: [String]
//    @Binding var selectedPersonalitiesArray: [String]
//    private var selectedPersonalities: Binding<Set<String>> {
//        Binding<Set<String>>(
//            get: { Set(self.selectedPersonalitiesArray) },
//            set: { self.selectedPersonalitiesArray = Array($0) }
//        )
//    }
    init (agent: Binding<Agent>) {
        self._agent = agent
        _selectedPersonalities = State(initialValue: agent.wrappedValue.prompt.personality)
    }
    @Environment(\.presentationMode) var presentationMode
    @State private var showWarningMessage = false
    @State private var shakePersonalityId: String? = nil
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Select Personalities")
                .font(.title3)
                .padding(.vertical, 10)
                .bold()
            
            if showWarningMessage {
                Text("You can select up to 3 personalities.")
                    .foregroundColor(.red)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.showWarningMessage = false
                        }
                    }
            }
            else {
                Text("You can select up to 3 personalities.")
                    .foregroundColor(.clear)
            }
            
            let columns = [GridItem(.adaptive(minimum: 100, maximum: 220), spacing: 0)]
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(availablePersonalities, id: \.self) { personality in
                    Button(action: {
                        if selectedPersonalities.contains(personality) {
                            if let index = selectedPersonalities.firstIndex(of: personality) {
                                selectedPersonalities.remove(at: index)
                                agent.prompt.personality = selectedPersonalities
                                agentManager.updateAgentConfiguration(newAgent: agent){_ in}
                                shakePersonalityId = nil
                            }
                        } else {
                            if selectedPersonalities.count < 3 {
                                selectedPersonalities.append(personality)
                                agent.prompt.personality = selectedPersonalities
                                agentManager.updateAgentConfiguration(newAgent: agent){_ in}
                                print("Appended personality", personality)
                                print("selectedPersonalities: ", selectedPersonalities)
                            } else {
                                withAnimation {
                                    shakePersonalityId = personality
                                }
                                triggerErrorFeedback()
                                showWarningMessage = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    shakePersonalityId = nil
                                }
                            }
                        }
                    }) {
                        Text(personality)
                            .padding(10)
                            .background(
                                selectedPersonalities.contains(personality)
                                ? Constants.orangeGradient
                                : LinearGradient(gradient: Gradient(colors: [Color.white, Color.white]), startPoint: .leading, endPoint: .trailing)
                            )
                            .foregroundColor(selectedPersonalities.contains(personality) ? .white : .black)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(shakePersonalityId == personality ? Color.red : selectedPersonalities.contains(personality) ? Color.white : Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .modifier(ShakeEffect(animatableData: CGFloat(shakePersonalityId == personality ? 1 : 0)))
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
    
    // this will vibrate the phone
    private func triggerErrorFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 1
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}
