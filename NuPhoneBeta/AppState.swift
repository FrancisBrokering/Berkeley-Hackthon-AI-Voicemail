import SwiftUI


enum AppView {
    case loading
    case instruction
    case welcome
    case login
    case nameUser
    case createAgent
    case subscription
    case agent
    case phone
    case callHistory
    case liveCalls
    case error
}

enum Modal {
    case deleteAccount
    case logout
    case deleteFaq
    case selectVoice
    case deleteAction
}

class AppState: ObservableObject {
    @Published var notificationCallId: String? = nil
    @Published var currentTab: Tab = .assistant
    @Published var currentView = AppView.loading
    @Published var previousView = AppView.loading
    @Published var displayNavBar = true
    @Published var displayedModal: Modal? = nil
    @Published var alertAction: (() -> Void)?
    @Published var displayPaywall: Bool = false
    @Published var selectedPlan: String = "pro"
    @Published var displayPurchaseNumberSheet: Bool = false
//    @Published var proFeature: Bool = false
    func performAlertAction() {
        alertAction?()
    }
}
