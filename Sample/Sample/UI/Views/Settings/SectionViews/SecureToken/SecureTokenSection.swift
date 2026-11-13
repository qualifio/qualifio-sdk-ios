import SwiftUI

internal struct SecureTokenSection: View {
    @Preference(\.useSecureToken) private var useSecureToken: Bool
    @Preference(\.secureTokenSecret) private var secureTokenSecret: String
    @Preference(\.secureTokenSubject) private var secureTokenSubject: String

    @State private var showBlankSecretAlert = false

    private var useSecureTokenBinding: Binding<Bool> {
        Binding(
            get: { useSecureToken },
            set: { enabled in
                if enabled && secureTokenSecret.isBlank {
                    showBlankSecretAlert = true
                } else {
                    useSecureToken = enabled
                }
            }
        )
    }

    private var secureTokenSecretBinding: Binding<String> {
        Binding(
            get: { secureTokenSecret },
            set: { secret in
                secureTokenSecret = secret

                if secret.isBlank {
                    useSecureToken = false
                }
            }
        )
    }

    internal var body: some View {
        Section {
            Toggle(isOn: useSecureTokenBinding) {
                Label {
                    Text(String(localized: "settings_use_secure_token_label"))
                } icon: {
                    ListIconView(
                        icon: "key.shield",
                        foregroundColor: .white,
                        backgroundColor: .red
                    )
                }
            }
            .alert(
                String(localized: "settings_secure_token_secret_blank_alert_title"),
                isPresented: $showBlankSecretAlert
            ) {
                Button(String(localized: "settings_secure_token_secret_blank_alert_button"), role: .cancel) {}
            }

            HStack {
                Text(String(localized: "settings_secure_token_algorithm_label"))
                    .bold()

                Spacer()

                Text(String("HS256"))
            }

            EditableRow(
                label: String(localized: "settings_secure_token_secret_label"),
                value: secureTokenSecretBinding
            )

            EditableRow(
                label: String(localized: "settings_secure_token_subject_label"),
                value: $secureTokenSubject
            )

            NavigationLink {
                SecureTokenFieldsView()
            } label: {
                Label {
                    Text(String(localized: "settings_secure_token_fields_title"))
                } icon: {
                    ListIconView(
                        icon: "key.shield.badge.plus",
                        foregroundColor: .white,
                        backgroundColor: .blue
                    )
                }
            }
        } header: {
            Text(String(localized: "settings_secure_token_title"))
        }
    }
}

#Preview {
    SecureTokenSection()
}
