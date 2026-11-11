import SwiftUI
import QualifioKit

internal struct ConfigurationView: View {
    @StateObject private var viewModel = ConfigurationViewModel()

    @EnvironmentObject private var router: ContentRouter

    @State private var domainInput: String = QualifioConfiguration.loadFromBundle().domain
    @State private var secretInput: String = Secrets.secureTokenSecret ?? ""
    @State private var isDomainError = false
    @State private var isSecretError = false
    @State private var useSecureToken: Bool = !(Secrets.secureTokenSecret ?? "").isBlank

    @FocusState private var focusedField: Field?

    internal var body: some View {
        VStack {
            Spacer()

            Image("Logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 160, height: 160)

            Spacer().frame(height: 32)

            VStack(alignment: .leading, spacing: 4) {
                TextField(
                    String(localized: "configuration_domain_input"),
                    text: $domainInput
                )
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
                .focused($focusedField, equals: .domain)
                .submitLabel(useSecureToken ? .next : .done)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isDomainError ? Color.red : Color.clear, lineWidth: 1)
                )
                .onChange(of: domainInput) { newValue in
                    if isDomainError && !newValue.isEmpty {
                        isDomainError = false
                    }
                }
                .onSubmit {
                    if useSecureToken {
                        focusedField = .secret
                    }
                }

                if isDomainError {
                    Text(String(localized: "configuration_invalid_domain"))
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.85)

            Spacer().frame(height: 16)

            HStack {
                Text(String(localized: "configuration_use_secure_token_label"))
                Spacer()
                Toggle("", isOn: $useSecureToken)
                    .labelsHidden()
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.85)

            if useSecureToken {
                Spacer().frame(height: 16)

                VStack(alignment: .leading, spacing: 4) {
                    TextField(
                        String(localized: "configuration_secret_input"),
                        text: $secretInput
                    )
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: .secret)
                    .submitLabel(.done)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isSecretError ? Color.red : Color.clear, lineWidth: 1)
                    )
                    .onChange(of: secretInput) { newValue in
                        if isSecretError && !newValue.isEmpty {
                            isSecretError = false
                        }
                    }

                    if isSecretError {
                        Text(String(localized: "configuration_invalid_secret"))
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
            }

            Spacer().frame(height: 24)

            Button(action: submit) {
                Text(String(localized: "configuration_button"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.85)
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .textFieldStyle(.roundedBorder)
    }

    private func submit() {
        guard viewModel.validateDomain(domainInput) else {
            isDomainError = true
            return
        }

        if useSecureToken && secretInput.isEmpty {
            isSecretError = true
            return
        }

        Qualifio.shared.configure(
            QualifioConfiguration(domain: domainInput)
        )

        viewModel.updateConfiguration(
            domain: domainInput,
            secret: useSecureToken ? secretInput : nil
        )

        withAnimation {
            router.route = .main
        }

    }
}

private enum Field {
    case domain
    case secret
}

#Preview {
    ConfigurationView()
}
