import SwiftUI

struct WebsiteBlockerSettingsView: View {
    @ObservedObject var controller: WebsiteBlockerSettingsController
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                AddWebsiteSection(controller: controller)
                BlockedListHeader(controller: controller)
                
                if controller.blockedWebsites.isEmpty {
                    EmptyStateView()
                } else {
                    WebsiteList(controller: controller)
                }
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Add Website Section
struct AddWebsiteSection: View {
    @ObservedObject var controller: WebsiteBlockerSettingsController
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                TextFieldBox(controller: controller)
                AddButton(controller: controller)
            }
            
            Text("Domains only. Subdomains will also be blocked.")
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

struct TextFieldBox: View {
    @ObservedObject var controller: WebsiteBlockerSettingsController
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "link")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.5))
            
            TextField("e.g., youtube.com or https://twitter.com", text: $controller.newWebsite)
                .font(.custom("Inter-Regular", size: 14))
                .foregroundColor(.white)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    controller.addWebsite(controller.newWebsite)
                }
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
}

struct AddButton: View {
    @ObservedObject var controller: WebsiteBlockerSettingsController
    
    var body: some View {
        Button(action: {
            controller.addWebsite(controller.newWebsite)
        }) {
            HStack(spacing: 6) {
                Image(systemName: "plus")
                    .font(.system(size: 14))
                Text("Add")
                    .font(.custom("Inter-Regular", size: 14))
                    .fontWeight(.medium)
            }
            .foregroundColor(.blue.opacity(0.9))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Header
struct BlockedListHeader: View {
    @ObservedObject var controller: WebsiteBlockerSettingsController
    
    var body: some View {
        HStack {
            Text("Blocked websites")
                .font(.custom("Inter-Regular", size: 15))
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
            
            Text("\(controller.blockedWebsites.count) total")
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
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
                
                Image(systemName: "globe.slash")
                    .font(.system(size: 20))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Text("No websites blocked yet.")
                .font(.custom("Inter-Regular", size: 14))
                .foregroundColor(.white.opacity(0.8))
            
            Text("Add a domain above to start blocking distractions.")
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

// MARK: - Website List
struct WebsiteList: View {
    @ObservedObject var controller: WebsiteBlockerSettingsController
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(controller.blockedWebsites.sorted(), id: \.self) { website in
                WebsiteListItem(
                    website: website,
                    onRemove: { controller.removeWebsite(website) }
                )
            }
        }
    }
}

// MARK: - Website List Item
struct WebsiteListItem: View {
    let website: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            WebsiteInfo(website: website)
            Spacer()
            RemoveButton(onRemove: onRemove)
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

struct WebsiteInfo: View {
    let website: String
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: "https://www.google.com/s2/favicons?domain=\(website)&sz=64")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "globe")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.5))
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
                Text(website)
                    .font(.custom("Inter-Regular", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                LabelBadge(text: "Blocked", icon: "minus.circle")
            }
        }
    }
}

struct LabelBadge: View {
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

struct RemoveButton: View {
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
