import SwiftUI
import SwiftUIX
import FirebaseAuth
import AVFoundation
import RiveRuntime


struct AgentView: View {
    @ObservedObject private var kGuardian = KeyboardGuardian(textFieldCount: 1)
    @ObservedObject var userManager = UserManager.shared
    @ObservedObject var accountManager = AccountManager.shared
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var agentManager: AgentManager
    @State private var agent: Agent = AgentManager.shared.agent ?? defaultAgent
    @State private var displayTestCallForwardingSheet: Bool = false
    @State private var isEditingName = false
    @State private var isEditingMessage = false
    @State private var isEditingFreestyleInstructions = false
//    @State private var isFreestyleSelected: Bool
//    @State private var isGuidedSelected: Bool
//    @State private var isEditingYouAre = false
//    @State private var isEditingMainTask = false
//    @State private var isEditingConcludeBy = false
    @State var index = 0
    @State private var valueBeforeEditing: String = ""
    @State private var editedValue: String = ""
    @State private var isShowingPersonalityModal = false
    @State var selectedCarrier: String = "Verizon"
    @State private var showDeleteAlert = false
    @State private var audioPlayer: AVAudioPlayer?
    @State var forwardVerifiedResult: Bool?
    @State var isForwardVerifiedLoading: Bool = false
    @State private var agentName: String
    @State private var selectedLLM: String = "claude-3-haiku"
    
    init(agent: Agent) {
        UISegmentedControl.appearance().backgroundColor = .white
        let storedCarrier = UserDefaults.standard.string(forKey: "phoneCarrier") ?? "Verizon"
        self._selectedCarrier = State(initialValue: storedCarrier)
        self.agent = agent
        _agentName = State(initialValue: agent.metadata["name"] as? String ?? "")
//        self._selectedLLM = "gpt-3.5-turbo"
//        let isFreestyle = AgentManager.shared.agent?.prompt.instructions.instruction_type == .freestyle
//        _isFreestyleSelected = State(initialValue: isFreestyle)
//        _isGuidedSelected = State(initialValue: !isFreestyle)
    }
        
    var body: some View {
        ZStack {
            MovingBackground()
                .padding(.bottom, 20)
                .blur(radius: 10)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(hexadecimal: "#002676")]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .edgesIgnoringSafeArea(.top)
                )
                .edgesIgnoringSafeArea(.top)
            
            VStack {
                VStack(alignment: .center, spacing: 10) {
                    HStack(alignment: .center, spacing: 10) {
                        Text("Assistant")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .fontWeight(.bold)
                        
                        Spacer()
                        Button(action: {
                            if let url = URL(string: "tel://\(Constants.agentPhoneNumber)"),
                               UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Label(agentName, systemImage: "phone.fill")
                                .foregroundColor(Color(.white))
                                .bold()
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                            
                        }
                        .background(.ultraThinMaterial, in:
                                        RoundedRectangle(cornerRadius: 10, style: .continuous))
                        
                        .shadow(color: Color("shadow").opacity(0.1), radius: 5, x: 0, y: 5)
                       
                    }
                    .padding(.horizontal, 20)
                }
                
                
                VStack {
                    HStack(spacing: 0){
                        Text("Identity")
                            .foregroundColor(self.index == 0 ? Color("AccentColor") : Color.white)
                            .fontWeight(.bold)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .background(Color.white.opacity(self.index == 0 ? 1 : 0))
                            .clipShape(Capsule())
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    self.index = 0
                                }
                            }
                        
                        Spacer(minLength: 0)
                        
                        Text("Instructions")
                            .foregroundColor(self.index == 1 ? Color("AccentColor") : Color.white)
                            .fontWeight(.bold)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .background(Color.white.opacity(self.index == 1 ? 1 : 0))
                            .clipShape(Capsule())
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    self.index = 1
                                }
                            }
                        
                        Spacer(minLength: 0)
                        
