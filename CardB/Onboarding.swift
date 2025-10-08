import SwiftUI

struct Onboarding: View {

    var onContinue: () -> Void = {}

    var body: some View {
        ZStack {
            Color(hex: "#151414")
                .ignoresSafeArea()

            Image("onboarding")
                .resizable()
                .scaledToFill()
                .offset(y: Device.isSmall ? -40 : 0)
                .ignoresSafeArea()

            GeometryReader { geo in
                VStack {
                    Spacer()

                    VStack(spacing: 10) {
                        Text("Why you’ll love it")
                            .foregroundColor(Color.init(hex: "FE830F"))
                            .font(
                                .system(
                                    size: Device.isSmall ? 26 : 36,
                                    weight: .heavy
                                )
                            )
                            .italic()
                            .padding(.bottom, Device.isSmall ? 2 : 10)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("• 📝 Easy card creation")
                                .font(
                                    .system(
                                        size: Device.isSmall ? 14 : 17,
                                        weight: .semibold
                                    )
                                )
                                .foregroundColor(.white)
                                .padding(.leading, 55)
                                .padding(.bottom, 5)
                            Text("• 📚 Organized collection")
                                .font(
                                    .system(
                                        size: Device.isSmall ? 14 : 17,
                                        weight: .semibold
                                    )
                                )
                                .foregroundColor(.white)
                                .padding(.leading, 55)
                                .padding(.bottom, 5)
                            Text("• 🎯 Study mode")
                                .font(
                                    .system(
                                        size: Device.isSmall ? 14 : 17,
                                        weight: .semibold
                                    )
                                )
                                .foregroundColor(.white)
                                .padding(.leading, 55)
                                .padding(.bottom, 5)
                            Text("• 🚀 Offline access")
                                .font(
                                    .system(
                                        size: Device.isSmall ? 14 : 17,
                                        weight: .semibold
                                    )
                                )
                                .foregroundColor(.white)
                                .padding(.leading, 55)
                                .padding(.bottom, 5)
                            Text("• ✨ Simple, clean design")
                                .font(
                                    .system(
                                        size: Device.isSmall ? 14 : 17,
                                        weight: .semibold
                                    )
                                )
                                .foregroundColor(.white)
                                .padding(.leading, 55)
                                .padding(.bottom, 5)
                                .padding(.bottom, Device.isSmall ? 5 : 15)

                            Button(action: { onContinue() }) {
                                ZStack {
                                    Text("Continue")
                                        .font(.system(size: 18, weight: .bold))
                                        .italic()
                                    HStack {
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(
                                                .system(size: 20, weight: .bold)
                                            )
                                    }
                                    .padding(.horizontal)
                                }
                                .padding(.vertical, 14)
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(OrangeBtn())
                            .padding(.bottom, 10)

                            TermsFooter().padding(
                                .bottom,
                                Device.isSmall ? 100 : 40
                            )
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal)
            }
        }.ignoresSafeArea()
    }
}

private struct BulletRow: View {
    let title: String
    let description: String

    init(_ title: String, _ description: String) {
        self.title = title
        self.description = description
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {

            Text(" – \(description)")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white)
            Spacer()
        }
    }
}

private struct TermsFooter: View {
    var body: some View {
        VStack(spacing: 2) {
            Text("By Proceeding You Accept")
                .foregroundColor(Color.init(hex: "B5B5B5"))
                .font(.footnote)

            HStack(spacing: 0) {
                Text("Our ")
                    .foregroundColor(Color.init(hex: "B5B5B5"))
                    .font(.footnote)

                Link("Terms Of Use", destination: AppLinks.termsOfUse)
                    .font(.footnote)
                    .foregroundColor(Color.init(hex: "33AE33"))

                Text(" And ")
                    .foregroundColor(Color.init(hex: "B5B5B5"))
                    .font(.footnote)

                Link("Privacy Policy", destination: AppLinks.privacyPolicy)
                    .font(.footnote)
                    .foregroundColor(Color.init(hex: "33AE33"))

            }
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}

extension Text {

    func link(_ url: URL) -> some View {
        Link(destination: url) { self }
    }
}

#Preview {
    Onboarding {
        print("Finished")
    }
}
