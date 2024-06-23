import SwiftUI

struct OrDivider: View {
    var body: some View {
        HStack {
            VStack{
                Divider()
            }
            .frame(maxWidth: .infinity)
            //                        .frame(maxWidth: .infinity)
            .background(.gray)
            Text("OR")
                .foregroundColor(.black.opacity(0.8))
                .padding(.horizontal, 10)
            VStack{
                Divider()
            }
            .frame(maxWidth: .infinity)
            //                        .frame(maxWidth: .infinity)
            .background(.gray)
        }
    }
}

