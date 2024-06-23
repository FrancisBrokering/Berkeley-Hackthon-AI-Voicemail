import SwiftUI

// Define an enum for icon position
enum IconPosition {
    case left, right
}

// Define a struct for GradientButton
struct GradientButton: View {
    var title: String
    var icon: String?
    var iconPosition: IconPosition = .right
    @Binding var isLoading: Bool
    var onClick: () -> Void

    var body: some View {
        Button(action: {
            if !isLoading {
                onClick()
            }
        }) {
            Group {
                if isLoading {
                    HStack(spacing: 5) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text(title)
                            .font(.callout)
                    }
                } else {
                    ButtonContent(title: title, icon: icon, iconPosition: iconPosition)
                }
            }
            .gradientButtonStyle()
//            .background(Constants.orangeGradient, in: .capsule)
            .background(Constants.orangeGradient)
            .cornerRadius(10)
            
        }
        
        .opacity(isLoading ? 0.5 : 1)
        .disabled(isLoading)
    }
}

// Define a struct for GrayButton
struct GrayButton: View {
    var title: String
    var icon: String
    var iconPosition: IconPosition = .right
    @Binding var isLoading: Bool
    var onClick: () -> Void

    var body: some View {
        Button(action: {
            if !isLoading {
                onClick()
            }
        }) {
            Group {
                if isLoading {
                    HStack(spacing: 5) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text(title)
                    }
                } else {
                    ButtonContent(title: title, icon: icon, iconPosition: iconPosition)
                }
            }
//            .fontWeight(.bold)
//            .foregroundStyle(.white)
//            .padding(.vertical, 10)
//            .padding(.horizontal, 20)
            .gradientButtonStyle()
//            .background(LinearGradient(gradient: Gradient(colors: [Color.gray, Color.gray.opacity(0.7)]), startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 30))
            .background(LinearGradient(gradient: Gradient(colors: [Color.gray, Color.gray.opacity(0.7)]), startPoint: .leading, endPoint: .trailing), in: RoundedRectangle(cornerRadius: 10))
        }
        .opacity(isLoading ? 0.5 : 1)
        .disabled(isLoading)
    }
}

// Define a view for ButtonContent
struct ButtonContent: View {
    var title: String
    var icon: String?
    var iconPosition: IconPosition

    var body: some View {
        HStack(spacing: 5) {
            if iconPosition == .left {
                if icon != nil {
                    Image(systemName: icon ?? "")
                }
                Text(title)
            } else {
                Text(title)
                if icon != nil {
                    Image(systemName: icon ?? "")
                }
            }
        }
    }
}
