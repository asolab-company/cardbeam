import Combine
import SwiftUI

struct AddCardRoute: Identifiable {
    let id = UUID()
    let mode: AddTaskMode
}

struct CollectionDetails: View {
    let collectionId: UUID
    let title: String
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var model: TasksModel

    @State private var isReorderMode = false
    @Environment(\.editMode) private var editMode

    @State private var now = Date()
    private let ticker = Timer.publish(every: 1, on: .main, in: .common)
        .autoconnect()

    var onOpenAddNew: () -> Void = {}
    var onEditCard: (CardItem) -> Void = { _ in }

    let listBG = Color.clear
    @State private var addRoute: AddCardRoute? = nil
    @State private var showTrainer = false

    @AppStorage("did_show_cards_hint") private var didShowCardsHint = false
    @State private var showHint = false

    var body: some View {
        ZStack(alignment: .top) {

            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#FE8310"), Color(hex: "#FF9533"),
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: Device.isSmall ? 240 : 270)
            .cornerRadius(30, corners: [.bottomLeft, .bottomRight])
            .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                let hasCards = !model.cards(in: collectionId).isEmpty

                VStack(spacing: 26) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .heavy))
                                .foregroundColor(.white)
                        }

                        Spacer()

                        Text(title)
                            .font(.headline)
                            .foregroundColor(.white)

                        Spacer()

                        Button(action: {
                            model.deleteCollection(id: collectionId)
                            dismiss()
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 18, weight: .heavy))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.horizontal, 26)
                    .padding(.top, 10)

                    Button(action: {
                        addRoute = .init(
                            mode: .create(collectionId: collectionId)
                        )
                    }) {
                        ZStack {
                            Text("Add new flashcard")
                                .font(.system(size: 18, weight: .bold))
                                .italic()
                            HStack {
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(OrangeBtn())
                    .padding(.horizontal, 26)

                    Button(action: {
                        if hasCards { showTrainer = true }
                    }) {
                        ZStack {
                            Text("Start")
                                .font(.system(size: 18, weight: .bold))
                                .italic()
                            HStack {
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 20, weight: .bold))
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(GreenButton())
                    .padding(.horizontal, 26)
                    .disabled(!hasCards)
                    .opacity(hasCards ? 1.0 : 0.5)

                    Spacer(minLength: 0)
                }
                .frame(height: 220)

                if model.cards(in: collectionId).isEmpty {
                    VStack {
                        Spacer()
                        EmptyTasksView()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section {
                            if showHint {
                                TipRow()
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(listBG)
                                    .listRowInsets(
                                        EdgeInsets(
                                            top: 12,
                                            leading: 26,
                                            bottom: 0,
                                            trailing: 26
                                        )
                                    )
                            }

                            ForEach(
                                Array(visibleSortedCards.enumerated()),
                                id: \.element.id
                            ) { index, item in
                                CardRow(item: item)
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(listBG)
                                    .padding(.top, index == 0 ? 12 : 0)
                                    .swipeActions(
                                        edge: .trailing,
                                        allowsFullSwipe: true
                                    ) {
                                        if !isReorderMode && !item.isDone {
                                            Button {
                                                model.deleteCard(id: item.id)
                                            } label: {
                                                Image(systemName: "trash")
                                                    .renderingMode(.template)
                                                    .foregroundColor(.white)
                                            }
                                            .tint(Color(hex: "B23500"))
                                        }
                                    }
                                    .swipeActions(
                                        edge: .leading,
                                        allowsFullSwipe: false
                                    ) {
                                        if !isReorderMode {
                                            Button {
                                                addRoute = .init(
                                                    mode: .edit(item)
                                                )
                                            } label: {
                                                Image(systemName: "pencil")
                                                    .renderingMode(.template)
                                                    .foregroundColor(.white)
                                            }
                                            .tint(Color(hex: "33AE33"))
                                        }
                                    }
                                    .listRowInsets(
                                        EdgeInsets(
                                            top: 0,
                                            leading: 26,
                                            bottom: 0,
                                            trailing: 26
                                        )
                                    )
                            }
                            .onMove { source, destination in
                                model.moveCards(
                                    in: collectionId,
                                    from: source,
                                    to: destination
                                )
                            }
                        } footer: {
                            Color.clear
                                .frame(height: 100)
                                .listRowBackground(listBG)
                        }
                    }

                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(listBG)
                    .environment(
                        \.editMode,
                        .constant(isReorderMode ? .active : .inactive)
                    )
                    .environment(\.defaultMinListRowHeight, 60)
                    .listRowSpacing(12)
                }
            }
        }
        .onAppear {
            if !didShowCardsHint {
                showHint = true
                didShowCardsHint = true
            } else {
                showHint = false
            }
        }
        .onDisappear {
            showHint = false
        }
        .background(
            ZStack {
                Color(hex: "#1B1A1A").ignoresSafeArea()
                Image("app_bg_main").resizable().scaledToFill()
                    .ignoresSafeArea()
            }
        )
        .fullScreenCover(item: $addRoute) { r in
            AddTask(mode: r.mode)
                .environmentObject(model)
        }
        .fullScreenCover(isPresented: $showTrainer) {
            ShowView(
                cards: model.cards(in: collectionId),
                onDelete: { id in
                    model.deleteCard(id: id)
                },
                onFinishBack: { dismiss() }
            )
        }

    }

    private var visibleSortedCards: [CardItem] {
        model.cards(in: collectionId)
    }

}

private struct EmptyTasksView: View {
    var body: some View {
        VStack(spacing: 10) {
            Image("app_ic_empty")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 138, maxHeight: 138)
            Text("Your list is empty")
                .font(.system(size: 16, weight: .light))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

private struct CardRow: View {
    let item: CardItem

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 2) {
                Text(item.front)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 24)
        .frame(height: 60)
        .background(
            RoundedRectangle(cornerRadius: 100, style: .continuous)
                .fill(Color(hex: "151414"))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 100, style: .continuous)
                .stroke(Color.white.opacity(0.13), lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 100, style: .continuous))
    }
}
private struct TipRow: View {

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Image("app_ic_idea")
                .resizable()
                .frame(width: 44, height: 44)

            Text(
                "Swipe left on the bar if you want to delete the word. Drag the word signs if you want to change the order."
            )
            .font(.system(size: 12, weight: .regular))
            .foregroundColor(.white)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(Color.white.opacity(0.2))
        )
    }
}

#Preview("Details • Filled") {
    let m = TasksModel()

    let col = CollectionItem(title: "My collection")
    m.collections = [col]
    m.cards = [
        CardItem(collectionId: col.id, front: "apple", back: "яблоко"),
        CardItem(collectionId: col.id, front: "orange", back: "апельсин"),
    ]
    return CollectionDetails(collectionId: col.id, title: col.title)
        .environmentObject(m)
        .preferredColorScheme(.dark)
}

#Preview("Details • Empty") {
    let m = TasksModel()
    let col = CollectionItem(title: "Empty collection")
    m.collections = [col]
    m.cards = []
    return CollectionDetails(collectionId: col.id, title: col.title)
        .environmentObject(m)
        .preferredColorScheme(.dark)
}
