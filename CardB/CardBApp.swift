import SwiftUI

@main
struct CardBApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}

enum AppLinks {

    static let appURL = URL(string: "https://apps.apple.com/app/id6753748589")!

    static let termsOfUse = URL(string: "https://docs.google.com/document/d/e/2PACX-1vRBSzBSzy4wRt62VY07r9-tvKXJViNXoPGc2p-qetZShMmJfqyYvxKu4pvIjXO-YKtIWiFoRr3wVs3e/pub")!
    static let privacyPolicy = URL(string: "https://docs.google.com/document/d/e/2PACX-1vRBSzBSzy4wRt62VY07r9-tvKXJViNXoPGc2p-qetZShMmJfqyYvxKu4pvIjXO-YKtIWiFoRr3wVs3e/pub")!

    static var shareMessage: String {
        """
        Check out this app I’m using.  
        It’s simple, useful, and helps me every day.  

        Download here:  
        \(appURL.absoluteString)
        """
    }

    static var shareItems: [Any] { [shareMessage, appURL] }
}

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

enum Device {
    static var isSmall: Bool {
        UIScreen.main.bounds.height < 700
    }

    static var isMedium: Bool {
        UIScreen.main.bounds.height >= 700 && UIScreen.main.bounds.height < 850
    }

    static var isLarge: Bool {
        UIScreen.main.bounds.height >= 850
    }
}

struct OrangeBtn: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(Color(hex: "FE830F"))
            )
            .foregroundColor(.white)
            .overlay(
                Capsule()
                    .stroke(Color.white, lineWidth: 2)
            )
            .overlay(
                Capsule()
                    .stroke(
                        Color.white.opacity(
                            configuration.isPressed ? 0.25 : 0.12
                        ),
                        lineWidth: 1
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .shadow(
                color: .black.opacity(0.25),
                radius: configuration.isPressed ? 2 : 6,
                x: 0,
                y: 4
            )
    }
}

struct GreenButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .background(
                Capsule()
                    .fill(Color(hex: "#33AE33"))
            )
            .foregroundColor(.white)
            .overlay(
                Capsule()
                    .stroke(Color.white, lineWidth: 2)
            )
            .overlay(
                Capsule()
                    .stroke(
                        Color.white.opacity(
                            configuration.isPressed ? 0.25 : 0.12
                        ),
                        lineWidth: 1
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .shadow(radius: configuration.isPressed ? 2 : 6, y: 2)
    }
}
