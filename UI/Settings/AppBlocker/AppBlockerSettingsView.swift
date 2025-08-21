import SwiftUI

struct AppBlockerSettingsView: View {
    @ObservedObject var controller: AppBlockerSettingsController
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                AddAppSection(controller: controller)
                BlockedAppsListHeader(controller: controller)
                
                if controller.blockedApps.isEmpty {
                    EmptyAppsStateView()
                } else {
                    BlockedAppsList(controller: controller)
                }
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Add App Section
struct AddAppSection: View {
    @ObservedObject var controller: AppBlockerSettingsController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                AppPickerButton(controller: controller)
            }
            
            Text("Select applications from your Applications folder to block during focus sessions.")
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct AppPickerButton: View {
    @ObservedObject var controller: AppBlockerSettingsController
    
    var body: some View {
        Button(action: {
            controller.openApplicationsPicker()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "folder")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.5))
                
                Text("Browse Applications...")
                    .font(.custom("Inter-Regular", size: 14))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Header
struct BlockedAppsListHeader: View {
    @ObservedObject var controller: AppBlockerSettingsController
    
    var body: some View {
        HStack {
            Text("Blocked applications")
                .font(.custom("Inter-Regular", size: 15))
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
            
            Text("\(controller.blockedApps.count) total")
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Empty State
struct EmptyAppsStateView: View {
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .frame(width: 40, height: 40)
                
                Image(systemName: "app.badge.checkmark")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Text("No applications blocked yet.")
                .font(.custom("Inter-Regular", size: 14))
                .foregroundColor(.white.opacity(0.8))
            
            Text("Select applications above to start blocking distractions.")
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Apps List
struct BlockedAppsList: View {
    @ObservedObject var controller: AppBlockerSettingsController
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(controller.blockedApps.sorted(by: { $0.name < $1.name })) { app in
                AppListItem(
                    app: app,
                    onRemove: { controller.removeApp(app) }
                )
            }
        }
    }
}

// MARK: - App List Item
struct AppListItem: View {
    let app: BlockedApp
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            AppInfo(app: app)
            Spacer()
            RemoveAppButton(onRemove: onRemove)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct AppInfo: View {
    let app: BlockedApp
    
    var body: some View {
        HStack(spacing: 12) {
            Group {
                if let icon = app.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "app")
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .frame(width: 20, height: 20)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.custom("Inter-Regular", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                AppStatusBadge(text: "Blocked", icon: "minus.circle")
            }
        }
    }
}

struct AppStatusBadge: View {
    let text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
            
            Text(text)
                .font(.custom("Inter-Regular", size: 10))
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct RemoveAppButton: View {
    let onRemove: () -> Void
    
    var body: some View {
        Button(action: onRemove) {
            HStack(spacing: 4) {
                Image(systemName: "xmark")
                    .font(.system(size: 12))
                
                Text("Remove")
                    .font(.custom("Inter-Regular", size: 12))
                    .fontWeight(.medium)
            }
            .foregroundColor(.white.opacity(0.8))
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
