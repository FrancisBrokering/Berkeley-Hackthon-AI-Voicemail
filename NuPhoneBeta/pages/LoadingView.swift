import SwiftUI
import RiveRuntime

struct LoadingView: View {
    var body: some View {
        VStack{
            VStack(spacing: 10) {
                Text("Powered by")
                    .font(.title3)
                    .foregroundColor(.black)
                Image("voiceOsLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 130)
            }
     
        }
        .padding(.bottom, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(
            Color(.white)
        )        
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
//            .previewLayout(.sizeThatFits)
//            .background(Color.black)
    }
}
