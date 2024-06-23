import SwiftUI

struct DropDownOption: Identifiable {
    let id: String
    let text: String
    let displayText: String
    let isPremium: Bool
    
    init(text: String, displayText: String, isPremium: Bool = false) {
        self.id = UUID().uuidString
        self.text = text
        self.displayText = displayText
        self.isPremium = isPremium
    }
}


struct DropDownView: View {
    @EnvironmentObject var appState: AppState
    @Binding var selection: String
    @ObservedObject var accountManager = AccountManager.shared
    let title: String
    let prompt: String
    var options: [DropDownOption]
    var frameWidth: CGFloat = .infinity
    @State private var isExpanded = false
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack {
                HStack {
                    Text(selection != "" ? options.first { $0.text == selection }?.displayText ?? selection : prompt)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                        .rotationEffect(.degrees(isExpanded ? -180 : 0))
                }
                .frame(height: 40)
                .padding(.horizontal)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.snappy) {
                        isExpanded.toggle()
                    }
                }
                
                if isExpanded {
                    VStack {
                        ForEach(options) { option in
                            HStack(spacing: 5) {
                                Text(option.displayText)
                                    .foregroundStyle(selection == option.text ? Color.primary : .gray)
                                Spacer()
                                if selection == option.text {
                                    Image(systemName: "checkmark")
                                        .font(.subheadline)
                                        .foregroundColor(Color("AccentColor"))
                                }
                            }
                            .frame(height: 40)
                            .padding(.horizontal)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    selection = option.text
                                    isExpanded.toggle()
                                }
                                
                            }
                        }
                    }
                    .transition(.move(edge: .bottom))
                }
            }
            .buttonStyle()
            .frame(maxWidth: frameWidth)
        }
    }
}

