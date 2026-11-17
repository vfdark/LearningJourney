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
    
    
}


