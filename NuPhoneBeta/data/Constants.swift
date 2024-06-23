import Foundation
import SwiftUI

struct Constants {
//    static let baseURL = URL(string: "https://api.wako.ai/")!
    static let baseURL = URL(string: "https://api.voiceos.io/")!
//     static let baseURL = URL(string: "http://127.0.0.1:5003/")!
//    static let baseURL = URL(string: "https://2f52-2001-5a8-4098-d600-4029-f754-eecc-47ed.ngrok-free.app/")!
    static let webSocketBaseURL = URL(string: "wss://nuphone.wako.ai/")!
    static let googleOauth2ClientId = "791773396593-ci2l3pbki9p6a4rju0iht6ssnk1bioq1.apps.googleusercontent.com"
    static let googleOauth2Uri = "com.googleusercontent.apps.791773396593-ci2l3pbki9p6a4rju0iht6ssnk1bioq1"
    static let googleOauth2Scope = "email+profile+calendar.events"
    //    static let webSocketBaseURL = URL(string: "wss://127.0.0.1:5001/")!
    //used for bottom tab-icons, tab leters in AgentView, and save button in AgentView
    static let nuPhoneOrange = Color(hexadecimal: "#fdb517")
    static let nuPhoneBackgroundGray = Color(hexadecimal: "#f5f8f9")
    static let agentPhoneNumber = "(415)-942-0699"
    static let testCallPhoneNumber = "(415)-915-8418"
    static let orangeGradient = LinearGradient(
        gradient: Gradient(colors: [ Color(hexadecimal: "#fdb517"), Color(hexadecimal: "#fdb517")]),
        startPoint: .leading,
        endPoint: .trailing
    )
//    static let orangeGradient = Color(hexadecimal: "#fdb517")
    static let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color("AccentColor")]),
        startPoint: .leading,
        endPoint: .trailing
    )
    static let yopGradient = LinearGradient(
        gradient: Gradient(colors: [Color("AccentColor")]),
        startPoint: .leading,
        endPoint: .trailing
    )
}
