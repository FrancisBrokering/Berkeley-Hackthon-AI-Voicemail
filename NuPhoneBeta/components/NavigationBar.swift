//
//  NavigationBar.swift
//  NuPhoneBeta
//
//  Created by Francis Brokering on 2/27/24.
//

import SwiftUI

struct NavigationBar: View {
    var title = ""
    var textColor = Color(.black)
    var body: some View {
        ZStack {
            Color.clear
                .background(.ultraThinMaterial)
                .blur(radius: 10)
            Text(title)
                .foregroundColor(textColor)
                .font(.largeTitle.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
        }
        .frame(height: 70)
        .frame(maxHeight: .infinity, alignment: .top)
    }
}

#Preview {
    NavigationBar()
}
