import Foundation
import Foundation
import Combine

let defaultAgent = Agent(
    initialMessage: InitialMessage(),
    prompt: PromptConfig(),
//    voice: Voice(name: "Eva", provider: "azure", model: "en-US-AvaNeural", pitch: 0, rate: 0),
    voice: Voice(name: "Tara”", provider: "azure", model: "en-US-JennyMultilingualNeural"),
    id: "default_id",
    uri: "http://example.com",
    accountId: "account_default",
    createdAt: "2023-01-01T00:00:00Z",
    updatedAt: "2023-01-01T00:00:00Z",
    metadata: ["name": "Alex"]
)

class Agent: ObservableObject {
    @Published var initial_message: InitialMessage
    @Published var prompt: PromptConfig
    @Published var voice: Voice
    @Published var id: String
    @Published var uri: String
    @Published var account_id: String
    @Published var created_at: String
    @Published var updated_at: String
    @Published var metadata: [String: Any]

    init(initialMessage: InitialMessage, prompt: PromptConfig, voice: Voice, id: String, uri: String, accountId: String, createdAt: String, updatedAt: String, metadata: [String: Any]) {
        self.initial_message = initialMessage
        self.prompt = prompt
        self.voice = voice
        self.id = id
        self.uri = uri
        self.account_id = accountId
        self.created_at = createdAt
        self.updated_at = updatedAt
        self.metadata = metadata
    }
}



struct Webhook: Codable {
    var url: String
    var method: String
    var event: String
}

let initialMessageBeginning = "Hello, I'm "
let initialMessageEnding = "'s AI assistant powered by NuPhone."

let recordMessage = "This call may be monitored or recorded."

let concludeByMessage = "wishing them a good day"
let youAreMessage = "an AI assistant called "
let mainTaskMessage = "gather a message for "

class InitialMessage: ObservableObject, Codable {
    var call_recorded_message: String
    var greeting_message: String
    
    init(callRecordedMessage: String = recordMessage, greetingMessage: String = "Hey there, this is an AI assistant powered by NuPhone. How can I help you?") {
        self.call_recorded_message = callRecordedMessage
        self.greeting_message = greetingMessage
    }
}

class Voice: ObservableObject {
    @Published var name: String
    @Published var provider: String
    @Published var model: String?
    @Published var voice_id: String?
    
    init(name: String, provider: String, model: String) {
        self.name = name
        self.provider = provider
        self.model = model
        self.voice_id = nil
    }
    
    init(name: String, provider: String, voice_id: String) {
        self.name = name
        self.provider = provider
        self.model = nil
        self.voice_id = voice_id
    }
}


class PromptConfig: ObservableObject, Codable {
    var system_message: String
    var personality: [String]
    var instructions: Instructions
    var faqs: FAQ
    init(system_message: String = "You are a personal receptionist who answers missed calls. You interact through audio by interpreting spoken queries and replying with your own voice. Your replies are short to mimic a real-life conversation." , personality: [String] = ["😊friendly", "🤗helpful"], instructions: Instructions = Instructions(), faqs: FAQ = FAQ()) {
        self.system_message = system_message
        self.personality = personality
        self.instructions = instructions
        self.faqs = faqs
    }
}

struct FAQItem: Codable, Identifiable {
    var id = UUID()
    var question: String
    var answer: String
}

class FAQ: ObservableObject, Codable {
    var items: [FAQItem]
    
    init(items: [FAQItem] = [FAQItem(question: "What's your availability for this week?", answer: "Tuesday and Wednesday.")]) {
        self.items = items
    }
}


class Instructions: ObservableObject, Codable {
//    var instruction_type: InstructionType
    var freestyle_instruction: String
//    var guided_instructions: GuidedInstructions
    
    init(freestyle_instruction: String = "Start by asking for the caller’s name and reason for the call. Always provide answers that aim to be helpful. Conclude by wishing them a good day and asking if they enjoyed the conversation.") {
//        self.instruction_type = instruction_type
        self.freestyle_instruction = freestyle_instruction
//        self.guided_instructions = guided_instructions
    }
}

//class GuidedInstructions: ObservableObject, Codable {
//    var you_are: String
//    var main_task: String
//    var conclude_by: String
//    init(you_are: String = "a personal assistant", main_task: String = "gather a message", conclude_by: String = concludeByMessage) {
//        self.you_are = you_are
//        self.main_task = main_task
//        self.conclude_by = conclude_by
//    }
//}

extension String {
    func withoutEmoji() -> String {
        filter { $0.isASCII }
    }
}