                        Text("Activation")
                            .foregroundColor(self.index == 2 ? Color("AccentColor") : Color.white)
                            .fontWeight(.bold)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .background(Color.white.opacity(self.index == 2 ? 1 : 0))
                            .clipShape(Capsule())
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    self.index = 2
                                }
                            }
                    }
                    .background(Color(hexadecimal: "fdb517").opacity(0.6))
                    .clipShape(Capsule())
                    .padding(.horizontal)
                    
                    VStack{
                            TabView(selection: self.$index) {
                                ScrollView {
                                    ScrollViewReader { proxy in
                                        VStack {
                                            AgentNameCard(isEditingName: $isEditingName, agentName: $agentName, proxy: proxy)
                                            voiceSection
                                            personalitySection
//                                            AgentPhoneNumberCard()
                                        }
                                    }
                                    .padding(.top, 20)
                                    .padding(.bottom, 100)
                                    
                                    
                                }
                                .tag(0)
                                
                                ScrollView {
                                    ScrollViewReader { proxy in
                                        VStack {
                                            llmSection
                                            greetingMessageSection
                                            AgentInstructionsCard(agent: $agent, editedValue: $editedValue, isEditingFreestyleInstructions: $isEditingFreestyleInstructions, proxy: proxy)
                                            FaqView()
                                            ActionsView(proxy: proxy)
                                        }
                                    }
                                    .padding(.top, 20)
                                    .padding(.bottom, 100)
                                    
                                }
                                .tag(1)
                                
                                ScrollView {
                                    VStack(spacing: 10) {
                                        agentActivationView
                                    }
                                    .padding(.top, 20)
                                    .padding(.bottom, 100)
                                    
                                    
                                }
                                .tag(2)
                                
                            }
                            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                            .onChange(of: index){ _ in
                                if isEditingName {
                                    isEditingName.toggle()
                                }
                                if isEditingMessage {
                                    isEditingMessage.toggle()
                                }
                                if isEditingFreestyleInstructions {
                                    isEditingFreestyleInstructions.toggle()
                                }
                            }
                            Spacer(minLength: 0)
//                        }
                        
                    }
                    .background(Constants.nuPhoneBackgroundGray)
                    .frame(maxHeight: .infinity)
                }
            }
            .onChange(of: isEditingName) { newValue in
                if !newValue {
                    agentManager.updateAgentConfiguration(newAgent: agent){_ in}
                }
            }
            .onChange(of: isEditingMessage) { newValue in
                if !newValue {
                    agentManager.updateAgentConfiguration(newAgent: agent){_ in}
                }
            }
            .onChange(of: isEditingFreestyleInstructions) { newValue in
                if !newValue {
                    agentManager.updateAgentConfiguration(newAgent: agent){_ in}
                }
            }
            .onReceive(agent.$voice) { _ in
                if let newVoiceModel = AvailableVoice.voiceId(for: agent.voice.name) {
                    let provider = AvailableVoice.provider(for: newVoiceModel) ?? "azure"
                    print("VOICE: ", newVoiceModel)
                    if provider == "azure" {
                        agent.voice.provider = provider
                        agent.voice.model = newVoiceModel
                        agentManager.updateAgentConfiguration(newAgent: agent){_ in}
                    }
                    else if provider == "elevenlabs" {
                        agent.voice.provider = provider
                        agent.voice.voice_id = newVoiceModel
                        agentManager.updateAgentConfiguration(newAgent: agent){_ in}
                    }
                }
            }
            .onChange(of: agentName) { newValue in
                // Update the agent's metadata dictionary when the name changes
                agent.metadata["name"] = newValue
                agentManager.updateAgentConfiguration(newAgent: agent){_ in}
            }
