import SwiftUI

struct CustomInput<Value: InputConvertible>: View {
    @Binding var value: Value
    var label: String
    var iconName: String?
    var isDisabled: Bool = false
    var placeholder: String = ""
    var placeholderColor: Color = .gray
    
    // Internal text representation for TextField
    @State private var text: String
    
    init(value: Binding<Value>, label: String, iconName: String? = nil, isDisabled: Bool = false, placeholder: String = "", placeholderColor: Color = .gray) {
        self._value = value
        self.label = label
        self.iconName = iconName
        self.isDisabled = isDisabled
        self.placeholder = placeholder
        self.placeholderColor = placeholderColor
        self._text = State(initialValue: value.wrappedValue.description)
    }

    var body: some View {
        HStack {
            if let iconName = iconName {
                Image(systemName: iconName)
                    .foregroundColor(.gray)
                    .padding(.trailing, 2)
            }

            TextField(label, text: $text)
                .onChange(of: text) { newValue in
                    if let newValue = Value(newValue) {
                        value = newValue
                    }
                }
                .keyboardType(getKeyboardType())
                .placeholder(when: text.isEmpty) {
                    Text(placeholder).foregroundColor(placeholderColor)
                }
                .disabled(isDisabled)
                .inputBoxStyle()
        }
    }

    private func getKeyboardType() -> UIKeyboardType {
        switch value {
        case is Int:
            return .numberPad
        case is Double:
            return .decimalPad
        default:
            return .default
        }
    }
}

struct CustomInput_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var inputText: String = ""

        var body: some View {
            CustomInput(
                value: $inputText,
                label: "Email",
                iconName: "envelope",
                placeholder: "Email"
            )
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}
