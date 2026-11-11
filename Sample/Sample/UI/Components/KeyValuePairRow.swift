import SwiftUI

internal struct KeyValuePairRow: View {
    internal let key: String
    internal let value: String
    internal let onEdit: (String) -> Void
    internal let onDelete: () -> Void

    @State private var showEditDialog = false
    @State private var editInput: String = ""

    internal var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(key)
                    .font(.subheadline.weight(.semibold))
                Text(value)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                editInput = value
                showEditDialog = true
            } label: {
                Image(systemName: "pencil")
            }
            .buttonStyle(.borderless)

            Button(action: onDelete) {
                Image(systemName: "x.circle")
            }
            .buttonStyle(.borderless)
        }
        .alert(
            String(format: String(localized: "key_value_pair_row_alert_title"), key),
            isPresented: $showEditDialog
        ) {
            TextField(String(localized: "key_value_pair_row_alert_text_field_label"), text: $editInput)

            Button(String(localized: "key_value_pair_row_alert_cancel_button"), role: .cancel) {
                showEditDialog = false
            }

            Button(String(localized: "key_value_pair_row_alert_save_button")) {
                onEdit(editInput)
                showEditDialog = false
            }
        }
    }
}

#Preview {
    KeyValuePairRow(
        key: "key",
        value: "value",
        onEdit: { _ in },
        onDelete: {}
    )
    .padding()
}
