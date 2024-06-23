import SwiftUI
import CoreHaptics

enum Tab: String, CaseIterable {
    case calls
    case assistant

    var iconName: String {
        switch self {
        case .calls:
            return "phone"
        case .assistant:
            return "person"
        }
    }
}

struct BottomNavBar: View {
    @Binding var selectedTab: Tab
    let badgeNumber: Int
    @State private var iconScale: [Tab: CGFloat] = [.calls: 1, .assistant: 1]

    var body: some View {
        VStack{
            HStack {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Button(action: {
//                        withAnimation(.easeInOut(duration: 0.2)) {
//                            iconScale[tab] = 0.8
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                                iconScale[tab] = 1
//                            }
//                        }
//                        selectedTab = tab
//                        triggerFeedback()
                    }) {
                        GeometryReader { geometry in
                            Rectangle()
                                .foregroundColor(tab == selectedTab ? Color("AccentColor") : .clear)
                                .frame(width: geometry.size.width / 2, height: 3)
                                .padding(.leading, geometry.size.width / 4)
                                .clipShape(Capsule())
                            
                            VStack(spacing: 5) {
                                ZStack {
                                    Image(systemName: tab == selectedTab ? "\(tab.iconName).fill" : tab.iconName)
                                        .font(.system(size: tab == selectedTab ? 24 : 22))
                                        .foregroundColor(tab == selectedTab ? Color("AccentColor") : .gray.opacity(0.5))
                                        .scaleEffect(iconScale[tab] ?? 1)
                                        .frame(width: 25, height: 25)

                                    if tab == .calls && badgeNumber > 0 {
                                        Text("\(badgeNumber)")
                                            .font(.caption2)
                                            .padding(.horizontal, badgeNumber == 1 ? 6 : 5)
                                            .padding(.vertical, 2)
                                            .foregroundColor(.white)
                                            .background(Color.red)
                                            .clipShape(Capsule())
                                            .offset(x: 15, y: -9)
                                    }
                                }
                                Text(tab.rawValue.capitalized)
                                    .font(.caption2)
                                    .foregroundColor(tab == selectedTab ? Color("AccentColor") : .gray.opacity(0.5))
                                    .scaleEffect(iconScale[tab] ?? 1)
                            }
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                iconScale[tab] = 0.9
                                withAnimation(.easeInOut(duration: 0.2)) {
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        iconScale[tab] = 1.0
//                                    }
                                }
                                selectedTab = tab
                                triggerFeedback()
                            }
                        }
                    }
                }
            }
            .frame(width: 290, height: 60)
            .padding(.horizontal, 20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 50, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 50)
                    .stroke(Color("Pink").opacity(0.05), lineWidth: 1)
            )
        }
    }
}
