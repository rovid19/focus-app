import SwiftUI

struct HomeView: View {
    @ObservedObject var controller: HomeController
    @EnvironmentObject var supabaseAuth: SupabaseAuth
    @EnvironmentObject var router: Router
    @EnvironmentObject var blockerManager: BlockerManager
    @EnvironmentObject var statsManager: StatisticsManager

    @State private var scrollViewportHeight: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            if supabaseAuth.user != nil {
                // TOP
                topBar
                    .padding(.horizontal, 12)
                    .opacity(controller.isTimerRunning ? 0 : 1)
                    .frame(maxHeight: controller.isTimerRunning ? 0 : .infinity, alignment: .bottom)
                    .clipped()

                // MIDDLE
                ScrollView {
                    contentArea
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: scrollViewportHeight)
                }
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                if proxy.size.height.isFinite && proxy.size.height > 0 {
                                    scrollViewportHeight = proxy.size.height
                                }
                            }
                            .onChange(of: proxy.size.height) { newHeight in
                                if newHeight.isFinite && newHeight > 0 {
                                    withAnimation(.easeInOut(duration: 0.8)) { // match your main animation
                                        scrollViewportHeight = newHeight
                                    }
                                }
                            }
                    }
                )
                .padding(.horizontal, !controller.changePadding ? 24 : 0)
                .padding(.vertical, !controller.changePadding ? 12 : 0)
                .scrollIndicators(.hidden)
                .layoutPriority(1)
                .clipped()

                // BOTTOM
                bottomBar
                    .padding(.horizontal, 12)
                    .opacity(controller.isTimerRunning ? 0 : 1)
                    .frame(maxHeight: controller.isTimerRunning ? 0 : .infinity, alignment: .top)
                    .clipped()
            } else {
                loginView
            }
        }
        .frame(width: 460, height: 420) // outer popup frame stays fixed
        .glassWindow(cornerRadius: 0)
        .animation(.easeInOut(duration: 0.8), value: controller.isTimerRunning)
        .onAppear {
            Task { @MainActor in
                router.changeView(view: .home)
            }
        }
    }
}

// MARK: - Pieces

private extension HomeView {
    // Top bar with tabs
    var topBar: some View {
        VStack(spacing: 0) {
            VStack {
                HStack(spacing: 0) {
                    tabButton(
                        title: "Focus",
                        systemImage: "target",
                        isActive: controller.whichView == "focus"
                    ) {
                        controller.switchView(to: "focus")
                    }
                    Spacer()
                    tabButton(
                        title: "Blocker",
                        systemImage: "shield",
                        isActive: controller.whichView == "blocker"
                    ) {
                        controller.switchView(to: "blocker")
                    }

                    Spacer()
                    tabButton(
                        title: "Statistics",
                        systemImage: "chart.bar",
                        isActive: controller.whichView == "stats"
                    ) {
                        controller.switchView(to: "stats")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 12)
            }
            .glassBackground()
            .padding(.top, 12)

            // Border
            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(height: 1)
                .padding(.top, 12)
        }
    }

    // Bottom bar with actions
    var bottomBar: some View {
        VStack(spacing: 0) {
            // Border
            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(height: 1)
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button(action: {
                        controller.logout()
                        print("Logged out")
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "power")
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(.white.opacity(0.7))
                            Text("Logout")
                        }
                    }
                    .glassy()

                    Spacer()

                    Button(action: {
                        controller.openSettings()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "gear")
                                .font(.custom("Inter-Regular", size: 16))
                                .foregroundColor(.white.opacity(0.7))
                            Text("Settings")
                        }
                    }
                    .glassy()
                }
            }
            .padding(.bottom, 12)
        }
    }

    // Login screen
    var loginView: some View {
        VStack(spacing: 20) {
            Image(systemName: "brain.head.profile")
                .font(.custom("Inter-Regular", size: 60))
                .foregroundColor(.blue)

            Text("Welcome to Focus App")
                .font(.custom("Inter-Regular", size: 16))

            Button("Sign in with Google") {
                controller.signIn()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    // Switch between Focus / Stats (type-erased to avoid compiler blow-up)
    var contentArea: AnyView {
        if controller.showFinishSessionDialog {
            return AnyView(FinishSessionDialog(controller: controller.focusController))
        } else {
        if controller.whichView == "focus" {
            return AnyView(controller.focusView)
        } else if controller.whichView == "stats" {
            return AnyView(controller.statsView)
        } else if controller.whichView == "blocker" {
            return AnyView(controller.blockerView)
            } else {
                return AnyView(EmptyView())
            }
        }
    }

    // One tab button
    func tabButton(title: String, systemImage: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            TabButtonContent(title: title, systemImage: systemImage, isActive: isActive)
        }
        .buttonStyle(GlassTabButtonStyle(isActive: isActive))
    }
}

// MARK: - Tab Button Content
struct TabButtonContent: View {
    let title: String
    let systemImage: String
    let isActive: Bool
    @Environment(\.isHovered) var isHovered
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.custom("Inter-Regular", size: 16))
                .foregroundColor(foregroundColor)

            Text(title)
                .font(.custom("Inter-Regular", size: 14))
                .tracking(-0.5)
                .foregroundColor(foregroundColor)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(backgroundColor)
        .overlay(borderOverlay)
        .cornerRadius(8)
        .animation(.easeInOut(duration: 0.2), value: isHovered)
        .animation(.easeInOut(duration: 0.2), value: isActive)
    }
    
    private var foregroundColor: Color {
        if isActive {
            return .white
        } else if isHovered {
            return .white.opacity(0.8)
        } else {
            return .white.opacity(0.4)
        }
    }
    
    private var backgroundColor: Color {
        if isActive {
            return Color.white.opacity(0.05)
        } else if isHovered {
            return Color.white.opacity(0.02)
        } else {
            return Color.clear
        }
    }
    
    @ViewBuilder
    private var borderOverlay: some View {
        if isActive {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        } else if isHovered {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        }
    }
}
