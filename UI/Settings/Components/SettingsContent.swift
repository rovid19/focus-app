import SwiftUI

struct SettingsContent: View {
    @ObservedObject var controller: SettingsController
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            SettingsToolbar(section: controller.selectedSection)
            
            // Content based on selected section
            Group {
                switch controller.selectedSection {
                case .blocker:
                    WebsiteBlockerSettingsView(controller: controller.websiteBlockerController)
                case .apps:
                    AppBlockerSettingsView(controller: controller.appBlockerController)
                case .stats:
                    StatsSettingsView(controller: controller.statsController)
                case .general:
                    GeneralSettingsView()
                        .environmentObject(controller.generalController)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct SettingsToolbar: View {
    let section: SettingsSection
    
    var body: some View {
        HStack {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Image(systemName: section.icon)
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.8))
                
                Text(section.rawValue)
                    .font(.custom("Inter-Regular", size: 16 ))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(.regularMaterial)
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1)
                .frame(maxHeight: .infinity, alignment: .bottom)
        )
    }
}
