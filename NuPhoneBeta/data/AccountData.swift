import Foundation

class Account: ObservableObject {
    @Published var last_usage_reset: String
    @Published var next_usage_reset: String
    @Published var current_usage_minutes: Double
    @Published var usage_limit_minutes: Double
    
    init(last_usage_reset: String, current_usage_minutes: Double, usage_limit_minutes: Double) {
        let formattedLastUsageReset = Account.formatDate(dateString: last_usage_reset)
        let nextReset = Account.calculateNextResetDate(lastResetDate: last_usage_reset)
        
        self.last_usage_reset = formattedLastUsageReset
        self.next_usage_reset = nextReset
        self.current_usage_minutes = current_usage_minutes
        self.usage_limit_minutes = usage_limit_minutes
    }
    
    private static func formatDate(dateString: String) -> String {
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = inputFormatter.date(from: dateString) else {
            return ""
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MM/dd"
        return outputFormatter.string(from: date)
    }
    
    private static func calculateNextResetDate(lastResetDate: String) -> String {
        let inputFormatter = ISO8601DateFormatter()
        inputFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = inputFormatter.date(from: lastResetDate) else {
            return ""
        }
        
        guard let nextDate = Calendar.current.date(byAdding: .day, value: 30, to: date) else {
            return ""
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MM/dd"
        return outputFormatter.string(from: nextDate)
    }
}
