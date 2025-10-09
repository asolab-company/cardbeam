import Combine
import SwiftUI

enum SortChoice: Equatable {
    case newestFirst
    case oldestFirst
    case onlyActive
    case onlyDone
}

struct Main: View {
    @EnvironmentObject var model: TasksModel
    @State private var isReorderMode = false
    @Environment(\.editMode) private var editMode

    var onOpenSettings: () -> Void = {}
    var onOpenAddNew: () -> Void = {}
    var onEditTask: (CollectionItem) -> Void = { _ in }

    @State private var showSortMenu = false
    @State private var sortChoice: SortChoice = .newestFirst

    @State private var routeToDetails: CollectionRoute?
    struct CollectionRoute: Identifiable {
        let id = UUID()
        let collectionId: UUID
        let title: String
    }

    let listBG = Color.clear

    var body: some View {
        ZStack(alignment: .top) {

            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "#FE8310"),
                    Color(hex: "#FF9533"),
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: Device.isSmall ? 155 : 200)
            .cornerRadius(30, corners: [.bottomLeft, .bottomRight])
            .ignoresSafeArea(edges: .top)

            if showSortMenu {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { showSortMenu = false } }

                SortMenu(
                    selected: $sortChoice,
                    onSelect: { choice in
                        sortChoice = choice
                        withAnimation { showSortMenu = false }
                    },
                    onClose: { withAnimation { showSortMenu = false } }
                )
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .topTrailing
                )
                .padding(.top, Device.isSmall ? 10 : 14)
                .padding(.trailing, Device.isSmall ? 18 : 20)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(2)
            }

            VStack(spacing: 0) {

                VStack(spacing: 26) {
                    HStack {
                        Button(action: onOpenSettings) {
                            Image("app_ic_settings")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                        }

                        Spacer()

                        Text("My flashcards")
                            .font(.headline)
                            .foregroundColor(.white)

                        Spacer()

                        Button {
                            withAnimation(
                                .spring(response: 0.3, dampingFraction: 0.9)
                            ) {
                                showSortMenu.toggle()
                            }
                        } label: {
                            Image("app_ic_sort")
                                .resizable()
                                .renderingMode(.template)
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                        }
                    }
                    .padding(.horizontal, 26)
                    .padding(.top, 10)

                    Button(action: { onOpenAddNew() }) {
                        ZStack {
                            Text("Create new collection")
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

                    Spacer(minLength: 0)
                }
                .frame(height: 140)

                if model.collections.isEmpty {
                    VStack {
                        Spacer()
                        EmptyTasksView()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section {
                            ForEach(
                                Array(visibleSortedCollections.enumerated()),
                                id: \.element.id
                            ) { index, item in
                                TaskRow(
                                    item: item,
                                    count: model.cards(in: item.id).count,
                                    isFirst: index == 0,
                                    isLast: index == visibleSortedCollections
                                        .count - 1
                                )
                                .onTapGesture {
                                    routeToDetails = .init(
                                        collectionId: item.id,
                                        title: item.title
                                    )
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(listBG)
                                .padding(.top, index == 0 ? 12 : 0)
                                .swipeActions(
                                    edge: .trailing,
                                    allowsFullSwipe: true
                                ) {
                                    if !isReorderMode {
                                        Button {
                                            model.deleteCollection(id: item.id)
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
                                            onEditTask(item)
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
        .background(
            ZStack {
                Color(hex: "#1B1A1A").ignoresSafeArea()
                Image("app_bg_main").resizable().scaledToFill()
                    .ignoresSafeArea()
            }
        )
        .fullScreenCover(item: $routeToDetails) { r in
            CollectionDetails(collectionId: r.collectionId, title: r.title)
                .environmentObject(model)
        }
    }

    private var visibleSortedCollections: [CollectionItem] {
        switch sortChoice {
        case .newestFirst:
            return model.collections.sorted { $0.createdAt > $1.createdAt }
        case .oldestFirst:
            return model.collections.sorted { $0.createdAt < $1.createdAt }
        case .onlyActive:
            return model.collections.sorted {
                $0.title.lowercased() < $1.title.lowercased()
            }
        case .onlyDone:
            return model.collections.sorted {
                $0.title.lowercased() > $1.title.lowercased()
            }
        }
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

private struct TaskRow: View {
    let item: CollectionItem
    let count: Int
    var isFirst: Bool = false
    var isLast: Bool = false

    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 2) {
                Text(item.title)
                    .foregroundColor(.white)
                    .font(.system(size: 16, weight: .bold))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()

                Text("\(count)")
                    .foregroundColor(Color(hex: "33AE33"))
                    .font(.system(size: 16, weight: .regular))
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
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
        .contentShape(
            RoundedRectangle(cornerRadius: 100, style: .continuous)
        )
    }
}

private struct SortMenu: View {
    @Binding var selected: SortChoice
    var onSelect: (SortChoice) -> Void
    var onClose: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                    }
                }
                .padding(.trailing, 6)

                VStack(alignment: .leading, spacing: 0) {
                    row("Newest first", isOn: selected == .newestFirst) {
                        onSelect(.newestFirst)
                    }
                    row("Oldest first", isOn: selected == .oldestFirst) {
                        onSelect(.oldestFirst)
                    }
                    row("A - Z", isOn: selected == .onlyActive) {
                        onSelect(.onlyActive)
                    }
                    row("Z - A", isOn: selected == .onlyDone) {
                        onSelect(.onlyDone)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
                .padding(.top, 10)
            }
        }
        .frame(maxWidth: 180, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .background(
            TopNub()
                .fill(.ultraThinMaterial)
                .overlay(Color.black.opacity(0.25))
                .frame(width: 36, height: 36)
                .offset(x: 220, y: -18)
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.4), radius: 10, y: 6)
    }

    @ViewBuilder
    private func row(_ title: String, isOn: Bool, action: @escaping () -> Void)
        -> some View
    {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white)
                Spacer(minLength: 8)
                ZStack {
                    Circle()
                        .fill(
                            isOn
                                ? Color(hex: "#FE830F")
                                : Color.white.opacity(0.08)
                        )
                        .frame(width: 20, height: 20)
                        .overlay(
                            Circle()
                                .inset(by: -2)
                                .stroke(Color.black.opacity(0.3), lineWidth: 1)
                        )
                    if isOn {
                        Image(systemName: "checkmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .contentShape(Rectangle())
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

private struct TopNub: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let r = rect.width / 2
        p.addRoundedRect(in: rect, cornerSize: CGSize(width: r, height: r))
        return p
    }
}

#Preview("Main • Filled") {
    let m = TasksModel()

    m.collections = [
        CollectionItem(title: "Spanish A1"),
        CollectionItem(title: "IT terms"),
        CollectionItem(title: "Phrasal verbs"),
    ]
    return Main()
        .environmentObject(m)
        .preferredColorScheme(.dark)
}

#Preview("Main • Empty") {
    let m = TasksModel()
    m.collections = []
    return Main()
        .environmentObject(m)
        .preferredColorScheme(.dark)
}
