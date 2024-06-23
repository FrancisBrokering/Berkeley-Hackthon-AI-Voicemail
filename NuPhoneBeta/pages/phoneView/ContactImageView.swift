import SwiftUI

struct ContactImageView: View {
    let callData: CallData
    let frameSize: CGFloat = 40
    
    var body: some View {
        Group {
            if let image = callData.contactImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: frameSize, height: frameSize)
                    .clipShape(Circle())
                    .padding(.trailing, 4)
            } else if let initials = callData.initials {
                Text(initials)
                    .frame(width: frameSize, height: frameSize)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .frame(width: frameSize, height: frameSize)
                    )
                    .padding(.trailing, 4)
            } else {
                Circle()
                    .fill(.white)
                    .frame(width: frameSize, height: frameSize)
                    .overlay(
                        LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.4)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            .mask(
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: frameSize, height: frameSize)
                            )
                    )
                    .padding(.trailing, 4)
            }
        }
    }
}
