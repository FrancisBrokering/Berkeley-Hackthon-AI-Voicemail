import SwiftUI

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

struct TextBubbleView: View {
    var content: String
    var isAgent: Bool
    @State private var isFocused: Bool = false
    
    var body: some View {
        Text(isAgent ? content : content.capitalizingFirstLetter())
            .padding(10)
            .background(
                isAgent ? Constants.orangeGradient : LinearGradient(
                    gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.2)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(isAgent ? .white : .black)
            .cornerRadius(14)
            .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 16))
            .contextMenu {
                Button(action: {
                    UIPasteboard.general.string = content
                }) {
                    Text("Copy")
                    Image(systemName: "doc.on.doc")
                }
            }
            .frame(maxWidth: 250, alignment: isAgent ? .trailing : .leading)
            .onTapGesture {  }
            .onLongPressGesture(minimumDuration: 0.5) {
                self.isFocused.toggle()
            }
            .onDisappear {
                self.isFocused = false
            }
    }
}
