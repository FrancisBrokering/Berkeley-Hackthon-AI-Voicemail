import SwiftUI
import SwiftUIX

struct WelcomeView: View {
    @State var startAnimation: Bool = false
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            MovingBackground()
                .blur(radius: 10)
                .background(
                    Constants.backgroundGradient
                    .edgesIgnoringSafeArea(.top)
                )
                .edgesIgnoringSafeArea(.all)
            
            
            VStack {
                Spacer()
                VStack {
//                    Image("nuPhoneIconSmall")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 100)                    
                    
                    Text("Welcome")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding()
                        .foregroundColor(.white)
                    
                    Text("Bear AI Voicemail")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.bottom, 30)
                }
//                .padding()
//                .background(.ultraThinMaterial, in:
//                                RoundedRectangle(cornerRadius: 20, style: .continuous))
                
                
                Spacer()
                Button(action: {
                    appState.currentView = .login
                    appState.previousView = .welcome
                }, label: {
                    HStack(spacing: 15) {
                        Text("Get Started")
                            .fontWeight(.bold)
                            .foregroundColor(Color("AccentColor"))
                            .opacity(1)
                        Image(systemName: "arrow.right")
                            .foregroundColor(Color("AccentColor"))
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 35)
                    .background(Color.white)
                    .clipShape(Capsule())
                })
                .overlay(Capsule().stroke(Color.white, lineWidth: 2))
                .padding()

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            startAnimation = true 
        }
    }
    
    //    @ViewBuilder
    //    func Ball(offset: CGSize = .zero)->some View{
    //        Circle()
    //            .fill(.white)
    //            .frame(width: 150, height: 150)
    //            .offset(offset)
    //    }
}
//
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        // Binding variables can be simulated with constant values for preview purposes
        WelcomeView()
            .previewDevice("iPhone 12") // You can specify a device for the preview
    }
}
