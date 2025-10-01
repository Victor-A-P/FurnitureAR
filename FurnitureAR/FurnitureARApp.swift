import SwiftUI

@main
struct FurnitureARApp: App {
    
    @StateObject var placementSettings = PlacementSettings()
    @StateObject var sceneManager = SceneManager()
    
    var body: some Scene {
        WindowGroup {
            SplashScreen()
                .environmentObject(placementSettings)
                .environmentObject(sceneManager)
                .onAppear {
                    sceneManager.refreshPersistenceDataFromDisk()
                }
        }
    }
}
