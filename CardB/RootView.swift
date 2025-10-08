import SwiftUI

enum AppStage {
    case loading
    case onboarding
    case main
}

struct AddTaskRoute: Identifiable {
    let id = UUID()
    let mode: AddTaskMode
}

struct AddCollectionRoute: Identifiable {
    let id = UUID()
    let mode: AddCollectionMode
}

enum AddCollectionMode: Equatable {
    case create
    case edit(CollectionItem)
}

struct RootView: View {
    @StateObject private var model = TasksModel()
    @State private var addRoute: AddCollectionRoute? = nil
    @AppStorage("onboarding_done") private var onboardingDone = false
    @State private var stage: AppStage = .loading

    @State private var showSettings = false

    var body: some View {
        Group {
            switch stage {
            case .loading:
                Loading {
                    stage = onboardingDone ? .main : .onboarding
                }

            case .onboarding:
                Onboarding {
                    onboardingDone = true
                    stage = .main
                }

            case .main:
                ZStack {
                    Main(
                        onOpenSettings: { showSettings = true },
                        onOpenAddNew: { addRoute = .init(mode: .create) },
                        onEditTask: { col in addRoute = .init(mode: .edit(col))
                        }
                    )
                    .environmentObject(model)
                }
                .fullScreenCover(isPresented: $showSettings) {
                    Setting()
                }
                .fullScreenCover(item: $addRoute) { route in
                    AddCollection(mode: route.mode)
                        .environmentObject(model)
                }
            }
        }
        .animation(.easeInOut, value: stage)
    }
}