func generateAgentPrompt(plan: String, promptConfig: PromptConfig, agentName: String, userName: String) -> String {
    var prompt = "IDENTITY\nYou are a personal receptionist"
    if (agentName != "") {
        prompt += " named \(agentName)"
    }
    prompt += " who answers missed calls"
    if (userName != "") {
        prompt += " for \(userName)"
    }
    prompt += ". You interact through audio by interpreting spoken queries and replying with your own voice. "
    if !promptConfig.personality.isEmpty {
        prompt += "Your personality traits are \(promptConfig.personality.joined(separator: ", ").withoutEmoji()). "
    }
    
    prompt += "Your replies are short to mimic a real-life conversation.\n\n"

    
    prompt += "INSTRUCTIONS\n"
//    switch promptConfig.instructions.instruction_type {
//    case .freestyle:
    prompt += promptConfig.instructions.freestyle_instruction
//    case .guided:
//        prompt += "You are \(promptConfig.instructions.guided_instructions.you_are). "
//        prompt += "Your main task is to \(promptConfig.instructions.guided_instructions.main_task). "
//        prompt += "When the caller says goodbye, conclude the conversation by \(promptConfig.instructions.guided_instructions.conclude_by).\n"
//    }
    
    if !promptConfig.faqs.items.isEmpty {
        prompt += "\n\nFAQ\n"
        for (index, faqItem) in promptConfig.faqs.items.enumerated() {
            prompt += "\(index + 1). Question: \(faqItem.question)"
            prompt += "   Answer: \(faqItem.answer)\n"
        }
    }
    
    return prompt
}

enum InstructionType: String, Codable {
    case guided, freestyle
}

struct AgentVoice {
    let name: String
    let fileName: String
    let voiceId: String
    let provider: String
}

var voiceOptions: [DropDownOption] {
    AvailableVoice.voices.map { voice in
        DropDownOption(text: voice.name, displayText: voice.name, isPremium: voice.provider == "elevenlabs")
//        DropDownOption(text: voice.name, displayText: voice.name)
    }
}

var llmOptions: [DropDownOption] {
    AvailableLLM.languageModel.map { llm in
        DropDownOption(text: llm, displayText: llm)
//        DropDownOption(text: voice.name, displayText: voice.name)
    }
}

class AvailableLLM {
    static let languageModel = ["claude-3-haiku", "claude-3-opus", "claude-3-sonnet", "gpt-3.5-turbo"]
}


class AvailableVoice {
//    static let voices = [
//        AgentVoice(name: "Casey", fileName: "en-US-AlloyMultilingualNeural.wav", voiceId: "en-US-AlloyMultilingualNeural"),
//        AgentVoice(name: "Tara", fileName: "en-US-ShimmerMultilingualNeural.wav", voiceId: "en-US-ShimmerMultilingualNeural"),
//        AgentVoice(name: "Cody", fileName: "en-US-FableMultilingualNeural.wav", voiceId: "en-US-FableMultilingualNeural"),
//        AgentVoice(name: "Dane", fileName: "en-US-OnyxMultilingualNeural.wav", voiceId: "en-US-OnyxMultilingualNeural"),
//        AgentVoice(name: "Brett", fileName: "en-US-EchoMultilingualNeural.wav", voiceId: "en-US-EchoMultilingualNeural"),
//        AgentVoice(name: "Eva", fileName: "en-US-NovaMultilingualNeural.wav", voiceId: "en-US-NovaMultilingualNeural"),
//    ]
    
    static let voices = [
        AgentVoice(name: "Eva", fileName: "en-US-EmmaMultilingualNeural.wav", voiceId: "en-US-EmmaMultilingualNeural", provider: "azure"),
        AgentVoice(name: "Cody", fileName: "en-US-RyanMultilingualNeural.wav", voiceId: "en-US-RyanMultilingualNeural", provider: "azure"),
        AgentVoice(name: "Tara", fileName: "en-US-JennyMultilingualNeural.wav", voiceId: "en-US-JennyMultilingualNeural", provider: "azure"),
        AgentVoice(name: "Jen", fileName: "en-US-AvaMultilingualNeural.wav", voiceId: "en-US-AvaMultilingualNeural", provider: "azure"),
        AgentVoice(name: "Brett", fileName: "en-US-BrianMultilingualNeural.wav", voiceId: "en-US-BrianMultilingualNeural", provider: "azure"),
        AgentVoice(name: "Casey", fileName: "en-US-AndrewMultilingualNeural.wav", voiceId: "en-US-AndrewMultilingualNeural", provider: "azure"),
        AgentVoice(name: "Hope", fileName: "Hope.wav", voiceId: "OYTbf65OHHFELVut7v2H", provider: "elevenlabs"),
        AgentVoice(name: "Rachel", fileName: "Rachel.wav", voiceId: "rachel", provider: "elevenlabs"),
        AgentVoice(name: "Scott", fileName: "Scott.wav", voiceId: "CVbhI883h2bnkDcj3jJQ", provider: "elevenlabs"),
        AgentVoice(name: "Ryan", fileName: "Ryan.wav", voiceId: "rU18Fk3uSDhmg5Xh41o4", provider: "elevenlabs"),
    ]
    
    static func fileName(for name: String) -> String? {
        return voices.first { $0.name == name }?.fileName
    }
    
    static func voiceId(for name: String) -> String? {
        return voices.first { $0.name == name }?.voiceId
    }
    
    static func name(for voiceId: String) -> String? {
        return voices.first { $0.voiceId == voiceId }?.name
    }
    
    static func provider(for voiceId: String) -> String? {
        return voices.first { $0.voiceId == voiceId }?.provider
    }
}


func mapPitchToIndex(_ input: Int) -> Int {
    switch input {
    case -5:
        return 0
    case 0:
        return 1
    default:
        return 2
    }
}

func mapRateToIndex(_ input: Int) -> Int {
    switch input {
    case -15:
        return 0
    case 0:
        return 1
    default:
        return 2
    }
}
