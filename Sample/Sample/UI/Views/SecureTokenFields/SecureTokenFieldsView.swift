import SwiftUI

internal struct SecureTokenFieldsView: View {
    @StateObject private var viewModel = SecureTokenFieldsViewModel()
    @Preference(\.secureTokenFields) private var fields

    @State private var keyInput: String = ""
    @State private var valueInput: String = ""
    @State private var keyError: Bool = false
    @State private var valueError: Bool = false

    @FocusState private var focusedField: Field?

    internal var body: some View {
        VStack {
            if fields.isEmpty {

            }
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(fields.keys.sorted(), id: \.self) { key in
                        if let value = fields[key] {
                            GroupBox {
                                KeyValuePairRow(
                                    key: key,
                                    value: value,
                                    onEdit: { newValue in
                                        viewModel.addSecureTokenField(key, newValue)
                                    },
                                    onDelete: { viewModel.deleteSecureTokenField(key) }
                                )
                            }
                        }
                    }
                }
            }

            VStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    TextField(String(localized: "secure_token_fields_key_label"), text: $keyInput)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .key)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .value }
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(keyError ? Color.red : Color.clear, lineWidth: 1)
                        )
                        .onChange(of: keyInput) { _ in keyError = false }

                    if keyError {
                        Text(String(localized: "secure_token_fields_invalid_key"))
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    TextField(String(localized: "secure_token_fields_value_label"), text: $valueInput)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .value)
                        .submitLabel(.done)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(valueError ? Color.red : Color.clear, lineWidth: 1)
                        )
                        .onChange(of: valueInput) { _ in valueError = false }

                    if valueError {
                        Text(String(localized: "secure_token_fields_invalid_value"))
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Button {
                    guard !keyInput.isBlank, (fields)[keyInput] == nil else {
                        keyError = true
                        return
                    }

                    guard !valueInput.isBlank else {
                        valueError = true
                        return
                    }

                    viewModel.addSecureTokenField(keyInput, valueInput)

                    keyInput = ""
                    valueInput = ""
                } label: {
                    Text(String(localized: "secure_token_fields_add_button"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
    }
}

private enum Field {
    case key
    case value
}

#Preview {
    SecureTokenFieldsView()
}
