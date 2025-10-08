import SwiftUI
import UIKit

struct AddCollection: View {
    @EnvironmentObject var model: TasksModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    let mode: AddCollectionMode

    @State private var title: String = ""

    var body: some View {
        let isEdit: Bool = {
            if case .edit = mode { return true }
            return false
        }()

        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let canSave = !trimmed.isEmpty

        ZStack(alignment: .top) {
            Color(hex: "#1B1A1A")
                .ignoresSafeArea(edges: .top)
                .frame(height: 50)

            VStack(spacing: 20) {

                ZStack {
                    Text(isEdit ? "Edit Collection" : "New Collection")
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
                                if case .edit(let col) = mode {
                                    model.deleteCollection(id: col.id)
                                }
                                dismiss()
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "BD0000"))
                        } else {
                            Button("Cancel") {
                                isFocused = false
                                UIApplication.endEditing()
                                title = ""
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "BD0000"))
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.top, 10)
                .padding(.bottom)

                VStack(spacing: 26) {
                    TaskInputRow(
                        title: isEdit
                            ? "Collection name*" : "Name of the collection*",
                        placeholder: "Enter the collection",
                        text: $title
                    )
                    .focused($isFocused)

                    Button {
                        if isEdit {
                            if case .edit(let col) = mode, canSave {
                                model.editCollectionTitle(
                                    id: col.id,
                                    newTitle: trimmed
                                )
                            }
                            dismiss()
                        } else {
                            if canSave {
                                model.addCollections(titles: [trimmed])
                            }
                            title = ""
                            dismiss()
                        }
                    } label: {
                        RowButtonContent(title: "Save")
                    }
                    .buttonStyle(OrangeBtn())
                    .padding(.horizontal, 24)
                    .padding(.bottom)
                    .disabled(!canSave)
                    .opacity(canSave ? 1.0 : 0.5)

                    Spacer()
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
        .onAppear {
            switch mode {
            case .create:
                title = ""
                isFocused = true
            case .edit(let item):
                title = item.title
                isFocused = true
            }
        }
    }
}

private struct TaskInputRow: View {
    let title: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.top, 5)

            TextField(
                "",
                text: $text,
                prompt: Text(placeholder)
                    .foregroundColor(Color(hex: "5D5D5D"))
                    .font(.system(size: 16))
            )
            .font(.system(size: 16))
            .foregroundColor(.black)
            .padding(.horizontal, 18)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(hex: "B5B5B5"))
            )

        }.background(
            ZStack { Color(hex: "#1B1A1A") }
                .cornerRadius(20)
        )
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

#if DEBUG
    import SwiftUI

    struct AddCollection_Previews: PreviewProvider {
        struct PreviewContainer: View {
            @StateObject var model = TasksModel()

            var body: some View {
                Group {
                    AddCollection(mode: .create)
                        .environmentObject(model)
                        .previewDisplayName("Create")

                    let sample = CollectionItem(title: "Buy milk")
                    AddCollection(mode: .edit(sample))
                        .environmentObject(model)
                        .previewDisplayName("Edit")
                }
                .preferredColorScheme(.dark)
                .background(Color(hex: "232330"))
            }
        }

        static var previews: some View {
            PreviewContainer()
                .previewLayout(.sizeThatFits)
        }
    }
#endif
