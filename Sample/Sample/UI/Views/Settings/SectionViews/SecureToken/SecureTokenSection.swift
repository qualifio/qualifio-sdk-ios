import SwiftUI

internal struct SecureTokenSection: View {
    @Preference(\.useSecureToken) private var useSecureToken: Bool
    @Preference(\.secureTokenSecret) private var secureTokenSecret: String
    @Preference(\.secureTokenSubject) private var secureTokenSubject: String

    internal var body: some View {
        Section {
            Toggle(isOn: $useSecureToken) {
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
            HStack {
                Text(String(localized: "settings_secure_token_algorithm_label"))
                    .bold()

                Spacer()

                Text(String("HS256"))
            }

            EditableRow(
                label: String(localized: "settings_secure_token_secret_label"),
                value: $secureTokenSecret
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
