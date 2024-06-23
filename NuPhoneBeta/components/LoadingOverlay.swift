import SwiftUI
import RiveRuntime

struct LoadingOverlay: View {
    let loadingTexts = ["Loading.", "Loading..", "Loading..."]
    @EnvironmentObject var appState: AppState
    @State private var timer: Timer?
    @State private var currentIndex = 0
    
    var body: some View {
        ZStack {
            Color(.black)
                .opacity(0.4)
            
            VStack {
                RiveViewModel(fileName: "loadingSquare").view()
                    .frame(height: 320)
                    .padding(.bottom, -90)
                    .padding(.top, -60)
                
                Text(loadingTexts[currentIndex])
                    .foregroundColor(Color(.white))
            }
            
        }
        .ignoresSafeArea()
        .onAppear() {
            appState.displayNavBar = false
            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                currentIndex = (currentIndex + 1) % loadingTexts.count
            }
        }
        .onDisappear() {
            appState.displayNavBar = true
            timer?.invalidate()
                            timer = nil
        }
    }
}