//            .onChange(of: isGuidedSelected) { _ in agentManager.updateAgentConfiguration(newAgent: agent){_ in}}
//            .onChange(of: isEditingYouAre) { newValue in
//                if !newValue {
//                    agentManager.updateAgentConfiguration(newAgent: agent){_ in}
//                }
//            }
//            .onChange(of: isEditingMainTask) { newValue in
//                if !newValue {
//                    agentManager.updateAgentConfiguration(newAgent: agent){_ in}
//                }
//            }
//            .onChange(of: isEditingConcludeBy) { newValue in
//                if !newValue {
//                    agentManager.updateAgentConfiguration(newAgent: agent){_ in}
//                }
//            }
            
            if appState.displayedModal == .deleteFaq {
                CustomAlert(title: "Delete FAQ", buttonTitle: "Delete", isDisableButton: false, content:
                    VStack (alignment: .leading){
                        Text("Are you sure you want to delete this FAQ?")
                            .subTextStyle()
                            .padding(.bottom, 10)
                    }
                ) {
                    appState.performAlertAction()
                }
            }
            
            if appState.displayedModal == .deleteAction {
                CustomAlert(title: "Delete Action", buttonTitle: "Delete", isDisableButton: false, content:
                    VStack (alignment: .leading){
                        Text("Are you sure you want to delete this Action?")
                            .subTextStyle()
                            .padding(.bottom, 10)
                    }
                ) {
                    appState.performAlertAction()
                }
            }
        }
    }
    
    var personalitySection: some View {
        get {
            _ = [GridItem(.adaptive(minimum: 105, maximum: 200), spacing: 0)]
            
            return VStack(alignment: .center, spacing: 20) {
                HStack {
                    Text("Personality")
                    Spacer()
                }
                .font(.title3).bold()
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack(spacing: 5) {
                    ForEach(agent.prompt.personality, id: \.self) { personality in
                        Text(personality)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 5)
                            .background(
                                .white
                            )
                            .foregroundColor(.black)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .onTapGesture {
                    isShowingPersonalityModal.toggle()
                    triggerFeedback()
                }
            }
            .agentCardStyle()
            .sheet(isPresented: $isShowingPersonalityModal) {
                PersonalitySelectionView(agent: $agent)
                .presentationDetents([.height(350)])
            }
            
        }
    }
    
    func playVoiceSample() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            guard let fileName = AvailableVoice.fileName(for: agent.voice.name) else { return }
            guard let url = Bundle.main.url(forResource: fileName, withExtension: nil) else { return }
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
        } catch {
            print("Audio Session error: \(error)")
        }
    }
    
    
    var voiceSection: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack {
                Text("Voice")
                Spacer()
            }
            .font(.title3).bold()
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack{
                DropDownView(selection: $agent.voice.name,
                                     title: "Voice",
                                     prompt: "Select a voice",
                                     options: voiceOptions
                )
                GradientButton(title: "Play Voice", icon: "speaker.wave.2", iconPosition: .left, isLoading: .constant(false), onClick: {
                    playVoiceSample()
                })
            }
        }
        .contentShape(Rectangle())
        .agentCardStyle()
    }
    
    var llmSection: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack {
                Text("Language Model")
                Spacer()
            }
            .font(.title3).bold()
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack{
                DropDownView(selection: $selectedLLM,
                                     title: "model",
                                     prompt: "Select a model",
                                     options: llmOptions
                )
            }
        }
        .contentShape(Rectangle())
        .agentCardStyle()
    }
    
    var greetingMessageSection: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Greeting Message")
                Spacer()
            }
            .font(.title3).bold()
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading, spacing: 10) {
//                Text("Intro sentence")
                HStack {
                    Text(agent.initial_message.greeting_message)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white)
                        .onTapGesture {
                            isEditingMessage.toggle()
                            editedValue = agent.initial_message.greeting_message
                        }
                }
                .fakeTextAreaStyle()
            }
        }
        .agentCardStyle()
        .sheet(isPresented: $isEditingMessage) {
            FullScreenEditorView(
                title: "Greeting Message",
                text: $editedValue,
                onSave: {
                    // Handle save action
                    agent.initial_message.greeting_message = editedValue
                    isEditingMessage = false
                },
                onCancel: {
                    // Handle cancel action
                    //                    agentInitialMessage = valueBeforeEditing
                    isEditingMessage = false
                },
                wordCountLimit: 30
            )
            .presentationCornerRadius(20)
        }
    }
    
    var agentActivationView: some View {
        return VStack(alignment: .center, spacing: 20) {
            HStack {
                Text("Activation")
                Spacer()
            }
            .font(.title3).bold()
            .foregroundColor(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(alignment: .leading) {
                Text("Carrier")
                    .font(.headline)
                
                DropDownView(selection: $selectedCarrier, title: "Cell Carrier", prompt: "Select cell carrier", options: cellCarriers)
                    .onChange(of: selectedCarrier) { newCarrier in
//                        if let carrier = newCarrier {
                            UserDefaults.standard.set(newCarrier, forKey: "phoneCarrier")
                            print("Carrier changed to: \(newCarrier)")
//                        }
                    }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Activate")
                    .font(.headline)
                
                    let forwardingNumber = callForwardingActivate(for: selectedCarrier, phoneNumber: Constants.agentPhoneNumber)
                
                    HStack {
                        Button(action: {
                            UIPasteboard.general.string = forwardingNumber
                        }) {
                            Image(systemName: "doc.on.clipboard")
                                .foregroundColor(Color("AccentColor"))
                        }
                        .padding(.trailing, 8)
                        Text(forwardingNumber)
                            .foregroundColor(.black.opacity(0.8))
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                    }
                    .frame(maxWidth: .infinity)
                    
                    GradientButton(title: "Call and Activate", icon: "phone", iconPosition: .left, isLoading: .constant(false), onClick: {
                        if let url = URL(string: "tel://\(forwardingNumber)"), UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    })
//                }
                
                OrDivider()
                
                Text("Deactivate")
                    .font(.headline)
                
                    let deactivationForwardingNumber = callForwardingDeactivate(for: selectedCarrier)
                    
                    HStack {
                        Button(action: {
                            UIPasteboard.general.string = deactivationForwardingNumber
                        }) {
                            Image(systemName: "doc.on.clipboard")
                                .foregroundColor(Color("AccentColor"))
                        }
                        .padding(.trailing, 8)
                        Text(deactivationForwardingNumber)
                            .bold()
                            .foregroundColor(.black.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                    }
                    .frame(maxWidth: .infinity)
                Button(action: {
                            if let url = URL(string: "tel://\(deactivationForwardingNumber)"),
                               UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "phone")
                                Text("Call and Deactivate")
                            }
                            .foregroundColor(.black)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle()
            }
        }
        .agentCardStyle()
        
    }
    
}

struct FullScreenEditorView: View {
    var title: String
    
    @Binding var text: String
    var onSave: () -> Void
    var onCancel: () -> Void
    var wordCountLimit: Int
    
    var body: some View {
        VStack {
            HStack {
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(Color.black.opacity(0.6))
                }
                Spacer()
                Text(title)
                    .font(.title3)
                    .bold()
                Spacer()
                if text.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count > wordCountLimit {
                    Text("Exceeded")
                        .font(.title3)
                        .foregroundColor(Color.red) // Change to red to indicate limit exceeded
                } else {
                    Button("Save", action: onSave)
                        .font(.title3)
                        .foregroundColor(Color("AccentColor"))
                }
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 20)
            
            TextEditor(text: $text)
                .padding(.horizontal, 20)
            
            // Display the word count and change color if limit is exceeded
            HStack {
                Spacer()
                Text("\(text.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count) / \(wordCountLimit)")
                    .font(.caption)
                    .foregroundColor(text.split(whereSeparator: { $0.isWhitespace || $0.isNewline }).count > wordCountLimit ? Color.red : Color.gray) // Change color to red if over limit
                    .padding(.trailing, 20)
                    .padding(.bottom, 10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


struct TagView: View {
    let isOnline: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(isOnline ? Color.green : Color.red)
                .frame(width: 10, height: 10)
            
            Text(isOnline ? "Online" : "Offline")
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(isOnline ? Color.blue : Color.gray)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white, lineWidth: 2)
        )
    }
}
