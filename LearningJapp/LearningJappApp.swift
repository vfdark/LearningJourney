import SwiftUI
import SwiftData

@main
struct LearningJappApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)   // the whole app is always dark mode
        }
        
        .modelContainer(for: [Goal.self, DayEntry.self])
    }
    init() {
           #if DEBUG
           // TESTING ONLY: erases saved data on every launch. Delete this block before you submit.
           let folder = URL.applicationSupportDirectory
           for name in ["default.store", "default.store-shm", "default.store-wal"] {
               try? FileManager.default.removeItem(at: folder.appending(path: name))
           }
           #endif
       }
    
}


