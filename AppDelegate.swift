import AppKit
import CoreText

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
    }

    private func registerFonts() {
        let fontNames = [
            "Inter_18pt-Thin.ttf",
            "Inter_18pt-ExtraLight.ttf",
            "Inter_18pt-Light.ttf",
            "Inter_18pt-Regular.ttf",
            "Inter_18pt-Medium.ttf",
            "Inter_18pt-SemiBold.ttf",
            "Inter_18pt-Bold.ttf",
            "Inter_18pt-ExtraBold.ttf",
        ]

        for fontName in fontNames {
            guard let fontURL = Bundle.main.url(forResource: fontName.replacingOccurrences(of: ".ttf", with: ""), withExtension: "ttf") else {
                print("❌ Could not find font file: \(fontName)")
                continue
            }

            var error: Unmanaged<CFError>?
            let success = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)

            if success {
                print("✅ Successfully registered font: \(fontName)")
            } else {
                print("❌ Failed to register font:")
            }
        }
    }

    func application(_: NSApplication, open urls: [URL]) {
        guard let url = urls.first,
              let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?
              .queryItems?.first(where: { $0.name == "code" })?.value
        else { return }

        Task {
            do {
                let session = try await SupabaseAuth.shared
                    .getClient()
                    .auth
                    .exchangeCodeForSession(authCode: code)

                SupabaseAuth.shared.user = session.user
                print("Logged in \(SupabaseAuth.shared.user)")
            } catch {
                NSLog("[blockerapp] Exchange failed: \(error)")
            }
        }
    }
}
