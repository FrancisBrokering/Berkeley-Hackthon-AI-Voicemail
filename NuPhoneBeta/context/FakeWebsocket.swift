import Combine
import SwiftUI

class FakeWebsocket: ObservableObject {
    static let shared = FakeWebsocket()
    var timer: AnyCancellable?
    var callsManager = CallsManager.shared
    
//    init() {
//        startFakeWebsocket()
//    }
//    
    func startFakeWebsocket() {
        timer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchEverySecond()
            }
    }
    
    func fetchEverySecond() {
        CallsManager.fetchLiveCalls(){_ in}
    }
    
    deinit {
        timer?.cancel()
    }
    
    func stopFakeWebsocket() {
        timer?.cancel()
    }
}
