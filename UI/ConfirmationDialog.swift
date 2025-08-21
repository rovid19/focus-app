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
        VStack(spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                Button(cancelText, action: cancelAction)
                    .buttonStyle(DialogButtonStyle(color: .gray.opacity(0.3)))
                
                Button(confirmText, action: confirmAction)
                    .buttonStyle(DialogButtonStyle(color: isDestructive ? .red.opacity(0.8) : .blue.opacity(0.8)))
            }
        }
        .padding()
        .glassBackground()
    }
}

struct DialogButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
            )
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

// Convenience initializer
extension ConfirmationDialog {
    static func delete(
        itemName: String,
        confirmAction: @escaping () -> Void,
        cancelAction: @escaping () -> Void
    ) -> ConfirmationDialog {
        ConfirmationDialog(
            title: "Delete \(itemName)",
            message: "Are you sure you want to delete this \(itemName)?",
            confirmText: "Delete",
            cancelText: "Cancel",
            isDestructive: true,
            confirmAction: confirmAction,
            cancelAction: cancelAction
        )
    }
}
