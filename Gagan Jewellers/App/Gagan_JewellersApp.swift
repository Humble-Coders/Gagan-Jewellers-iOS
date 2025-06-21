import SwiftUI
import Firebase

@main
struct GaganJewellersApp: App {
    
    init() {
        FirebaseApp.configure()
        // Initialize image cache
        _ = ImageCacheManager.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .onReceiveAppNotifications()
        }
    }
}

// Extension to handle app lifecycle for cache management
extension View {
    func onReceiveAppNotifications() -> some View {
        self
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification)) { _ in
                ImageCacheManager.shared.clearMemoryCache()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                ImageCacheManager.shared.printCacheInfo()
            }
    }
}
