import SwiftUI
import RiveRuntime

struct ErrorView: View {
    @EnvironmentObject var appState: AppState
    //    var errorMessage: String
    //    var retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
//            Image(systemName: "exclamationmark.triangle")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 100, height: 100)
//                .foregroundColor(.red)
            
            RiveViewModel(fileName: "errorIcon").view()
                .frame(height: 250)
                .padding(.bottom, -60)
            
            Text("Oops!")
                .font(.largeTitle)
                .foregroundColor(.white)
                .bold()
            
            Text("Something went wrong.")
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.7))
            
            //            Button(action: {currentView = previousView}) {
            //                Text("Go Back")
            //                    .bold()
            //                    .padding()
            //                    .background(Color.blue)
            //                    .foregroundColor(.white)
            //                    .cornerRadius(8)
            //            }
            Button(action: {
                appState.currentView = appState.previousView
//                appState.previousView = .error
            }, label: {
                HStack(spacing: 15) {
                    Image(systemName: "arrow.left")
                    Text("Go Back")
                        .fontWeight(.bold)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 35)
                .foregroundColor(Color("Pink"))
                .background(Color.white.opacity(0.8))
                .clipShape(Capsule())
            })
            .overlay(Capsule().stroke(Color("Pink"), lineWidth: 2))
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(
            VStack{
                RiveViewModel(fileName: "shapes").view()
//                    .scaleEffect(x: -1, y: 1)
                    .ignoresSafeArea()
                    .offset(x: -50, y: -50)
                    .blur(radius: 50)
                    .background(
                        MovingBackground()
                            .padding(.bottom, 20)
                            .blur(radius: 10)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("Orange"), Color("Pink"), Color("Pink"), Color("Blue")]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                                .edgesIgnoringSafeArea(.top)
                            )
                            .edgesIgnoringSafeArea(.all)
                    )
            }
        )
    }
}


struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView()
    }
}
