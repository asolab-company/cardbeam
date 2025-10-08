import Combine
import Foundation
import SwiftUI

enum CollectionStore {
    private static let key = "saved_collections_v1"

    static func save(_ items: [CollectionItem]) {
        let data = try? JSONEncoder().encode(items)
        UserDefaults.standard.set(data, forKey: key)
    }
    static func load() -> [CollectionItem] {
        guard let data = UserDefaults.standard.data(forKey: key),
            let items = try? JSONDecoder().decode(
                [CollectionItem].self,
                from: data
            )
        else { return [] }
        return items
    }
}

enum CardStore {
    private static let key = "saved_cards_v1"

    static func save(_ items: [CardItem]) {
        let data = try? JSONEncoder().encode(items)
        UserDefaults.standard.set(data, forKey: key)
    }
    static func load() -> [CardItem] {
        guard let data = UserDefaults.standard.data(forKey: key),
            let items = try? JSONDecoder().decode([CardItem].self, from: data)
        else { return [] }
        return items
    }
}

struct CollectionItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var createdAt: Date

    init(id: UUID = UUID(), title: String, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
    }
}

struct CardItem: Identifiable, Codable, Equatable {
    let id: UUID
    let collectionId: UUID
    var front: String
    var back: String
    var isDone: Bool
    var dueAt: Date

    init(
        id: UUID = UUID(),
        collectionId: UUID,
        front: String,
        back: String,
        isDone: Bool = false,
        dueAt: Date = Date().addingTimeInterval(24 * 3600)
    ) {
        self.id = id
        self.collectionId = collectionId
        self.front = front
        self.back = back
        self.isDone = isDone
        self.dueAt = dueAt
    }
}

struct TaskItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isDone: Bool
    var dueAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        isDone: Bool = false,
        dueAt: Date = Date().addingTimeInterval(24 * 3600)
    ) {
        self.id = id
        self.title = title
        self.isDone = isDone
        self.dueAt = dueAt
    }
}

enum TaskStore {
    private static let key = "saved_tasks_v2"

    static func save(_ tasks: [TaskItem]) {
        let data = try? JSONEncoder().encode(tasks)
        UserDefaults.standard.set(data, forKey: key)
    }

    static func load() -> [TaskItem] {
        guard let data = UserDefaults.standard.data(forKey: key),
            let items = try? JSONDecoder().decode([TaskItem].self, from: data)
        else { return [] }
        return items
    }

    static func clear() { UserDefaults.standard.removeObject(forKey: key) }
}

final class TasksModel: ObservableObject {

    @Published var tasks: [TaskItem] = TaskStore.load() {
        didSet { TaskStore.save(tasks) }
    }

    @Published var collections: [CollectionItem] = CollectionStore.load() {
        didSet { CollectionStore.save(collections) }
    }
    @Published var cards: [CardItem] = CardStore.load() {
        didSet { CardStore.save(cards) }
    }

    func addCollections(titles: [String]) {
        let trimmed =
            titles
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        guard !trimmed.isEmpty else { return }
        let newItems = trimmed.map { CollectionItem(title: $0) }
        collections.append(contentsOf: newItems)
    }

    func editCollectionTitle(id: UUID, newTitle: String) {
        guard let i = collections.firstIndex(where: { $0.id == id }) else {
            return
        }
        collections[i].title = newTitle
    }

    func deleteCollection(id: UUID) {

        collections.removeAll { $0.id == id }
        cards.removeAll { $0.collectionId == id }
    }

    func addCards(to collectionId: UUID, pairs: [(String, String)]) {
        let prepared = pairs.compactMap { (front, back) -> CardItem? in
            let f = front.trimmingCharacters(in: .whitespacesAndNewlines)
            let b = back.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !f.isEmpty, !b.isEmpty else { return nil }
            return CardItem(collectionId: collectionId, front: f, back: b)
        }
        guard !prepared.isEmpty else { return }
        cards.append(contentsOf: prepared)
    }

    func editCard(id: UUID, newFront: String, newBack: String) {
        guard let i = cards.firstIndex(where: { $0.id == id }) else { return }
        cards[i].front = newFront
        cards[i].back = newBack
    }

    func deleteCard(id: UUID) {
        cards.removeAll { $0.id == id }
    }

    func toggleCardDone(_ id: UUID) {
        guard let i = cards.firstIndex(where: { $0.id == id }) else { return }
        cards[i].isDone.toggle()
    }

    func deferCard24h(_ id: UUID) {
        guard let i = cards.firstIndex(where: { $0.id == id }) else { return }
        cards[i].dueAt = cards[i].dueAt.addingTimeInterval(24 * 3600)
    }

    func cards(in collectionId: UUID) -> [CardItem] {
        cards.filter { $0.collectionId == collectionId }
    }

    func moveCards(
        in collectionId: UUID,
        from source: IndexSet,
        to destination: Int
    ) {

        let indexed = cards.enumerated().filter {
            $0.element.collectionId == collectionId
        }
        var items = indexed.map { $0.element }

        items.move(fromOffsets: source, toOffset: destination)

        let targetIndices = indexed.map { $0.offset }
        for (dst, newItem) in zip(targetIndices, items) {
            cards[dst] = newItem
        }
    }
}
