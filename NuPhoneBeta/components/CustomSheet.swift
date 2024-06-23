import SwiftUI

struct CustomSheet<Content: View>: View {
    @EnvironmentObject var appState: AppState
    var isKeyboard: Bool = false
    let content: Content
    
    let action: () -> ()
    @State private var offset: CGFloat = UIScreen.main.bounds.height

    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .onTapGesture {
                    close()
                }

            VStack(spacing: 10) {
                content
            }
            .fixedSize(horizontal: false, vertical: true)
            .agentCardStyle()
            .frame(width: UIScreen.main.bounds.width * 0.9)
            .overlay(alignment: .topTrailing) {
                Button {
                    close()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .foregroundColor(Color.black.opacity(0.6))
                        .padding(.top, 5)
                        .padding(.trailing, 20)
                }
                .tint(.black)
                .padding()
            }
            .shadow(radius: 20)
            .padding(30)
            .cornerRadius(20)
            .offset(x: 0, y: offset)
            .onAppear {
                withAnimation(.spring()) {
                    offset = 0
                }
                appState.displayNavBar = false
            }
            .onChange(of: isKeyboard) { newValue in
                withAnimation(.spring()) {
                    if newValue {
                        offset = -150
                    } else {
                        offset = 0
                    }
                }
            }
        }
        .ignoresSafeArea()
    }

    func close() {
        withAnimation(.spring()) {
            offset = UIScreen.main.bounds.height
            appState.displayedModal = nil
            appState.displayNavBar = true
        }
    }
}
