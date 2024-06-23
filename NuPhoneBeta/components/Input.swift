import SwiftUI

struct Input: View {
    @Binding var inputValue: String
    @Binding var isEditing: Bool
    var placeholder: String?
    var proxy: ScrollViewProxy?
    var scrollId: String?
    var keyBoardType: UIKeyboardType = .default
    
    // Define focus state to control the keyboard
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack(spacing: 0){
            TextField(placeholder ?? "", text: $inputValue)
                .keyboardType(keyBoardType)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(isEditing ? Color("AccentColor").opacity(0.08) : Color.clear)
                .cornerRadius(isEditing ? 10 : 0)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(isEditing ? Color("AccentColor") : Color.gray.opacity(0.2), lineWidth: 1))
                .focused($isTextFieldFocused) // Bind the focus state to the text field
                
            // Update the focus state based on isEditing
            .onChange(of: isEditing) { editing in
                isTextFieldFocused = editing
                if !editing {
                    // Close the keyboard by resigning focus
                    isTextFieldFocused = false
                }
            }
        }
        .contentShape(Rectangle())
        .id(scrollId)
        .onChange(of: isTextFieldFocused) { focused in
            isEditing = focused
            if !focused {
                // Additional logic if needed when losing focus
            }
        }
        .onTapGesture {
            // Request focus by updating isEditing and isTextFieldFocused
            isEditing = true
            isTextFieldFocused = true
            DispatchQueue.main.async {
                if proxy != nil {
                    withAnimation {
                        proxy?.scrollTo(scrollId, anchor: .init(x: 0.5, y: 0.3))
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                if isEditing {
                    Button("Done") {
                        // Resign focus and close the keyboard when done
                        isEditing = false
                        isTextFieldFocused = false
                    }
                    .tint(Color("Orange"))
                    .fontWeight(.heavy)
                    .hSpacing(.trailing)
                }
            }
        }
    }
}
