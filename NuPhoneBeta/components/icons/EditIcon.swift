//
//  EditIcon.swift
//  NuPhoneBeta
//
//  Created by Francis Brokering on 2/27/24.
//

import SwiftUI

struct EditIconButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "square.and.pencil")
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(Color.black.opacity(0.5))
        }
        .font(.title3).bold()
    }
}
