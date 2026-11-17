import SwiftUI

internal struct EditableRow: View {
    internal var label: String
    @Binding internal var value: String

    @State private var showEditDialog = false
    @State private var editInput: String = ""

    internal var body: some View {
        HStack {
            Text(label)
                .bold()

            Spacer()

            Text(value)

            Spacer().frame(width: 8)

            Image(systemName: "pencil")
                .onTapGesture {
                    editInput = value
                    showEditDialog = true
                }
        }
        .alert(
            String(format: String(localized: "editable_row_alert_title"), label),
            isPresented: $showEditDialog
        ) {
            TextField(String(localized: "editable_row_alert_text_field_label"), text: $editInput)

            Button(String(localized: "editable_row_alert_cancel_button"), role: .cancel) {
                showEditDialog = false
            }

            Button(String(localized: "editable_row_alert_save_button")) {
                value = editInput
                showEditDialog = false
            }
        }
    }
}

#Preview {
    EditableRow(label: "Labek", value: .constant("value"))
}
