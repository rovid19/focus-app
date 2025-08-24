import SwiftUI

struct SettingsSidebar: View {
    @ObservedObject var controller: SettingsController
    
    var body: some View {
        VStack(spacing: 0) {
            SidebarHeader()
            SidebarNavigation(controller: controller)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 1)
                .frame(maxWidth: .infinity, alignment: .trailing)
        )
    }
}

struct SidebarHeader: View {
    var body: some View {
        HStack(spacing: 12) {
            AppIcon()
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Focus")
                    .font(.custom("Inter-Regular", size: 13))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text("Utilities")
                    .font(.custom("Inter-Regular", size: 11))
                    .foregroundColor(.white.opacity(0.6))
            }
            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(12)
    }
}

struct AppIcon: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .frame(width: 28, height: 28)
            
            Text("F")
                .font(.custom("Inter-Regular", size: 11))
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }
}

struct SidebarNavigation: View {
    @ObservedObject var controller: SettingsController
    
    var body: some View {
        VStack(spacing: 6) {
            ForEach(SettingsSection.allCases, id: \.self) { section in
                SettingsSidebarItem(
                    section: section,
                    isSelected: controller.selectedSection == section,
                    action: { controller.switchSection(to: section) }
                )
            }
        }
        .padding(.horizontal, 12)
    }
}

struct SettingsSidebarItem: View {
    let section: SettingsSection
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            content
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var content: some View {
        HStack(spacing: 12) {
            icon
            labels
            Spacer()
            trailing
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(background)
    }
    
    private var icon: some View {
        Image(systemName: section.icon)
            .font(.system(size: 16))
            .foregroundColor(isSelected ? .white.opacity(0.9) : .white.opacity(0.8))
            .frame(width: 18)
    }
    
    private var labels: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(section.rawValue)
                .font(.custom("Inter-Regular", size: 14))
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .white.opacity(0.9))
            
            Text(section.description)
                .font(.custom("Inter-Regular", size: 11))
                .foregroundColor(.white.opacity(0.6))
        }
    }
    
    @ViewBuilder private var trailing: some View {
    
            Image(systemName: "arrow.right")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.5))
        
    }
    
    private var background: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(isSelected ? Color.white.opacity(0.1) : Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}
