import SwiftUI

/// Custom SwiftUI View Extensions
extension View {
    /// View Alignments
    @ViewBuilder
    func hSpacing(_ alignment: Alignment = .center) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    @ViewBuilder
    func vSpacing(_ alignment: Alignment = .center) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
    
    /// Disable With Opacity
    @ViewBuilder
    func disableWithOpacity(_ condition: Bool) -> some View {
        self
            .disabled(condition)
            .opacity(condition ? 0.5 : 1)
    }
    
    @ViewBuilder
    func buttonStyle() -> some View {
        self
            //.background(scheme == .dark ? Color.black : Color.white)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
    }
    
    @ViewBuilder
    func gradientButtonStyle() -> some View {
        self
//            .fontWeight(.bold)
            .foregroundStyle(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 20) //make it 20 for capsule shape
            .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    func orangeCardStyle() -> some View {
        self
            .padding(20)
            .background(Color("AccentColor"))
            .cornerRadius(10)
//            .background(.thinMaterial, in:
//                            RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 20)
            .padding(.vertical, 5)
    }
        
    @ViewBuilder
    func agentCardStyle() -> some View {
        self
            .padding(20)
            .background(.white)
            .cornerRadius(10)
//            .background(.thinMaterial, in:
//                            RoundedRectangle(cornerRadius: 20, style: .continuous))
//                .overlay(
//                    RoundedRectangle(cornerRadius: 16, style: .continuous)
//                        .stroke(Color.white)
//                        .blendMode(.overlay)
//                )
//                .mask(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 20)
            .padding(.vertical, 5)
    }
    
    @ViewBuilder
    func phoneCardStyle() -> some View {
        self
            .padding(20)
//            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .background(.white.opacity(0.95))
        
            
            .cornerRadius(10)
//            .background(.thinMaterial, in:
//                            RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 20)
            .padding(.vertical, 5)
    }
    
    @ViewBuilder
    func fakeTextAreaStyle() -> some View {
        self
            .padding(.horizontal, 10)
            .padding(.vertical, 10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
    }
    
    @ViewBuilder
    func saveButtonStyle() -> some View {
        self
            .font(.system(size: 16))
            .foregroundStyle(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 30)
            .background(Constants.orangeGradient)
            .cornerRadius(10)
    }
    
    
    @ViewBuilder
    func isEditingTextFieldStyle() -> some View {
        self
            .foregroundColor(.black)
            .padding(.vertical, 10)
            .padding(.horizontal, 5)
            .background(Color("AccentColor").opacity(0.08))
            .mask(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color("AccentColor"), lineWidth: 1)
            )
    }
    
    @ViewBuilder
    func subTextStyle() -> some View {
        self
            .font(.caption)
            .foregroundColor(.black.opacity(0.8))
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(nil)
    }
}
