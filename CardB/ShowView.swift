import SwiftUI

struct ShowView: View {
    @Environment(\.dismiss) private var dismiss

    let cards: [CardItem]
    var onDelete: (UUID) -> Void = { _ in }
    var onFinishBack: () -> Void = {}

    @State private var deck: [CardItem] = []
    @State private var index: Int = 0
    @State private var isBackShown = false
    @State private var showFinishOverlay = false

    var body: some View {
        ZStack {
            ZStack(alignment: .top) {
                Color(hex: "#1B1A1A")
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 50)

                VStack(spacing: 14) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .heavy))
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Text(progressTitle)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: deleteCurrent) {
                            Image(systemName: "trash")
                                .font(.system(size: 18, weight: .heavy))
                                .foregroundColor(Color(hex: "BD0000"))
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                    .padding(.bottom, 30)

                    Spacer()

                    if currentCard != nil {
                        ZStack {
                            RoundedRectangle(
                                cornerRadius: 24,
                                style: .continuous
                            )
                            .fill(Color.white)

                            ZStack {
                                RoundedRectangle(
                                    cornerRadius: 20,
                                    style: .continuous
                                )
                                .fill(Color(hex: "#B23500"))
                                .overlay(
                                    Text(currentCard?.front ?? "")
                                        .font(
                                            .system(
                                                size: Device.isSmall ? 30 : 40,
                                                weight: .heavy
                                            )
                                        )
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(4)
                                        .padding(.horizontal, 24)
                                )
                                .rotation3DEffect(
                                    .degrees(isBackShown ? 180 : 0),
                                    axis: (x: 0, y: 1, z: 0)
                                )
                                .opacity(isBackShown ? 0.0 : 1.0)

                                RoundedRectangle(
                                    cornerRadius: 20,
                                    style: .continuous
                                )
                                .fill(Color(hex: "#3F78AE"))
                                .overlay(
                                    Text(currentCard?.back ?? "")
                                        .font(
                                            .system(
                                                size: Device.isSmall ? 30 : 40,
                                                weight: .heavy
                                            )
                                        )
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(4)
                                        .padding(.horizontal, 24)
                                )
                                .rotation3DEffect(
                                    .degrees(isBackShown ? 0 : -180),
                                    axis: (x: 0, y: 1, z: 0)
                                )
                                .opacity(isBackShown ? 1.0 : 0.0)
                            }
                            .padding(10)
                        }
                        .padding(26)
                        .frame(
                            width: Device.isSmall ? 300 : 400,
                            height: Device.isSmall ? 400 : 500
                        )
                        .shadow(radius: 5)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(
                                .spring(response: 0.45, dampingFraction: 0.9)
                            ) {
                                isBackShown.toggle()
                            }
                        }
                        .animation(
                            .spring(response: 0.45, dampingFraction: 0.9),
                            value: isBackShown
                        )
                    } else {
                        Text("No cards")
                            .foregroundColor(.white.opacity(0.8))
                            .padding()
                    }

                    Spacer()

                    Group {
                        if showFinishOverlay {
                            EmptyView()
                        } else {
                            Button(action: primaryAction) {
                                ZStack {
                                    Text(isBackShown ? "Continue" : "Show")
                                        .font(.system(size: 18, weight: .bold))
                                        .italic()

                                    HStack {
                                        Spacer()
                                        Image(
                                            systemName: isBackShown
                                                ? "chevron.right" : "eye.fill"
                                        )
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                    }
                                    .padding(.horizontal)
                                }
                                .padding(.vertical, 14)
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(
                                isBackShown
                                    ? AnyButtonStyle(OrangeBtn())
                                    : AnyButtonStyle(GreenButton())
                            )
                            .padding(.bottom)
                            .padding(.horizontal, 26)
                        }
                    }
                }
            }
            .background(
                ZStack {
                    Color(hex: "#1B1A1A").ignoresSafeArea()
                    Image("app_bg_main").resizable().scaledToFill()
                        .ignoresSafeArea()
                }
            )

            if showFinishOverlay {
                ZStack {
                    GeometryReader { geo in
                        let horizontalPadding: CGFloat = 34

                        VStack(spacing: 16) {
                            Spacer()

                            Image("great")
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: geo.size.width - horizontalPadding
                                        * 2
                                )

                            Spacer()

                            Button(action: { restart() }) {
                                ZStack {
                                    Text("Restart")
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
                            .buttonStyle(GreenButton())
                            .padding(.bottom, 10)

                            Button(action: { onFinishBack() }) {
                                ZStack {
                                    Text("Go to menu")
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
                        }
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity,
                            alignment: .top
                        )
                        .padding(.horizontal, horizontalPadding)
                    }
                }
                .background(
                    ZStack {
                        Color(hex: "#1B1A1A")
                            .ignoresSafeArea()

                        Image("app_bg_main")
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                    }
                )
            }
        }
        .onAppear {
            deck = cards
            index = 0
            isBackShown = false
            showFinishOverlay = deck.isEmpty
        }
    }

    private var currentCard: CardItem? {
        guard deck.indices.contains(index) else { return nil }
        return deck[index]
    }

    private var progressTitle: String {
        guard !deck.isEmpty else { return "0/0" }
        return "\(index + 1)/\(deck.count)"
    }

    private func primaryAction() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.9)) {
            if !isBackShown {
                isBackShown = true
            } else {
                goNext()
            }
        }
    }

    private func goNext() {
        isBackShown = false
        if index + 1 < deck.count {
            index += 1
        } else {
            showFinishOverlay = true
        }
    }

    private func deleteCurrent() {
        guard let cur = currentCard else { return }
        onDelete(cur.id)
        deck.removeAll { $0.id == cur.id }
        if deck.isEmpty {
            showFinishOverlay = true
            return
        }
        if index >= deck.count {
            index = max(0, deck.count - 1)
        }
        isBackShown = false
    }

    private func restart() {
        index = 0
        isBackShown = false
        showFinishOverlay = false
    }
}

struct AnyButtonStyle: ButtonStyle {
    private let _makeBody: (Configuration) -> AnyView
    init<S: ButtonStyle>(_ style: S) {
        _makeBody = { AnyView(style.makeBody(configuration: $0)) }
    }
    func makeBody(configuration: Configuration) -> some View {
        _makeBody(configuration)
    }
}

#Preview("ShowView • 3 cards") {
    let colId = UUID()
    let cards: [CardItem] = [
        CardItem(collectionId: colId, front: "apple", back: "яблоко"),
        CardItem(collectionId: colId, front: "orange", back: "апельсин"),
        CardItem(collectionId: colId, front: "table", back: "стол"),
    ]

    return ShowView(
        cards: cards,
        onDelete: { _ in },
        onFinishBack: {}
    )
    .preferredColorScheme(.dark)
}

#Preview("ShowView • Empty") {
    ShowView(
        cards: [],
        onDelete: { _ in },
        onFinishBack: {}
    )
    .preferredColorScheme(.dark)
}
