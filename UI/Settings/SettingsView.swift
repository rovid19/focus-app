import SwiftUI

struct SettingsView: View {
    @StateObject private var controller: SettingsController

    init(controller: SettingsController) {
        _controller = StateObject(wrappedValue: controller)
    }

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Settings")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Websites Blocker Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "globe")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Websites Blocker")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Block distracting websites during focus sessions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button("Configure Websites") {
                        // TODO: Open websites configuration
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.leading, 32)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            
            // Apps Blocker Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "app.badge")
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    Text("Apps Blocker")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Block distracting applications during focus sessions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button("Configure Apps") {
                        // TODO: Open apps configuration
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(.leading, 32)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(12)
            
            Spacer()
        }
        .padding()
        .frame(minWidth: 400, minHeight: 500)
    }
}