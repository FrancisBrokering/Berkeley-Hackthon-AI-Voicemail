import SwiftUI

struct OTPView: View {
    @Binding var otpText: String
    @Binding var isOtpLoading: Bool
    /// Closure to handle the OTP verification and sign-in process
    var onVerify: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(alignment: .leading, spacing: 15, content: {
            // Back Button
            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: "arrow.left")
                    .font(.title2)
                    .foregroundStyle(.gray)
            })
            .padding(.top, 15)
            
            Text("Enter Code")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding(.top, 5)
            
            Text("A 6 digit code has been sent to you.")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.gray)
                .padding(.top, -5)
            
            VStack(spacing: 25) {
                // Custom OTP TextField
                OTPVerificationView(otpText: $otpText)
                
                // Verify Button
                GradientButton(title: "Verify", icon: "arrow.right", isLoading: $isOtpLoading, onClick: {
                    onVerify(otpText)
                    isOtpLoading = true
                })
                .hSpacing(.trailing)
                // Disabling Until the Data is Entered
                .disableWithOpacity(otpText.isEmpty)
            }
            .padding(.top, 20)
            
            Spacer(minLength: 0)
        })
        .padding(.vertical, 15)
        .padding(.horizontal, 25)
        // Since this is going to be a Sheet.
        .interactiveDismissDisabled()
    }
}

