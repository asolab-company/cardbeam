import SwiftUI
import UIKit

struct TaskField: Identifiable, Hashable {
    let id = UUID()
    var text1: String
    var text2: String
}

enum AddTaskMode: Equatable {
    case create(collectionId: UUID)
    case edit(CardItem)
}

struct AddTask: View {
    @EnvironmentObject var model: TasksModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedID: UUID?

    let mode: AddTaskMode

    @State private var fields: [TaskField] = [TaskField(text1: "", text2: "")]

    var body: some View {
        let isEdit: Bool = {
            if case .edit = mode { return true }
            return false
        }()

        let allFilled = fields.allSatisfy {

            !$0.text1.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !$0.text2.trimmingCharacters(in: .whitespacesAndNewlines)
                    .isEmpty
        }

        ZStack(alignment: .top) {
            Color(hex: "#1B1A1A")
                .ignoresSafeArea(edges: .top)
                .frame(height: 50)

            VStack(spacing: 20) {

                ZStack {
                    Text(isEdit ? "Edit flashcard" : "Add new flashcard")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)

                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .heavy))
                                .foregroundColor(.white)
                        }
                        Spacer()

                        if isEdit {

                            Button("Delete") {
                                if case .edit(let card) = mode {
                                    model.deleteCard(id: card.id)
                                }
                                dismiss()
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "BD0000"))
                        } else {

                            Button("Cancel") {
                                focusedID = nil
                                UIApplication.endEditing()
                                fields = [TaskField(text1: "", text2: "")]
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "BD0000"))
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 8)

                ScrollView {
                    VStack(spacing: 14) {

                        if isEdit {

                            TaskInputRow(
                                title1: "The first side of the card*",
                                title2: "The second side of the card*",
                                placeholder1: "Enter the word",
                                placeholder2: "Enter the translation",
                                text1: $fields[0].text1,
                                text2: $fields[0].text2
                            )
                            .focused($focusedID, equals: fields[0].id)
                        } else {

                            ForEach($fields) { $field in
                                TaskInputRow(
                                    title1: "The first side of the card*",
                                    title2: "The second side of the card*",
                                    placeholder1: "Enter the word",
                                    placeholder2: "Enter the translation",
                                    text1: $field.text1,
                                    text2: $field.text2
                                )
                                .focused($focusedID, equals: field.id)
                            }

                            Button {
                                withAnimation(.easeOut(duration: 0.15)) {
                                    let new = TaskField(text1: "", text2: "")
                                    fields.append(new)
                                    focusedID = new.id
                                }
                            } label: {
                                RowButtonContent(title: "Add new flashcard")
                            }
                            .buttonStyle(OrangeBtn())
                            .padding(.horizontal, 24)
                            .padding(.top)
                        }

                        Button {
                            switch mode {
                            case .edit(let card):

                                let f = fields[0].text1.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                )
                                let b = fields[0].text2.trimmingCharacters(
                                    in: .whitespacesAndNewlines
                                )
                                guard !f.isEmpty, !b.isEmpty else { return }
                                model.editCard(
                                    id: card.id,
                                    newFront: f,
                                    newBack: b
                                )
                                dismiss()

                            case .create(let collectionId):
                                let pairs = fields.compactMap {
                                    field -> (String, String)? in
                                    let f = field.text1.trimmingCharacters(
                                        in: .whitespacesAndNewlines
                                    )
                                    let b = field.text2.trimmingCharacters(
                                        in: .whitespacesAndNewlines
                                    )
                                    return (f.isEmpty || b.isEmpty)
                                        ? nil : (f, b)
                                }
                                guard !pairs.isEmpty else { return }
                                model.addCards(to: collectionId, pairs: pairs)
                                fields = [TaskField(text1: "", text2: "")]
                                dismiss()
                            }
                        } label: {
                            RowButtonContent(title: "Save")
                        }
                        .buttonStyle(GreenButton())
                        .padding(.horizontal, 24)
                        .padding(.bottom)
                        .disabled(
                            {
                                if isEdit {
                                    return fields[0].text1.trimmingCharacters(
                                        in: .whitespacesAndNewlines
                                    ).isEmpty
                                        || fields[0].text2.trimmingCharacters(
                                            in: .whitespacesAndNewlines
                                        ).isEmpty
                                } else {
                                    return !allFilled
                                }
                            }()
                        )
                        .opacity(
                            {
                                if isEdit {
                                    let ok =
                                        !fields[0].text1.trimmingCharacters(
                                            in: .whitespacesAndNewlines
                                        ).isEmpty
                                        && !fields[0].text2.trimmingCharacters(
                                            in: .whitespacesAndNewlines
                                        ).isEmpty
                                    return ok ? 1.0 : 0.5
                                } else {
                                    return allFilled ? 1.0 : 0.5
                                }
                            }()
                        )
                    }
                    .padding(.top)
                }
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
        .onAppear {
            switch mode {
            case .create:
                fields = [TaskField(text1: "", text2: "")]
                focusedID = fields.first?.id
            case .edit(let card):
                fields = [TaskField(text1: card.front, text2: card.back)]
                focusedID = fields.first?.id
            }
        }
    }
}

private struct TaskInputRow: View {
    let title1: String
    let title2: String
    let placeholder1: String
    let placeholder2: String
    @Binding var text1: String
    @Binding var text2: String

    var body: some View {
        VStack(spacing: 5) {

            Text(title1)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.top, 5)

            TextField(
                "",
                text: $text1,
                prompt: Text(placeholder1)
                    .foregroundColor(Color(hex: "B5B5B5"))
                    .font(.system(size: 16))
            )
            .font(.system(size: 16))
            .foregroundColor(.white)
            .padding(.horizontal, 18)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(hex: "#B23500"))
            )

            Text(title2)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.top, 5)

            TextField(
                "",
                text: $text2,
                prompt: Text(placeholder2)
                    .foregroundColor(Color(hex: "B5B5B5"))
                    .font(.system(size: 16))
            )
            .font(.system(size: 16))
            .foregroundColor(.white)
            .padding(.horizontal, 18)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(hex: "#3F78AE"))
            )
        }
        .background(Color(hex: "#1B1A1A"))
        .cornerRadius(20)
        .padding(.horizontal, 24)
    }
}
private struct RowButtonContent: View {
    let title: String
    var body: some View {
        ZStack {
            Text(title)
                .font(.system(size: 16, weight: .bold))
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
}

extension UIApplication {
    static func endEditing() {
        #if canImport(UIKit)
            shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        #endif
    }
}

#Preview("AddTask • Create") {
    let m = TasksModel()
    return AddTask(mode: .create(collectionId: UUID()))
        .environmentObject(m)
        .preferredColorScheme(.dark)
}

#Preview("AddTask • Edit") {
    let m = TasksModel()
    let colId = UUID()
    let sample = CardItem(collectionId: colId, front: "apple", back: "яблоко")
    m.cards = [sample]
    return AddTask(mode: .edit(sample))
        .environmentObject(m)
        .preferredColorScheme(.dark)
}
