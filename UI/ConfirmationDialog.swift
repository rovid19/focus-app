import SwiftUI

struct ConfirmationDialog: View {
    let title: String
    let message: String
    let confirmText: String
    let cancelText: String
    let confirmAction: () -> Void
    let cancelAction: () -> Void
    let isDestructive: Bool
    
    init(
        title: String,
        message: String,
        confirmText: String = "Confirm",
        cancelText: String = "Cancel",
        isDestructive: Bool = false,
        confirmAction: @escaping () -> Void,
        cancelAction: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.confirmText = confirmText
        self.cancelText = cancelText
        self.isDestructive = isDestructive
        self.confirmAction = confirmAction
        self.cancelAction = cancelAction
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Title
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            // Message
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            // Buttons
            HStack(spacing: 12) {
                Button(action: cancelAction) {
                    Text(cancelText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: confirmAction) {
                    Text(confirmText)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isDestructive ? Color.red : Color.blue)
                        .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(20)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// Convenience initializer for common use cases
extension ConfirmationDialog {
    static func delete(
        itemName: String,
        confirmAction: @escaping () -> Void,
        cancelAction: @escaping () -> Void
    ) -> ConfirmationDialog {
        ConfirmationDialog(
            title: "Delete \(itemName)",
            message: "Are you sure you want to delete this \(itemName)? This action cannot be undone.",
            confirmText: "Delete",
            cancelText: "Cancel",
            isDestructive: true,
            confirmAction: confirmAction,
            cancelAction: cancelAction
        )
    }
}
